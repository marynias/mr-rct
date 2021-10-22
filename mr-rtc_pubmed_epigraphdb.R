library("tidyverse")
library("epigraphdb")
library("patchwork")

#Set ggplot2 theme
theme_set(theme_gray()+ theme(legend.key=element_blank(), axis.line = element_line(size=0.5),panel.background = element_rect(fill=NA,size=rel(20)), panel.grid.minor = element_line(colour = NA), plot.title = element_text(size=16), axis.text = element_text(size=12), axis.title = element_text(size=14), strip.text.x = element_text(size = 16)))


#MR studies
mr_mh <- read.csv("mendelian-mh.csv", stringsAsFactors=FALSE)
colnames(mr_mh)[1] <- "PMID"
length(unique(mr_mh$PMID))
mr_tiab <- read.csv("mendelian-tiab.csv", stringsAsFactors=FALSE)
colnames(mr_tiab)[1] <- "PMID"
length(unique(mr_tiab$PMID))
#Unique to MH
mh_uniq <- mr_mh$PMID[!(mr_mh$PMID %in% mr_tiab$PMID)]
length(mh_uniq)
#Do not use these entries, titles indicate that they are not relevant
add_mr_entires <- mr_mh[mr_mh$PMID %in% mh_uniq,]

#Unique to TIAB
mtiab_uniq <- mr_tiab$PMID[!(mr_tiab$PMID%in% mr_mh$PMID)]
length(mtiab_uniq)

mr_tiab_yearly_sum <- mr_tiab %>% group_by(Publication.Year) %>% count() %>%  filter(!(Publication.Year==2022))

mr_papers <- ggplot(data = mr_tiab_yearly_sum, aes(x = Publication.Year, y = n))+
  geom_line(color = "#00AFBB", size = 2) + ylab("Study count") + xlab("Year of publication") + 
  scale_y_continuous(labels = scales::comma, expand=c(0,0))

ggsave("mr_papers.png", width=10, height=7, units=c("cm"), dpi=600, limitsize=F)

#Combine RCT + MR in one plot.


#Query triples in EpigraphDb containg our MR studies.

quoted <- gsub("^", "'", mr_tiab$PMID)
quoted <- gsub("$", "'", quoted)
my_list_ids = paste(quoted, collapse =", ")

query <-  paste0("MATCH (lit:Literature)-[sem:SEMMEDDB_TO_LIT]-(trip:LiteratureTriple) WHERE lit.id in [", my_list_ids[1], "] RETURN trip.subject_id, trip.predicate, trip.name, trip.id, trip.object_id, lit.id")

call_epigraphdb <- function(query) {

  endpoint <- "/cypher"
  method <- "POST"
  params <- list(query = query)
  
  results <- query_epigraphdb(
    route = endpoint,
    params = params,
    method = method,
    mode = "table"
  )
  results
}

results <- call_epigraphdb(query)
write.table(results, "mr_tiab_triples.tsv", sep="\t", quote=F, row.names=F)


quoted2 <- gsub("^", "'", results$trip.id)
quoted2 <- gsub("$", "'", quoted2)
my_list_ids2 = paste(quoted2, collapse =", ")

query2 <-  paste0("MATCH (l1:LiteratureTerm)-[r1:SEMMEDDB_SUB]-(l:LiteratureTriple)-[r2:SEMMEDDB_OBJ]-(l2:LiteratureTerm) WHERE l.id in [", my_list_ids2[1], "] RETURN l1.name as sub_name,l.predicate as predicate,l2.name as obj_name, l.id")

results2 <- call_epigraphdb(query2)
write.table(results2, "mr_tiab_triples_det.tsv", sep="\t", quote=F, row.names=F)

#Join the two tables
joined <- merge(results, results2, by.x="trip.id", by.y="l.id")
write.table(joined, "mr_tiab_triples_joined.tsv", sep="\t", quote=F, row.names=F)

