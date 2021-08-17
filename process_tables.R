###Process ClinGov tables
library(dplyr)
library(stringr)

#Rows: 105,790
outcome_analyses <- read.delim("outcome_analyses.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
outcomes <- read.delim("outcomes.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
brief_sum <- read.delim("brief_summaries.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
all_cond <- read.delim("all_conditions.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
all_interv <- read.delim("all_interventions.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
all_interv_types <- read.delim("all_intervention_types.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
cond <- read.delim("conditions.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
interv <- read.delim("interventions.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
design_g <- read.delim("design_groups.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
design <- read.delim("designs.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
elig <- read.delim("eligibilities.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
result_g <- read.delim("result_groups.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
studies <- read.delim("studies.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
study_ref <- read.delim("study_references.txt", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")

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

interv$intervention.description <- clean_data(interv$intervention.description)
outcomes$outcome.description <- clean_data(outcomes$outcome.description)
outcomes$outcome.population <- clean_data(outcomes$outcome.population)
result_g$result_group.description <- clean_data(result_g$result_group.description)


#Table with required data
#Rows: 105,790
required_res <- merge(outcome_analyses[c("nct_id", "outcome_id", "param_type", "param_value", "dispersion_type", "dispersion_value", "ci_lower_limit", "ci_upper_limit", "ci_percent", "p_value", "method")], brief_sum, by="nct_id")
#Rows: 105,790
required_res2 <- merge(required_res, all_cond, by="nct_id")
#Rows: 105,790
required_res3 <- merge(required_res2, all_interv, by="nct_id", all.x=T)
#Rows: 94,704
required_res4 <- merge(required_res3, design, by="nct_id")
#Rows: 94,704
required_res5 <- merge(required_res4, all_interv_types, by="nct_id")
#Rows: 94,704
required_res6 <- merge(required_res5, elig[c("nct_id", "gender", "criteria")], by="nct_id")
#Rows: 94,152
required_res7 <- merge(required_res6, studies[c("nct_id", "brief_title", "study_type", "overall_status", "phase", "number_of_arms", "enrollment")], by="nct_id")
required_res7 <- required_res7 %>% dplyr::select(nct_id, outcome_id, all_interv, all_interv_types, all_cond, intervention_model, study_type, primary_purpose, allocation, brief_title, number_of_arms, param_type, param_value, p_value, method, ci_lower_limit, ci_upper_limit, ci_percent, dispersion_type, dispersion_value, gender, enrollment, overall_status, phase, criteria, description)
write.table(required_res7, "clingov_required.tsv", sep="\t", quote=F, row.names=F)

#Table with additional data.
#Rows: 7,478
all_studies <- data.frame(nct_id=unique(required_res7$nct_id))
all_studies <- merge(all_studies, elig[c("nct_id", "minimum_age", "maximum_age")], by="nct_id", all.x=T)
#Rows: 20,111
addit_res <- merge(all_studies, design_g, by="nct_id", all.x=T)
write.table(addit_res, "design_groups_add.tsv", sep="\t", quote=F, row.names=F)

#Rows: 300,218
addit_res2 <- merge(all_studies, result_g, by="nct_id", all.x=T)
write.table(addit_res2, "result_groups_add.tsv", sep="\t", quote=F, row.names=F)

#Rows: 26,410
addit_res3 <- merge(all_studies, study_ref, by="nct_id", all.x=T)
write.table(addit_res3, "study_ref_add.tsv", sep="\t", quote=F, row.names=F)

#Rows: 20,709
addit_res4 <- merge(all_studies, interv[c("nct_id", "intervention.description")], by="nct_id", all.x=T)
write.table(addit_res4, "interv_add.tsv", sep="\t", quote=F, row.names=F)

outcome_analyses_slim <- outcome_analyses %>% dplyr::select(nct_id, groups_description, method_description, estimate_description) %>% distinct()
#Rows: 37,419
addit_res5 <- merge(all_studies, outcome_analyses_slim, by="nct_id", all.x=T)
write.table(addit_res5, "outcome_analyses_add.tsv", sep="\t", quote=F, row.names=F)

#Rows: 87,636
addit_res6 <- merge(all_studies, outcomes, by="nct_id", all.x=T)
write.table(addit_res6, "outcome_add.tsv", sep="\t", quote=F, row.names=F)

addit_res7 <- merge(all_studies, studies[c("nct_id", "baseline_population", "official_title", "limitations_and_caveats")], by="nct_id", all.x=T)
write.table(addit_res7, "studies_add.tsv", sep="\t", quote=F, row.names=F)


