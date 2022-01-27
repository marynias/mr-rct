library("dplyr")
library("tibble")

#All outcomes
data_in <- read.delim("clingov_required.tsv", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
data <- data_in %>% dplyr::select(nct_id, all_interv_types, intervention_model, study_type, primary_purpose, allocation, overall_status, gender, phase, number_of_arms, mesh_interv, mesh_cond) %>% distinct()
data_results <- data_in %>% dplyr::select(nct_id, all_interv_types, method, param_type, p_value, mesh_interv) %>% distinct()

all_in <- read.delim("clingov_non_required.tsv", header=T, stringsAsFactors=F, row.names=NULL, sep="\t", quote="")
all <- all_in %>% dplyr::select(nct_id, all_interv_types, intervention_model, study_type, primary_purpose, allocation, overall_status, gender, phase, number_of_arms, mesh_interv, mesh_cond) %>% distinct()
all_results <- all_in %>% dplyr::select(nct_id, all_interv_types, method, param_type, p_value, mesh_interv) %>% distinct()

count_variable <- function(x) {
    data_inter <- data %>% count((!!as.name(x))) %>% rename(main_dataset="n")

    all_inter <- all %>% count((!!as.name(x))) %>% rename(all_RCTs="n")

    merge_inter <- merge(data_inter, all_inter) %>% remove_rownames %>% column_to_rownames(var=x)

    chisq <- chisq.test(merge_inter)

    #Table with column-summed proportions
    prop_inter <- prop.table(as.matrix(merge_inter), 2)
    colnames(prop_inter) <- c("main_dataset_freq", "all_RCTs_freq")
    merged <- cbind(merge_inter, prop_inter)
    outList <- list("chisquared" = chisq, "table" = merged)
}
 #Count intervention model
output <- count_variable("intervention_model")
write.table(output$table, "intervention_model_comp.txt", sep="\t", quote=F)


#Count primary purpose
output <- count_variable("primary_purpose")
write.table(output$table, "primary_purpose_comp.txt", sep="\t", quote=F)


#Count trial status
output <- count_variable("overall_status")
write.table(output$table, "overall_status_comp.txt", sep="\t", quote=F)

#Count trial phase
output <- count_variable("phase")
write.table(output$table, "phase_comp.txt", sep="\t", quote=F)

#Count gender
output <- count_variable("gender")
write.table(output$table, "gender_comp.txt", sep="\t", quote=F)

#Count number of arms
output <- count_variable("number_of_arms")
write.table(output$table, "number_of_arms_comp.txt", sep="\t", quote=F)