library("DataExplorer")
library("dplyr")
library("ggplot2")
source("clingov_functions.R")

#Primary outcomes only
data <- read.delim("clingov_data_all_primary.csv", header=T, stringsAsFactors=F, row.names=NULL, sep=",")
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
  temp <- dim(for_interv[grepl(i, for_interv2$all_interv_types),])[1]
  print(temp)
}


