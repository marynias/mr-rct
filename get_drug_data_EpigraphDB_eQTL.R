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


#Load data from DGIDb.
dgidb <- read.delim("dgidb_interactions.tsv", sep="\t", header=T, stringsAsFactors=F, row.names=NULL, quote="")
#Convert drug names to uppercase
dgidb$drug_name <- toupper(dgidb$drug_name)
dgidb$drug_claim_primary_name <- toupper(dgidb$drug_claim_primary_name)
dgidb$drug_claim_name <- toupper(dgidb$drug_claim_name)

#Load in data from Clinical trials.
clingov <- read.delim("clingov_required_primary.tsv", sep="\t", header=T, stringsAsFactors=F, row.names=NULL, quote="")
#Find only studies with drugs as intervention.
drugs_clingov <- clingov[grepl("Drug", clingov$all_interv_types),]

drugs_clingov2 <- drugs_clingov %>% mutate(drug = strsplit(mesh_interv, "\\|")) %>% tidyr::unnest(drug)
drugs_clingov2$drug <- toupper(drugs_clingov2$drug)

#Load data from Zheng et al. STable 7: MR evidence supported by coloc.
table7 <- read.delim("Zheng2020_ST7.tsv", sep="\t", header=T, stringsAsFactors=F, row.names=NULL, quote="")

#Load data from Zheng et al. STable 8: MR evidence not supported by coloc.
table8 <- read.delim("Zheng2020_ST8.tsv", sep="\t", header=T, stringsAsFactors=F, row.names=NULL, quote="")

#Map ClinGov drugs to genes via OT
clingov_vs_ot <- merge(drugs_clingov2, results, by.x="drug", by.y="d1.label")

#Map ClinGov drugs to genes via CPIC
clingov_vs_cpic <- merge(drugs_clingov2, results2, by.x="drug", by.y="d1.label")

#Map ClinGov drugs to genes via DGIDb.
clingov_vs_dgidb <- merge(drugs_clingov2, dgidb, by.x="drug", by.y="drug_claim_primary_name")
#Eliminate rows with empty gene name
clingov_vs_dgidb <- clingov_vs_dgidb[!(is.na(clingov_vs_dgidb$gene_name) | clingov_vs_dgidb$gene_name==""), ]

#Map results to MR analysis via gene id.
clingov_vs_ot_st7 <- clingov_vs_ot[clingov_vs_ot$g1.ensembl_id %in% table7$ENSEMBL,]
write.table(clingov_vs_ot_st7, "clingov_vs_ot_st7.tsv", sep="\t", quote=F, row.names=F)
#A slimmed table with just unique set of drug name, gene target name and condition
clingov_vs_ot_st7_slim <- clingov_vs_ot_st7 %>% select(drug, all_cond, g1.ensembl_id, g1.name) %>% distinct()
write.table(clingov_vs_ot_st7_slim, "clingov_vs_ot_st7_slim.tsv", sep="\t", quote=F, row.names=F)
clingov_vs_ot_st8 <- clingov_vs_ot[clingov_vs_ot$g1.ensembl_id %in% table8$ENSEMBL,]
write.table(clingov_vs_ot_st8, "clingov_vs_ot_st8.tsv", sep="\t", quote=F, row.names=F)
#A slimmed table with just unique set of drug name, gene target name and condition
clingov_vs_ot_st8_slim <- clingov_vs_ot_st8 %>% select(drug, all_cond, g1.ensembl_id, g1.name) %>% distinct()
write.table(clingov_vs_ot_st8_slim, "clingov_vs_ot_st8_slim.tsv", sep="\t", quote=F, row.names=F)

#Map results to MR analysis via gene id - all empty results from CPIC.
clingov_vs_cpic_st7 <- clingov_vs_cpic[clingov_vs_cpic$g1.ensembl_id %in% table7$ENSEMBL,]
clingov_vs_cpic_st8 <- clingov_vs_cpic[clingov_vs_cpic$g1.ensembl_id %in% table8$ENSEMBL,]


clingov_vs_dgidb_st7 <- clingov_vs_dgidb[clingov_vs_dgidb$gene_name %in% table7$Exposure,]
write.table(clingov_vs_dgidb_st7, "clingov_vs_dgidb_st7.tsv", sep="\t", quote=F, row.names=F)

#A slimmed down version
clingov_vs_dgidb_st7_slim <- clingov_vs_dgidb_st7 %>% select(drug, all_cond, gene_name) %>% distinct()
write.table(clingov_vs_dgidb_st7_slim, "clingov_vs_dgidb_st7_slim.tsv", sep="\t", quote=F, row.names=F)

clingov_vs_dgidb_st8 <- clingov_vs_dgidb[clingov_vs_dgidb$gene_name %in% table8$Exposure,]
write.table(clingov_vs_dgidb_st8, "clingov_vs_dgidb_st8.tsv", sep="\t", quote=F, row.names=F)

#A slimmed down version
clingov_vs_dgidb_st8_slim <- clingov_vs_dgidb_st8 %>% select(drug, all_cond, gene_name) %>% distinct()
write.table(clingov_vs_dgidb_st8_slim, "clingov_vs_dgidb_st8_slim.tsv", sep="\t", quote=F, row.names=F)

#Read in a file with matching conditions and genes from ClinGov trials for ST7 from Zheng et al. 2020
st7_matches <- read.delim("ST7_selected.txt", sep="\t", header=T, stringsAsFactors=F, row.names=NULL, quote="")

#Read in a file with matching conditions and genes from ClinGov trials for ST8 from Zheng et al. 2020
st8_matches <- read.delim("ST8_selected.txt", sep="\t", header=T, stringsAsFactors=F, row.names=NULL, quote="")

#Filter ST7 to the matching targets
table7_filt <- merge(table7, st7_matches, by.x="Exposure", by.y="target")

#Filter ST8 to the matching targets
table8_filt <- merge(table8, st8_matches, by.x="Exposure", by.y="target")

#Join Zheng et al. with Clingov trials table.
clingov_merged_table7 <- merge(table7_filt, drugs_clingov2, by.x=c("drug", "condition"), by.y=c("drug", "all_cond"))
clingov_merged_table7 <- clingov_merged_table7 %>% distinct()
write.table(clingov_merged_table7, "clingov_st7_merged.txt", sep="\t", quote=F, row.names=F)

#Join Zheng et al. with Clingov trials table.
clingov_merged_table8 <- merge(table8_filt, drugs_clingov2, by.x=c("drug", "condition"), by.y=c("drug", "all_cond"))
clingov_merged_table8 <- clingov_merged_table8 %>% distinct()
write.table(clingov_merged_table8, "clingov_st8_merged.txt", sep="\t", quote=F, row.names=F)