#What is the most popular exposure?
exposures_mr <- joined %>% group_by(sub_name) %>% count() %>% arrange(desc(n))
write.table(exposures_mr, "mr_top_exposures.tsv", sep="\t", quote=F, row.names=F)
exposures_mr$sub_name <- factor(exposures_mr$sub_name, levels=exposures_mr$sub_name)
exposure_mr_fig <- ggplot(exposures_mr[1:15,],
       aes(x = n, y = sub_name)) +
  geom_col(fill='#00AFBB') + 
  scale_y_discrete(limits=rev) + ylab("") + xlab("count")

#What is the most popular outcome?
outcome_mr <- joined %>% group_by(obj_name) %>% count() %>% arrange(desc(n))
write.table(outcome_mr, "mr_top_outcomes.tsv", sep="\t", quote=F, row.names=F)
outcome_mr$obj_name <- factor(outcome_mr$obj_name, levels=outcome_mr$obj_name)
outcome_mr_fig <- ggplot(outcome_mr[1:15,],
       aes(x = n, y = obj_name)) +
  geom_col(fill='#00AFBB') + 
  scale_y_discrete(limits=rev) + ylab("") + xlab("count")

#What is the most popular predicate?
predicate_mr <- joined %>% group_by(predicate) %>% count() %>% arrange(desc(n))
write.table(predicate_mr, "mr_top_predicates.tsv", sep="\t", quote=F, row.names=F)
predicate_mr$predicate <- factor(predicate_mr$predicate, levels=predicate_mr$predicate)
predicate_mr_fig <- ggplot(predicate_mr[1:15,],
       aes(x = n, y = predicate)) +
  geom_col(fill='#00AFBB') + 
  scale_y_discrete(limits=rev) + ylab("") + xlab("count")
#How many MR papers from Pubmed have a lit triple?
b = length(mr_tiab$PMID)
a = length(unique(joined$lit.id))
a/b
#Only 17.9% of MR papers have a triple associate with them.

#What publication years do the triples cover?
mr_select <- mr_tiab[mr_tiab$PMID %in% joined$lit.id,]
write.table(mr_select, "mr_select.tsv", sep="\t", quote=F, row.names=F)
mr_tiab_yearly_sum_select <- mr_select %>% group_by(Publication.Year) %>% count() %>%  filter(!(Publication.Year==2022))
ggplot(data = mr_tiab_yearly_sum_select, aes(x = Publication.Year, y = n))+
  geom_line(color = "#00AFBB", size = 2) + ylab("Study count") + xlab("Year of publication") +
  scale_y_continuous(labels = scales::comma, expand=c(0,0))
ggsave("mr_triples_timeline.png", width=10, height=7, units=c("cm"), dpi=600, limitsize=F)

####Load in RCT studies
all_rct_files <- list.files(pattern = "^csv-randomized-set*", recursive = TRUE)


loadFile <- function(x) {
  print (x)
  df <- read.csv(x, header=T, stringsAsFactors=F,row.names=NULL)
  df
}

all_normal <- lapply(all_rct_files, loadFile)
all_normal_together <- do.call(rbind,all_normal)
all_normal_together <- as.data.frame(all_normal_together)
colnames(all_normal_together)[1] <- "PMID"

all_normal_together <- all_normal_together %>% distinct()


rct_yearly_sum <- all_normal_together %>% group_by(Publication.Year) %>% count() %>%  filter(!(Publication.Year==2022))

rct_papers <- ggplot(data = rct_yearly_sum, aes(x = Publication.Year, y = n))+
  geom_line(color = "#F06543", size = 2) + ylab("Study count") + xlab("Year of publication") + 
  scale_y_continuous(labels = scales::comma, expand=c(0,0)) 
ggsave("rct_papers.png", width=10, height=7, units=c("cm"), dpi=600, limitsize=F)

#Plot RCT and MR counts on 1 plot
mr_papers + rct_papers

