library("DataExplorer")
library("dplyr")
library("ggplot2")
source("clingov_functions.R")

#Primary outcomes only
data <- read.delim("clingov_data_all_primary.csv", header=T, stringsAsFactors=F, row.names=NULL, sep=",")
glimpse(data)
#All outcomes
#all_req_data <- read.delim("clingov_required.tsv", header=T, stringsAsFactors=F, row.names=NULL, sep="\t")
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

