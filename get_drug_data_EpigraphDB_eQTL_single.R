library("epigraphdb")
library("dplyr")
library("tidyr")

###Analysis looking at ClinGov trials with results published on the server.

endpoint <- "/cypher"
method <- "POST"
params <- list(query = query)

#Query Open targets for drug targets.

query <- "MATCH (d1:Drug)-[ot:OPENTARGETS_DRUG_TO_TARGET]->(g1:Gene) 
           RETURN d1.label, ot.action_type, ot.phase, g1.description, g1.druggability_tier, g1.ensembl_id, g1.name, g1.small_mol_druggable"


params <- list(query = query)
results <- query_epigraphdb(
  route = endpoint,
  params = params,
  method = method,
  mode = "table"
)

#Query CPIC for drug targets

query2 <- "MATCH (d1:Drug)-[c:CPIC]->(g1:Gene) 
           RETURN d1.label, c.cpic_level, c.pgx_on_fda_label, c.pharmgkb_level_of_evidence, g1.description, g1.druggability_tier, g1.ensembl_id, g1.name, g1.small_mol_druggable"



params2 <- list(query = query2)
results2 <- query_epigraphdb(
  route = endpoint,
  params = params2,
  method = method,
  mode = "table"
)

#Load in data from Clinical trials.
clingov <- read.delim("clingov_required_primary.tsv", sep="\t", header=T, stringsAsFactors=F, row.names=NULL, quote="")
#Find only studies with drugs as intervention.
drugs_clingov <- clingov[grepl("Drug", clingov$all_interv_types),]

drugs_clingov2 <- drugs_clingov %>% mutate(drug = strsplit(mesh_interv, "\\|")) %>% tidyr::unnest(drug)
drugs_clingov2$drug <- toupper(drugs_clingov2$drug)

#Load in the data with significant single-SNP eQTL MR
table_eqtl <- read.delim("merged_single_significant.txt", sep="\t", header=T, stringsAsFactors=F, row.names=NULL, quote="")
#Map ClinGov drugs to genes via OT
clingov_vs_ot <- merge(drugs_clingov2, results, by.x="drug", by.y="d1.label")

#Map ClinGov drugs to genes via CPIC
clingov_vs_cpic <- merge(drugs_clingov2, results2, by.x="drug", by.y="d1.label")

#Map results to MR analysis via gene id.
clingov_vs_ot_st7 <- clingov_vs_ot[clingov_vs_ot$g1.ensembl_id %in% table_eqtl$exposure,]
write.table(clingov_vs_ot_st7, "clingov_vs_ot_singleeqtl.tsv", sep="\t", quote=F, row.names=F)
#A slimmed table with just unique set of drug name, gene target name and condition
clingov_vs_ot_st7_slim <- clingov_vs_ot_st7 %>% select(drug, all_cond, g1.ensembl_id, g1.name) %>% distinct() %>% arrange(g1.name)
write.table(clingov_vs_ot_st7_slim, "clingov_vs_ot_singleeqtl_slim.tsv", sep="\t", quote=F, row.names=F)

#Map results to MR analysis via gene id - all empty results from CPIC.
clingov_vs_cpic_st7 <- clingov_vs_cpic[clingov_vs_cpic$g1.ensembl_id %in% table_eqtl$exposure,]
write.table(clingov_vs_cpic_st7, "clingov_vs_cpic_singleeqtl.tsv", sep="\t", quote=F, row.names=F)

#A slimmed table with just unique set of drug name, gene target name and condition
clingov_vs_cpic_st7_slim <- clingov_vs_cpic_st7 %>% select(drug, all_cond, g1.ensembl_id, g1.name) %>% distinct() %>% arrange(g1.name)
write.table(clingov_vs_cpic_st7_slim, "clingov_vs_cpic_singleeqtl_slim.tsv", sep="\t", quote=F, row.names=F)

#Read in matches between eQTLs and ClinicalTrials.Gov
matches <- read.delim("singleeqtl_selected.txt", sep="\t", header=T, stringsAsFactors=F, row.names=NULL, quote="")

#Filter to the matching targets
table_filt <- merge(table_eqtl, matches, by.x="exposure", by.y="ensg")

#Join Zheng et al. with Clingov trials table.
clingov_merged_table7 <- merge(table_filt, drugs_clingov2, by.x=c("drug", "condition"), by.y=c("drug", "all_cond"))
clingov_merged_table7 <- clingov_merged_table7 %>% distinct()
write.table(clingov_merged_table7, "clingov_singleeqtl_merged.txt", sep="\t", quote=F, row.names=F)