merged_counts <- merge(mr_tiab_yearly_sum, rct_yearly_sum, by="Publication.Year", all.y=T)
colnames(merged_counts) <- c("Publication_year", "MR", "RCT")

merged_counts_long <- merged_counts %>% gather(., key="study_type", value="count", 2:3)

ggplot(data = merged_counts_long, aes(x = Publication_year, y = count, colour=study_type))+
  geom_line(size = 2) + ylab("Study count") + xlab("Year of publication") + 
  scale_y_continuous(labels = scales::comma, expand=c(0,0)) + scale_colour_manual(values=c("#00AFBB", "#F06543")) +
  labs(colour='study type') 
ggsave("rct_mr_combined_count.png", width=20, height=12, units=c("cm"), dpi=600, limitsize=F)

quoted <- gsub("^", "'", all_normal_together$PMID)
quoted <- gsub("$", "'", quoted)
my_list_ids = paste(quoted, collapse =", ")

query <-  paste0("MATCH (lit:Literature)-[sem:SEMMEDDB_TO_LIT]-(trip:LiteratureTriple) WHERE lit.id in [", my_list_ids[1], "] RETURN trip.subject_id, trip.predicate, trip.name, trip.id, trip.object_id, lit.id")
endpoint <- "/cypher"
method <- "POST"
params <- list(query = query)

results3 <- query_epigraphdb(
  route = endpoint,
  params = params,
  method = method,
  mode = "table"
)
results3 <- call_epigraphdb(query)
write.table(results3, "rct_triples.tsv", sep="\t", quote=F, row.names=F)

quoted2 <- gsub("^", "'", results3$trip.id)
quoted2 <- gsub("$", "'", quoted2)
my_list_ids2 = paste(quoted2, collapse =", ")

query2 <-  paste0("MATCH (l1:LiteratureTerm)-[r1:SEMMEDDB_SUB]-(l:LiteratureTriple)-[r2:SEMMEDDB_OBJ]-(l2:LiteratureTerm) WHERE l.id in [", my_list_ids2[1], "] RETURN l1.name as sub_name,l.predicate as predicate,l2.name as obj_name, l.id")

results4 <- call_epigraphdb(query2)
write.table(results4, "rct_triples_det.tsv", sep="\t", quote=F, row.names=F)

#Join the two tables
joined2 <- merge(results3, results4, by.x="trip.id", by.y="l.id")
write.table(joined2, "rct_triples_joined.tsv", sep="\t", quote=F, row.names=F)

#What is the most popular exposure?
exposures_rct <- joined2 %>% group_by(sub_name) %>% count() %>% arrange(desc(n))
write.table(exposures_rct, "rct_top_exposures.tsv", sep="\t", quote=F, row.names=F)
exposures_rct$sub_name <- factor(exposures_rct$sub_name, levels=exposures_rct$sub_name)
exposure_rtc_fig <- ggplot(exposures_rct[1:15,],
       aes(x = n, y = sub_name)) +
  geom_col(fill='#F06543') + 
  scale_y_discrete(limits=rev) + ylab("") + xlab("count")


#What is the most popular outcome?
outcome_rct <- joined2 %>% group_by(obj_name) %>% count() %>% arrange(desc(n))
write.table(outcome_rct, "rct_top_outcomes.tsv", sep="\t", quote=F, row.names=F)
outcome_rct$obj_name <- factor(outcome_rct$obj_name, levels=outcome_rct$obj_name)
outcome_rtc_fig <- ggplot(outcome_rct[1:15,],
       aes(x = n, y = obj_name)) +
  geom_col(fill='#F06543') + 
  scale_y_discrete(limits=rev) + ylab("") + xlab("count")
#What is the most popular predicate?
predicate_rct <- joined2 %>% group_by(predicate) %>% count() %>% arrange(desc(n))
write.table(predicate_rct, "rct_top_predicates.tsv", sep="\t", quote=F, row.names=F)
predicate_rct$predicate <- factor(predicate_rct$predicate, levels=predicate_rct$predicate)
predicate_rtc_fig <- ggplot(predicate_rct[1:15,],
       aes(x = n, y = predicate)) +
  geom_col(fill='#F06543') + 
  scale_y_discrete(limits=rev) + ylab("") + xlab("count")



