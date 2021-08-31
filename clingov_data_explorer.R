library("DataExplorer")
library("dplyr")
library("ggplot2")
source("clingov_functions.R")

#Primary outcomes only
data_in <- read.delim("clingov_required_primary.tsv", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
data <- data_in %>% dplyr::select(nct_id, all_interv_types, intervention_model, study_type, primary_purpose, allocation, overall_status, gender, phase, number_of_arms, mesh_interv) %>% distinct()
data_results <- data_in %>% dplyr::select(nct_id, all_interv_types, method, param_type, p_value, mesh_interv) %>% distinct()
#All outcomes
#all_req_data <- read.delim("clingov_required.tsv", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
#Table with studies with no results in the db but PMID with results
published_in <- read.delim("clingov_noresult.tsv", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
published <- published_in %>% dplyr::select(nct_id, all_interv_types, method, param_type, p_value, mesh_interv) %>% distinct()
introduce(data)
plot_intro(data)
plot_missing(data)
plot_bar(data)
plot_histogram(data)

#Outcomes table
outcome <- read.delim("outcome_add.tsv", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
outcome_primary <- outcome[outcome$outcome_type == "Primary",]
outcome_secondary <- outcome[outcome$outcome_type == "Secondary",]
primary_counts <- outcome_primary %>% count(nct_id)
secondary_counts <- outcome_secondary %>% count(nct_id)

ggplot(primary_counts, aes(n)) + geom_histogram(fill='darkblue') + scale_x_continuous(limits = c(0, 20)) + theme_Publication() + ggtitle("Number of primary outcomes per study")

ggplot(secondary_counts, aes(n)) + geom_histogram(fill='darkblue') + scale_x_continuous(limits = c(0, 40)) + theme_Publication() + ggtitle("Number of secondary outcomes per study")
#Distribution of p-values
ggplot(data_results, aes(p_value)) + geom_histogram(fill='darkblue') + scale_x_continuous(limits = c(0, 1)) + scale_y_continuous(limits = c(0, 1800))+ theme_Publication() + ggtitle("P-value distribution")

#What are the top types of methods among our studies?
data_results %>% count(method) %>% arrange(desc(n))

#What are the top types of estimates among our studies?
data_results %>% count(param_type) %>% arrange(desc(n))

#Evaluate frequency of different intervention types
for_interv <- data_results %>% dplyr::select(nct_id, all_interv_types) %>% distinct()
interv_types <- c("Drug", "Other", "Biological", "Behavioral", "Device", "Procedure", "Dietary Supplement", "Radiation", "Diagnostic Test", "Genetic", "Combination Product")
for (i in interv_types) {
  print(i)
  temp <- dim(for_interv[grepl(i, for_interv$all_interv_types),])[1]
  print(temp)
}
for_interv2 <- published %>% dplyr::select(nct_id, all_interv_types) %>% distinct()
for (i in interv_types) {
  print(i)
  temp <- dim(for_interv2[grepl(i, for_interv2$all_interv_types),])[1]
  print(temp)
}

#For how many of the studies with Drug intervention, we have a Mesh intervention term mapped?
#How many we don't?
#Results
count_nas <- function(x,y,z) {
  my_studies <- y[grepl(x, y$all_interv_types),]$nct_id
  rel <- z %>% select(nct_id, mesh_interv) %>% distinct() %>% filter(nct_id %in% my_studies)
  counts <- rel %>% count(mesh_interv) %>% arrange(desc(n))
}

out <- count_nas("Drug", for_interv, data)
# 1,064 NAs out of 5,527
#No-Results
out <- count_nas("Drug", for_interv2, published)
#For how many of the studies with Behavioral intervention, we have a Mesh intervention term mapped?
#How many we don't?
out <- count_nas("Behavioral", for_interv, data)
out <- count_nas("Behavioral", for_interv2, published)
#For how many of the studies with Dietary Supplement intervention, we have a Mesh intervention term mapped?
#How many we don't?
out <- count_nas("Dietary Supplement", for_interv, data)
out <- count_nas("Dietary Supplement", for_interv2, published)
