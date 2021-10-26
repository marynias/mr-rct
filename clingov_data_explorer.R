library("DataExplorer")
library("dplyr")
library("ggplot2")
library("patchwork")
library("ggpubr")
source("clingov_functions.R")

#All outcomes
data_in <- read.delim("clingov_required.tsv", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
data <- data_in %>% dplyr::select(nct_id, all_interv_types, intervention_model, study_type, primary_purpose, allocation, overall_status, gender, phase, number_of_arms, mesh_interv) %>% distinct()
data_results <- data_in %>% dplyr::select(nct_id, all_interv_types, method, param_type, p_value, mesh_interv) %>% distinct()
#Table with studies with no results in the db but PMID with results
published_in <- read.delim("clingov_noresult.tsv", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
published <- published_in %>% dplyr::select(nct_id, all_interv_types, method, param_type, p_value, mesh_interv) %>% distinct()

introduce(data)
plot_intro(data)
plot_missing(data)
plot_bar(data)
plot_histogram(data)

theme_set(theme_gray()+ theme(axis.line = element_line(size=0.5),panel.background = element_rect(fill=NA,size=rel(20)), panel.grid.minor = element_line(colour = NA), plot.title = element_text(size=16), axis.text = element_text(size=12), axis.title = element_text(size=14), strip.text.x = element_text(size = 16)))

data$title <- "Intervention model"
intervention <- ggplot(data, aes(intervention_model)) + geom_bar(fill='black', colour="black",  width=0.3) + coord_flip() + facet_grid(. ~ title) + xlab(element_blank()) +  scale_y_continuous(labels = scales::comma, expand=c(0,0)) + ylab("Study count")
ggsave("intervention_model.png", width=11, height=8, units=c("cm"), dpi=600, limitsize=F)
table(data$intervention_model)


data$primary_purpose <- factor(data$primary_purpose, levels=rev(c("Treatment", "Prevention", "Supportive Care", "Other","Basic Science", "Health Services Research", "Diagnostic", "Screening" )))
data$title <- "Primary purpose"
purpose <- ggplot(data, aes(primary_purpose)) + geom_bar(fill='black', colour="black",  width=0.5) + coord_flip() + facet_grid(. ~ title) + xlab(element_blank()) +  scale_y_continuous(labels = scales::comma, expand=c(0,0)) + ylab("Study count")
ggsave("primary_purpose.png", width=11, height=8, units=c("cm"), dpi=600, limitsize=F)
table(data$primary_purpose)

data <- data[!is.na(data$overall_status), ]
data$overall_status <- factor(data$overall_status, levels=rev(c("Completed", "Terminated", "Active, not recruiting", "Unknown status", "Recruiting")))
data$title <- "Trial status"
status <- ggplot(data, aes(overall_status)) + geom_bar(fill='black', colour="black",  width=0.5) + coord_flip() + facet_grid(. ~ title) + xlab(element_blank()) +  scale_y_continuous(labels = scales::comma, expand=c(0,0)) + ylab("Study count")
ggsave("trial_status.png", width=11, height=8, units=c("cm"), dpi=600, limitsize=F)
table(data$overall_status)

data$gender <- factor(data$gender, levels=rev(c("All", "Female", "Male")))
data$title <- "Gender"
gender <- ggplot(data, aes(gender)) + geom_bar(fill='black', colour="black",  width=0.4) + coord_flip() + facet_grid(. ~ title) + xlab(element_blank()) +  scale_y_continuous(labels = scales::comma, expand=c(0,0)) + ylab("Study count")
ggsave("gender.png", width=11, height=8, units=c("cm"), dpi=600, limitsize=F)
table(data$gender)

data <- data[!is.na(data$phase), ]
data$phase <- factor(data$phase, levels=rev(c("Phase 3", "Phase 2", "N/A", "Phase 4", "Phase 1", "Phase 2/Phase 3", "Phase 1/Phase 2", "Early Phase 1")))
data$title <- "Trial phase"
phase <- ggplot(data, aes(phase)) + geom_bar(fill='black', colour="black",  width=0.5) + coord_flip() + facet_grid(. ~ title) + xlab(element_blank()) +  scale_y_continuous(labels = scales::comma, expand=c(0,0)) + ylab("Study count")
ggsave("trial_phase", width=11, height=8, units=c("cm"), dpi=600, limitsize=F)
table(data$phase)


data$title <- "Number of arms"
number_arms <- ggplot(data, aes(number_of_arms)) + geom_bar(fill='black', colour="black",  width=0.5) + facet_grid(. ~ title) + xlab(element_blank()) +  scale_y_continuous(labels = scales::comma, expand=c(0,0)) +  scale_x_continuous(limits = c(0, 15)) + ylab("Study count") + coord_flip() + scale_x_reverse(limits = c(15, 0))
ggsave("arms.png", width=11, height=8, units=c("cm"), dpi=600, limitsize=F)
summary(data$number_of_arms)

(intervention | purpose ) / (status | phase) / (gender | number_arms )

ggarrange(intervention, purpose, status, phase, gender, number_arms, ncol = 2, nrow = 3)
#ggarrange(phase, status, gender, intervention, number_arms, purpose, ncol = 2, nrow = 3)
#ggarrange(intervention, status, gender, phase, number_arms, purpose, ncol = 2, nrow = 3)


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
pvalues <- ggplot(data_results, aes(p_value)) + geom_histogram(fill='darkblue', colour="black") + scale_x_continuous(limits = c(0, 1)) + scale_y_continuous(limits = c(0, 13000), labels = scales::comma, expand=c(0,0)) + xlab("P-value") + ylab("Result count")

ggtitle("P-value distribution")
ggsave("p-values.png", width=10, height=8, units=c("cm"), dpi=600, limitsize=F)
summary(data_results$p_value)

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