#One figure comparing exposure, predicates, outcomes in MR/RCT
(exposure_mr_fig | exposure_rtc_fig) / (predicate_mr_fig | predicate_rtc_fig) /(outcome_mr_fig | outcome_rtc_fig)
ggsave("rct_mr_triple_count.png", width=100, height=50, units=c("cm"), dpi=600, limitsize=F)
#How many RCT papers from Pubmed have a lit triple?
b = length(all_normal_together$PMID)
a = length(unique(joined2$lit.id))
a/b
#Only 11% of RCT papers have a triple associated with them.

#What publication years do the triples cover?
rct_select <- all_normal_together[all_normal_together$PMID %in% joined2$lit.id,]
write.table(rct_select, "rct_select.tsv", sep="\t", quote=F, row.names=F)
rct_yearly_sum_select <- rct_select %>% group_by(Publication.Year) %>% count() %>%  filter(!(Publication.Year==2022))
ggplot(data = rct_yearly_sum_select, aes(x = Publication.Year, y = n))+
  geom_line(color = "#F06543", size = 2) + ylab("Study count") + xlab("Year of publication") + 
  scale_y_continuous(labels = scales::comma, expand=c(0,0)) 
ggsave("rct_tripes_timeline.png", width=10, height=7, units=c("cm"), dpi=600, limitsize=F)

#Plot number of papers and triples on the same timeline
merged_counts <- merge(mr_tiab_yearly_sum, rct_yearly_sum, by="Publication.Year", all.y=T)
merged_counts2 <- merge(merged_counts, mr_tiab_yearly_sum_select, by="Publication.Year", all.x=T)
colnames(merged_counts2) <- c("Publication.Year", "MR", "RCT", "MR_triple")
merged_counts3 <- merge(merged_counts2, rct_yearly_sum_select, by="Publication.Year", all.x=T)
colnames(merged_counts3) <- c("Publication.Year", "MR", "RCT", "MR_triple", "RCT_triple")

merged_counts3_long <- merged_counts3 %>% gather(., key="study_type", value="count", 2:5)

ggplot(data = merged_counts3_long, aes(x = Publication.Year, y = count, group=study_type))+
  geom_line(size=1, aes(linetype=study_type, color=study_type)) + ylab("Study count") + xlab("Year of publication") + 
  scale_y_continuous(labels = scales::comma, expand=c(0,0)) + 
  scale_colour_manual(name="", labels=c("MR papers", "MR triples", "RCT papers", "RCT triples"), values=c("#00AFBB", "#00AFBB", "#F06543", "#F06543")) +
  scale_linetype_manual(name="", labels=c("MR papers", "MR triples", "RCT papers", "RCT triples"), values=c("solid", "dotted", "solid", "dotted")) +
  labs(colour='study type') 

ggsave("all_timelines.png", width=20, height=12, units=c("cm"), dpi=600, limitsize=F)

#Find overlap between RCT and MR (exposure and outcome matching)
matched <- merge(joined, joined2, by=c("sub_name", "obj_name"))
write.table(matched, "rct_mr_matched.tsv", sep="\t", quote=F, row.names=F)

