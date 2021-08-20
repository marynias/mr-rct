library("DataExplorer")
library("dplyr")
library("ggplot2")
source("clingov_functions.R")

#Primary outcomes only
data <- read.delim("clingov_required_primary.tsv", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
glimpse(data)
#All outcomes
#all_req_data <- read.delim("clingov_required.tsv", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
#Table with studies with no results in the db but PMID with results
published <- read.delim("clingov_noresult.tsv", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")

introduce(data)
plot_intro(data)
plot_missing(data)
plot_bar(data)
plot_histogram(data)

#How many unique studies in the required info data set?
length(unique(data$nct_id))
#4,398

#How many unique studies in published?
length(unique(published$nct_id))
#11,613

#Outcomes table
outcome <- read.delim("outcome_add.tsv", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
outcome_primary <- outcome[outcome$outcome_type == "Primary",]
outcome_secondary <- outcome[outcome$outcome_type == "Secondary",]
primary_counts <- outcome_primary %>% count(nct_id)
secondary_counts <- outcome_secondary %>% count(nct_id)

ggplot(primary_counts, aes(n)) + geom_histogram(fill='darkblue') + scale_x_continuous(limits = c(0, 20)) + theme_Publication() + ggtitle("Number of primary outcomes per study")

ggplot(secondary_counts, aes(n)) + geom_histogram(fill='darkblue') + scale_x_continuous(limits = c(0, 40)) + theme_Publication() + ggtitle("Number of secondary outcomes per study")

#What are the top types of methods among our studies?
data %>% count(method) %>% arrange(desc(n))

#What are the top types of estimates among our studies?
data %>% count(param_type) %>% arrange(desc(n))

#Evaluate frequency of different intervention types
for_interv <- data %>% dplyr::select(nct_id, all_interv_types) %>% distinct()
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


number_nas <- function(x,y,z) {
	my_studies <- y[grepl(x, y$all_interv_types),]$nct_id
	rel <- z %>% select(nct_id, mesh_interv) %>% distinct() %>% filter(nct_id %in% my_studies)
	counts <- rel %>% count(mesh_interv) %>% arrange(desc(n))
	return(counts)
}

#For how many of the studies with Drug intervention, we have a Mesh intervention term mapped?
#How many we don't?
#Results
out <- number_nas("Drug", for_interv, data)
head(out)
# 682 NAs out of 3,514
#No-Results
out <- number_nas("Drug", for_interv2, published)
head(out)
# 808 Nas out of 5,190

#For how many of the studies with Behavioral intervention, we have a Mesh intervention term mapped?
#How many we don't?
#Results
out <- number_nas("Behavioral", for_interv, data)
head(out)
#272 out of 313

#No-Results
out <- number_nas("Behavioral", for_interv2, published)
head(out)
#1,178 out of 1,278

#For how many of the studies with Dietary Supplement intervention, we have a Mesh intervention term mapped?
#How many we don't?
#Results
out <- number_nas("Dietary Supplement", for_interv, data)
head(out)
#16 out of 43 studies
#No-Results
out <- number_nas("Dietary Supplement", for_interv2, published)
head(out)
#188 out of 306 studies


number_nas_cond <- function(x,y,z) {
	my_studies <- y[grepl(x, y$all_interv_types),]$nct_id
	rel <- z %>% select(nct_id, mesh_cond) %>% distinct() %>% filter(nct_id %in% my_studies)
	counts <- rel %>% count(mesh_cond) %>% arrange(desc(n))
	return(counts)
}

#For how many of the studies with Drug intervention, we have a Mesh intervention term mapped?
#How many we don't?
#Results
out <- number_nas_cond("Drug", for_interv, data)
head(out)
# 238 NAs out of 3,514
#No-Results
out <- number_nas_cond("Drug", for_interv2, published)
head(out)
# 463 Nas out of 5,190

#For how many of the studies with Behavioral intervention, we have a Mesh intervention term mapped?
#How many we don't?
#Results
out <- number_nas_cond("Behavioral", for_interv, data)
head(out)
#59 out of 313

#No-Results
out <- number_nas_cond("Behavioral", for_interv2, published)
head(out)
#254 out of 1,278

#For how many of the studies with Dietary Supplement intervention, we have a Mesh intervention term mapped?
#How many we don't?
#Results
out <- number_nas_cond("Dietary Supplement", for_interv, data)
head(out)
#2 out of 43 studies
#No-Results
out <- number_nas_cond("Dietary Supplement", for_interv2, published)
head(out)
#40 out of 306 studies