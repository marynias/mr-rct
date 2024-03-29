library("DataExplorer")
library("dplyr")
library("ggplot2")
library("patchwork")
library("ggpubr")
library("anytime")
library("lubridate")
library("reshape2")
source("clingov_functions.R")

#All outcomes
data_in <- read.delim("clingov_required.tsv", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
data <- data_in %>% dplyr::select(nct_id, all_interv_types, intervention_model, study_type, primary_purpose, allocation, overall_status, gender, phase, number_of_arms, mesh_interv, mesh_cond) %>% distinct()
completed_trials <- data_in[data_in$overall_status == "Completed",]
data_results <- data_in %>% dplyr::select(nct_id, all_interv_types, method, param_type, p_value, mesh_interv) %>% distinct()
#Table with studies with no results in the db but PMID with results
published_in <- read.delim("clingov_noresult.tsv", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
published <- published_in %>% dplyr::select(nct_id, all_interv_types, method, param_type, p_value, mesh_interv, mesh_cond           ) %>% distinct()

introduce(data)
plot_intro(data)
plot_missing(data)
plot_bar(data)
plot_histogram(data)

theme_set(theme_gray()+ theme(axis.line = element_line(size=0.5),panel.background = element_rect(fill=NA,size=rel(20)), panel.grid.minor = element_line(colour = NA), plot.title = element_text(size=16), axis.text = element_text(size=12), axis.title = element_text(size=14), strip.text.x = element_text(size = 16)))

data$title <- "Intervention model"
intervention <- ggplot(data, aes(intervention_model)) + geom_bar(fill='black', colour="black",  width=0.3) + coord_flip() + facet_grid(. ~ title) + xlab(element_blank()) + 
  scale_y_continuous(breaks=c(0, 3000, 6000, 9000, 12000), labels = scales::comma, expand=c(0,0)) + ylab("Study count")
ggsave("intervention_model.png", width=11, height=8, units=c("cm"), dpi=600, limitsize=F)
table(data$intervention_model)

data_temp <- data[!is.na(data$primary_purpose), ]
data_temp$primary_purpose <- factor(data_temp$primary_purpose, levels=rev(c("Treatment", "Prevention", "Supportive Care", "Other","Basic Science", "Health Services Research", "Diagnostic", "Screening" )))
data_temp$title <- "Primary purpose"
data_temp <- data_temp[!is.na(data_temp$primary_purpose), ]
purpose <- ggplot(data_temp, aes(primary_purpose)) + geom_bar(fill='black', colour="black",  width=0.5) +
  coord_flip() + facet_grid(. ~ title) + xlab(element_blank()) +  
  scale_y_continuous(breaks=c(0,2500,5000,7500,10000), labels = scales::comma, expand=c(0,0)) + ylab("Study count")
ggsave("primary_purpose.png", width=11, height=8, units=c("cm"), dpi=600, limitsize=F)
table(data_temp$primary_purpose)

data_temp <- data[!is.na(data$overall_status), ]
data_temp$overall_status <- factor(data_temp$overall_status, levels=rev(c("Completed", "Terminated", "Active, not recruiting", "Unknown status", "Recruiting")))
data$title <- "Trial status"
status <- ggplot(data_temp, aes(overall_status)) + geom_bar(fill='black', colour="black",  width=0.5) +
coord_flip() + facet_grid(. ~ title) + xlab(element_blank()) +  
  scale_y_continuous(breaks=c(0, 3000, 6000, 9000, 12000), labels = scales::comma, expand=c(0,0)) + ylab("Study count")
ggsave("trial_status.png", width=11, height=8, units=c("cm"), dpi=600, limitsize=F)
table(data_temp$overall_status)

data$gender <- factor(data$gender, levels=rev(c("All", "Female", "Male")))
data$title <- "Gender"
gender <- ggplot(data, aes(gender)) + geom_bar(fill='black', colour="black",  width=0.4) +
coord_flip() + facet_grid(. ~ title) + xlab(element_blank()) +  
scale_y_continuous(breaks=c(0, 3000, 6000, 9000, 12000), labels = scales::comma, expand=c(0,0)) + ylab("Study count")
ggsave("gender.png", width=11, height=8, units=c("cm"), dpi=600, limitsize=F)
table(data$gender)

data_temp <- data[!is.na(data$phase), ]
data_temp$phase <- factor(data$phase, levels=rev(c("Phase 3", "Phase 2", "Not Applicable", "Phase 4" , "Phase 1", "Phase 2/Phase 3", "Phase 1/Phase 2", "Early Phase 1")))
data_temp$title <- "Trial phase"
phase <- ggplot(data_temp, aes(phase)) + geom_bar(fill='black', colour="black",  width=0.5) + 
coord_flip() + facet_grid(. ~ title) + xlab(element_blank()) +  
scale_y_continuous(labels = scales::comma, expand=c(0,0)) + ylab("Study count")
ggsave("trial_phase.png", width=11, height=8, units=c("cm"), dpi=600, limitsize=F)
table(data_temp$phase)


data$title <- "Number of arms"
number_arms <- ggplot(data, aes(number_of_arms)) + geom_bar(fill='black', colour="black",  width=0.5) + facet_grid(. ~ title) + xlab(element_blank()) +  scale_y_continuous(labels = scales::comma, expand=c(0,0)) +  scale_x_continuous(limits = c(0, 15)) + ylab("Study count") + coord_flip() + scale_x_reverse(limits = c(15, 0))
ggsave("arms.png", width=11, height=8, units=c("cm"), dpi=600, limitsize=F)
summary(data$number_of_arms)

(intervention | purpose ) / (status | phase) / (gender | number_arms )

ggarrange(intervention, purpose, status, phase, gender, number_arms, ncol = 2, nrow = 3)

#Outcomes table
outcome <- read.delim("outcome_add.tsv", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
outcome_primary <- outcome[outcome$outcome_type == "Primary",]
outcome_secondary <- outcome[outcome$outcome_type == "Secondary",]
primary_counts <- outcome_primary %>% count(nct_id)
secondary_counts <- outcome_secondary %>% count(nct_id)

primary <- ggplot(primary_counts, aes(n)) + geom_histogram(fill='darkblue', colour="black") + scale_x_continuous(limits = c(0, 20)) +  scale_y_continuous(labels = scales::comma, expand=c(0,0)) + xlab("Primary outcomes") + ylab("Study count")
ggtitle("Number of primary outcomes per study") 
ggsave("primary_outcomes.png", width=10, height=8, units=c("cm"), dpi=600, limitsize=F)

summary(primary_counts)

secondary <- ggplot(secondary_counts, aes(n)) + geom_histogram(fill='darkblue', colour="black") + scale_x_continuous(limits = c(0, 40)) +  scale_y_continuous(labels = scales::comma, expand=c(0,0)) + xlab("Secondary outcomes") + ylab("Study count")
ggtitle("Number of secondary outcomes per study")
ggsave("secondary_outcomes.png", width=10, height=8, units=c("cm"), dpi=600, limitsize=F)

summary(secondary_counts)

#Distribution of p-values
data_results$p_value <- as.numeric(data_results$p_value)
data_results_plot <- data_results %>% dplyr::filter(p_value <= 1) %>% dplyr::filter( p_value >= 0)
pvalues <- ggplot(data_results_plot, aes(p_value)) + 
geom_histogram(fill='darkblue', colour="black") + 
scale_y_continuous(labels = scales::comma, expand=c(0,0)) + xlab("P-value") + ylab("Result count")

ggtitle("P-value distribution")
ggsave("p-values.png", width=10, height=8, units=c("cm"), dpi=600, limitsize=F)
summary(data_results_plot$p_value)

zeroes <- data_results[data_results$p_value < 0.05,]

primary + secondary + pvalues

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
# 2,212 NAs out of 11,537
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

#Same but for condition MeSH terms
count_nas2 <- function(x,y,z) {
  my_studies <- y[grepl(x, y$all_interv_types),]$nct_id
  rel <- z %>% select(nct_id, mesh_cond) %>% distinct() %>% filter(nct_id %in% my_studies)
  counts <- rel %>% count(mesh_cond) %>% arrange(desc(n))
}
out <- count_nas2("Drug", for_interv, data)#No-Results
out <- count_nas2("Drug", for_interv2, published)
#For how many of the studies with Behavioral intervention, we have a Mesh intervention term mapped?
#How many we don't?
out <- count_nas2("Behavioral", for_interv, data)
out <- count_nas2("Behavioral", for_interv2, published)
#For how many of the studies with Dietary Supplement intervention, we have a Mesh intervention term mapped?
#How many we don't?
out <- count_nas2("Dietary Supplement", for_interv, data)
out <- count_nas2("Dietary Supplement", for_interv2, published)


#Load a list of identifiers with all RCTs in ClinGov database (taken from clingov_non_required.tsv file).
nct_ids <- read.delim("RCT_ids.txt", header=F)
#Load a list of identifiers with all completed RCTs in ClinGov database (taken from clingov_non_required.tsv file).
nct_ids_comp <- read.delim("RCT_ids_comp.txt", header=F)
#Study table with data details.
study_ext <- read.delim("studies_ext.txt", stringsAsFactors = F, na.strings="")

#Subset study_ext to all RCTs
study_ext_all <- study_ext[study_ext$nct_id %in% nct_ids$V1,]
#Subset study_ext to all completed RCTs
study_ext_all_comp <- study_ext[study_ext$nct_id %in% nct_ids_comp$V1,]
#Subset study_ext to RCTs with results.
study_ext_results <- study_ext[study_ext$nct_id %in% data$nct_id,]
#Subset study_ext to RCTs with results = only completed trials.
study_ext_results_comp <- study_ext[study_ext$nct_id %in% completed_trials$nct_id,]

#Look at the date fields, and check which ones have most missing data.
#317
dim(study_ext_all[is.na(study_ext_all$start_date),])
#3720
dim(study_ext_all[is.na(study_ext_all$completion_date),])
#0
dim(study_ext_all[is.na(study_ext_all$study_first_submitted_date),])
#136490     
dim(study_ext_all[is.na(study_ext_all$results_first_submitted_date),])
#317
dim(study_ext_all[is.na(study_ext_all$start_month_year),])
#3720
dim(study_ext_all[is.na(study_ext_all$completion_month_year),])

#Use start date
study_ext_all$date <- anytime::anydate(study_ext_all$start_date)
#Remove NAs
study_ext_all <- study_ext_all[!is.na(study_ext_all$date),]
#The earliest study start year is 1966.
min(study_ext_all$date)
study_ext_all$year <- year(study_ext_all$date)
study_all_year <- study_ext_all %>% count(year)
#How many RCTs before 2000
study_all_year %>% filter(year < 2000) %>% summarise(Total = sum(n)) 

##Same but for RCTs with results.
#Use start date
study_ext_results$date <- anytime::anydate(study_ext_results$start_date)
#Remove NAs
study_ext_results <- study_ext_results[!is.na(study_ext_results$date),]
#The earliest study start year is 1966.
min(study_ext_results$date)
study_ext_results$year <- year(study_ext_results$date)
study_results_year <- study_ext_results %>% count(year)
#How many RCTs before 2000
study_results_year %>% filter(year < 2000) %>% summarise(Total = sum(n)) 

#How many RCTs before 2012
study_results_year %>% filter(year < 2012) %>% summarise(Total = sum(n)) 

##Subsetting to only completed trials.
study_ext_results_comp$date <- anytime::anydate(study_ext_results_comp$start_date)
#Remove NAs
study_ext_results_comp <- study_ext_results_comp[!is.na(study_ext_results_comp$date),]
median(year(study_ext_results$date))
median(year(study_ext_results_comp$date))
study_ext_all_comp$date <- anytime::anydate(study_ext_all_comp$start_date)
#Remove NAs
study_ext_all_comp <- study_ext_all_comp[!is.na(study_ext_all_comp$date),]
#Mark the completed RCTs with results available
study_ext_all_comp$results <- ifelse(study_ext_all_comp$nct_id %in% study_ext_results_comp$nct_id, "yes", "no")
study_ext_all_comp$year <- year(study_ext_all_comp$date)

study_ext_all_comp2 <- study_ext_all_comp %>% group_by(results) %>% count(year)
study_ext_all_comp3 = melt(study_ext_all_comp2, id=c("year", "results"))
study_ext_all_comp3$results <- as.factor(study_ext_all_comp3$results)

ggplot(study_ext_all_comp3, aes(x=year, y=value, group=results, fill=results)) + 
  geom_bar(position="stack", stat="identity", colour="black", size=0.2) +
  xlab('') +
  ylab("Number of RCTs") +
  scale_x_continuous(breaks = c(1980, 1990, 2000, 2010, 2020)) +
  scale_y_continuous() +
  theme_Publication() +
  theme(axis.text.x = element_text(
    colour = 'black', angle = 90, size = 13,
    hjust = 0.5, vjust = 0.5)) 


ggplot(study_ext_all_comp3, aes(x=year, y=value, group=results, fill=results, colour=results)) + 
  geom_bar(position="fill", stat="identity") +
  xlab('') +
  ylab("Fraction of RCTs") + 
  scale_x_continuous(breaks = c(1980, 1990, 2000, 2010, 2020)) +
  scale_y_continuous() +
  theme_Publication() +
  theme(axis.text.x = element_text(
    colour = 'black', angle = 90, size = 13,
    hjust = 0.5, vjust = 0.5)) 