# A unique set of matching subjects and objects.
exposure_outcomes <- unique(matched[c("sub_name", "obj_name")])
write.table(exposure_outcomes, "exposure-outcome_pairs.tsv", sep="\t", quote=F, row.names=F)
#Join with MR
joined_mr <- merge(joined, exposure_outcomes, by=c("sub_name", "obj_name"))
write.table(joined_mr, "exposure-outcome_joined_mr.tsv", sep="\t", quote=F, row.names=F)
#Join with RCT
joined_rct <- merge(joined2, exposure_outcomes, by=c("sub_name", "obj_name"))
write.table(joined_rct, "exposure-outcome_joined_rct.tsv", sep="\t", quote=F, row.names=F)
#Retrieve bibliographic info - MR
mr_studies_match <- mr_tiab[mr_tiab$PMID %in% joined_mr$lit.id,]
write.table(mr_studies_match, "exposure-outcome_joined_mr_lit.tsv", sep="\t", quote=F, row.names=F)
#Retrieve bibliographic info - RCT
rct_studies_match <- all_normal_together[all_normal_together$PMID %in% joined_rct$lit.id,]
write.table(rct_studies_match, "exposure-outcome_joined_rct_lit.tsv", sep="\t", quote=F, row.names=F)
#Count how many papers reference a given exposure-outcome pair
#MR
doubles_mr <- joined_mr %>% select("sub_name", "obj_name", "lit.id") %>% distinct() %>% group_by(sub_name, obj_name) %>% count %>% arrange(desc(n))
write.table(doubles_mr, "exposure-outcome_lit_count_mr.tsv", sep="\t", quote=F, row.names=F)
#RCT
doubles_rct <- joined_rct %>% select("sub_name", "obj_name", "lit.id") %>% distinct() %>% group_by(sub_name, obj_name) %>% count %>% arrange(desc(n))
write.table(doubles_rct, "exposure-outcome_lit_count_rct.tsv", sep="\t", quote=F, row.names=F)
#Now, the same for exposures and outcomes seperately.
exp_mr <- joined_mr %>% select("sub_name", "lit.id") %>% distinct() %>% group_by(sub_name) %>% count %>% arrange(desc(n))
write.table(exp_mr, "exposure_lit_count_mr.tsv", sep="\t", quote=F, row.names=F)
outcome_mr <- joined_mr %>% select("obj_name", "lit.id") %>% distinct() %>% group_by(obj_name) %>% count %>% arrange(desc(n))
write.table(exp_mr, "outcome_lit_count_mr.tsv", sep="\t", quote=F, row.names=F)

exp_rct <- joined_rct %>% select("sub_name", "lit.id") %>% distinct() %>% group_by(sub_name) %>% count %>% arrange(desc(n))
write.table(exp_rct, "exposure_lit_count_rct.tsv", sep="\t", quote=F, row.names=F)
outcome_rct <- joined_rct %>% select("obj_name", "lit.id") %>% distinct() %>% group_by(obj_name) %>% count %>% arrange(desc(n))
write.table(outcome_rct, "outcome_lit_count_rct.tsv", sep="\t", quote=F, row.names=F)

#Now merge these files to compare numbers for MR and RCT.
doubles_merged <- merge(doubles_mr, doubles_rct, by=c("sub_name", "obj_name"))
colnames(doubles_merged) <- c("sub_name", "obj_name", "MR", "RTC")
write.table(doubles_merged, "exposure_outcome_lit_count_all.tsv", sep="\t", quote=F, row.names=F)

exp_merged <- merge(exp_mr, exp_rct, by="sub_name")
colnames(exp_merged) <- c("sub_name", "MR", "RTC")
write.table(exp_merged, "exposure_lit_count_all.tsv", sep="\t", quote=F, row.names=F)

outcome_merged <- merge(outcome_mr, outcome_rct, by="obj_name")
colnames(outcome_merged) <- c("obj_name", "MR", "RTC")
write.table(outcome_merged, "outcome_lit_count_all.tsv", sep="\t", quote=F, row.names=F)
#How many exposure/outcome pairs do we have in MR and RCT combined?
exp_out_rct <- unique(joined2[c("sub_name", "obj_name")])
exp_out_mr <- unique(joined[c("sub_name", "obj_name")])
combined_exp_out <- rbind(exp_out_mr, exp_out_rct)
combined_exp_out_distinct <- unique(combined_exp_out[c("sub_name", "obj_name")])

#Plot in ggplot2
