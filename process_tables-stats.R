###Process ClinGov tables
library(dplyr)
library(stringr)

#Rows: 105,790
outcome_analyses <- read.delim("outcome_analyses.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
outcomes <- read.delim("outcomes.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
brief_sum <- read.delim("brief_summaries.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
all_cond <- read.delim("all_conditions.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
all_interv <- read.delim("all_interventions.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
all_interv_types <- read.delim("all_intervention_types.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
cond <- read.delim("conditions.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
interv <- read.delim("interventions.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
design_g <- read.delim("design_groups.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
design <- read.delim("designs.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
elig <- read.delim("eligibilities.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
result_g <- read.delim("result_groups.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
studies <- read.delim("studies.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
study_ref <- read.delim("study_references.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
previously_filtered <- read.delim("shared_designs_studies.txt", header=F, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
colnames(previously_filtered) <- c("nct_id")

mesh_cond <- read.delim("mesh-conditions.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
mesh_interv <- read.delim("mesh-interventions.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
#Create tables with all mesh terms (condition and intervention) associated with a given study id.
mesh_cond_all <- mesh_cond %>% dplyr::select(nct_id, downcase_mesh_term) %>% group_by(nct_id) %>% mutate(mesh_cond= paste0(downcase_mesh_term, collapse = "|")) %>% dplyr::select(nct_id, mesh_cond) %>% distinct()
mesh_interv_all <- mesh_interv %>% dplyr::select(nct_id, downcase_mesh_term) %>% group_by(nct_id) %>% mutate(mesh_interv= paste0(downcase_mesh_term, collapse = "|")) %>% dplyr::select(nct_id, mesh_interv) %>% distinct()

#Clean data
clean_data <- function(x) {
	x <- gsub("\n", "", x)
	x  <- str_trim(x)
	x <- str_squish(x)
	x
}

brief_sum$description <- clean_data(brief_sum$description)
elig$criteria <- clean_data(elig$criteria)

colnames(all_cond) <- c("nct_id", "all_cond")
colnames(all_interv) <- c("nct_id", "all_interv")
colnames(all_interv_types) <- c("nct_id", "all_interv_types")
colnames(interv) <- c("nct_id", "intervention.name", "intervention.description", "intervention_type")
colnames(cond) <- c("nct_id", "condition.name")
colnames(design_g) <- c("nct_id", "group_type", "design_group.title", "design_group.description")
colnames(result_g) <- c("nct_id", "group_type", "result_group.title", "result_group.description")
colnames(outcomes) <- c("nct_id", "outcome_id", "outcome_type", "outcome.title", "outcome.description", "outcome.time_frame", "outcome.population", "outcome.units")
colnames(outcome_analyses)[1] <- "outcome_analyses.id"

interv$intervention.description <- clean_data(interv$intervention.description)
outcomes$outcome.description <- clean_data(outcomes$outcome.description)
outcomes$outcome.population <- clean_data(outcomes$outcome.population)
result_g$result_group.description <- clean_data(result_g$result_group.description)


#Table with required data
#Rows: 106,034
required_res0 <- merge(previously_filtered, brief_sum, by="nct_id")
required_res <- merge(outcome_analyses[c( "outcome_analyses.id", "nct_id", "outcome_id", "param_type", "param_value", "dispersion_type", "dispersion_value", "ci_lower_limit", "ci_upper_limit", "ci_percent", "p_value", "method")], required_res0, by="nct_id")
#Rows: 106,034
required_res2 <- merge(required_res, all_cond, by="nct_id")
#Rows: 106,034
required_res3 <- merge(required_res2, all_interv, by="nct_id", all.x=T)
#Rows: 94,936
required_res4 <- merge(required_res3, design, by="nct_id")
#Rows: 94,936
required_res5 <- merge(required_res4, all_interv_types, by="nct_id")
#Rows: 94,936
required_res6 <- merge(required_res5, elig[c("nct_id", "gender", "criteria")], by="nct_id")
#Rows: 94,384
required_res7 <- merge(required_res6, studies[c("nct_id", "brief_title", "study_type", "overall_status", "phase", "number_of_arms", "enrollment")], by="nct_id")
#Rows: 94,384
required_res8 <- merge(required_res7, mesh_cond_all, by="nct_id", all.x=T)
#Rows: 94,384
required_res9 <- merge(required_res8, mesh_interv_all, by="nct_id", all.x=T)
#Rows: 94,175
required_res10 <- merge(required_res9, outcomes[c("nct_id", "outcome_id", "outcome.title")], by=c("nct_id", "outcome_id"))
required_res10 <- required_res10 %>% dplyr::select(nct_id, outcome_analyses.id, outcome_id, outcome.title, mesh_interv, all_interv, all_interv_types, mesh_cond, all_cond, intervention_model, study_type, primary_purpose, allocation, brief_title, number_of_arms, param_type, param_value, p_value, method, ci_lower_limit, ci_upper_limit, ci_percent, dispersion_type, dispersion_value, gender, enrollment, overall_status, phase, criteria, description)
write.table(required_res10, "clingov_required.tsv", sep="\t", quote=F, row.names=F)

#Filtered down to only primary outcomes.
primary_outcomes <- outcomes[outcomes$outcome_type == "Primary",]
required_res11 <- required_res10[required_res10$outcome_id %in% primary_outcomes$outcome_id,]
write.table(required_res11, "clingov_required_primary.tsv", sep="\t", quote=F, row.names=F)

#Table with additional data.
#Rows: 7,485
all_studies <- data.frame(nct_id=unique(required_res7$nct_id))
all_studies <- merge(all_studies, elig[c("nct_id", "minimum_age", "maximum_age")], by="nct_id", all.x=T)
#Rows: 20,132
addit_res <- merge(all_studies, design_g, by="nct_id", all.x=T)
write.table(addit_res, "design_groups_add.tsv", sep="\t", quote=F, row.names=F)

#Rows: 300,594
addit_res2 <- merge(all_studies, result_g, by="nct_id", all.x=T)
write.table(addit_res2, "result_groups_add.tsv", sep="\t", quote=F, row.names=F)

#Rows: 26,596
addit_res3 <- merge(all_studies, study_ref, by="nct_id", all.x=T)
write.table(addit_res3, "study_ref_add.tsv", sep="\t", quote=F, row.names=F)

#Rows: 20,726
addit_res4 <- merge(all_studies, interv[c("nct_id", "intervention.description")], by="nct_id", all.x=T)
write.table(addit_res4, "interv_add.tsv", sep="\t", quote=F, row.names=F)

outcome_analyses_slim <- outcome_analyses %>% dplyr::select(outcome_analyses.id, outcome_id, nct_id, non_inferiority_type, non_inferiority_description, ci_n_sides, p_value_modifier, p_value_description, groups_description, method_description, estimate_description, other_analysis_description) %>% distinct()
#Rows: 94,384
addit_res5 <- merge(all_studies, outcome_analyses_slim, by="nct_id", all.x=T)
write.table(addit_res5, "outcome_analyses_add.tsv", sep="\t", quote=F, row.names=F)

#Rows: 87,717
addit_res6 <- merge(all_studies, outcomes, by="nct_id", all.x=T)
write.table(addit_res6, "outcome_add.tsv", sep="\t", quote=F, row.names=F)

addit_res7 <- merge(all_studies, studies[c("nct_id", "baseline_population", "official_title", "limitations_and_caveats")], by="nct_id", all.x=T)
write.table(addit_res7, "studies_add.tsv", sep="\t", quote=F, row.names=F)

##Find studies which do not have outcome analyses in the db but are interventional and have been published in a journal. Extract details about the publication.
"%ni%" <- Negate("%in%")
filtered_ref <- study_ref[study_ref$reference_type %in% c("result"),]
filtered_ref <- filtered_ref[filtered_ref$nct_id %ni% required_res10$nct_id,]

#All published pmid Ids in one row.
#24,098 studies linked to a PMID results publication which do not have results stored in ClinGov database
filtered_ref_lined <- filtered_ref %>% dplyr::select(nct_id, pmid, citation) %>% group_by(nct_id) %>% mutate(all_pmids= paste0(pmid, collapse = "|")) %>% mutate(all_cit= paste0(citation, collapse = "|")) %>% dplyr::select(nct_id, all_pmids, all_cit) %>% distinct()

#Fetch data about studies in this category
merged_published1 <- merge(filtered_ref_lined, brief_sum, by="nct_id", all.x=T)
merged_published2 <- merge(outcome_analyses[c( "outcome_analyses.id", "nct_id", "outcome_id", "param_type", "param_value", "dispersion_type", "dispersion_value", "ci_lower_limit", "ci_upper_limit", "ci_percent", "p_value", "method")], merged_published1, by="nct_id", all.y=T)
merged_published3 <- merge(merged_published2, all_cond, by="nct_id", all.x=T)
merged_published4 <- merge(merged_published3, all_interv, by="nct_id", all.x=T)
merged_published5 <- merge(merged_published4, design, by="nct_id", all.x=T)
merged_published6 <- merge(merged_published5, all_interv_types, by="nct_id", all.x=T)
merged_published7 <- merge(merged_published6, elig[c("nct_id", "gender", "criteria")], by="nct_id", all.x=T)
merged_published8 <- merge(merged_published7, studies[c("nct_id", "brief_title", "study_type", "overall_status", "phase", "number_of_arms", "enrollment")], by="nct_id", all.x=T)
merged_published9 <- merge(merged_published8, mesh_cond_all, by="nct_id", all.x=T)
#Rows: 94,152
merged_published10 <- merge(merged_published9, mesh_interv_all, by="nct_id", all.x=T)
#Rows: 94,114
merged_published10 <- merge(merged_published10, outcomes[c("nct_id", "outcome_id", "outcome.title")], by=c("nct_id", "outcome_id"), all.x=T)
merged_published10 <- merged_published10 %>% dplyr::select(nct_id, outcome_analyses.id, outcome_id, outcome.title, mesh_interv, all_interv, all_interv_types, mesh_cond, all_cond, intervention_model, study_type, primary_purpose, allocation, brief_title, number_of_arms, all_cit, all_pmids, param_type, param_value, p_value, method, ci_lower_limit, ci_upper_limit, ci_percent, dispersion_type, dispersion_value, gender, enrollment, overall_status, phase, criteria, description)
write.table(merged_published10, "clingov_noresult.tsv", sep="\t", quote=F, row.names=F)
