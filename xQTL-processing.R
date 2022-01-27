library("tidyverse")
setwd('/mnt/storage/home/qh18484/scratch/xqtl')
#Read in a file with GWAS ID - phenotype name associations
mr_mh <- read.delim("xqtl-raw/eQTL-MR-single-mrb.txt", stringsAsFactors=FALSE, sep="\t")
mr_mh_slimmed <- mr_mh[c("id.outcome", "outcome")] %>% distinct()
#Read in a file with multi-SNP MR results.
multi_snp <- read.csv("xqtl-processed/xqtl_multi_snp.csv", stringsAsFactors=FALSE)
#Read in a file with single-SNP MR results.
single_snp <- read.csv("xqtl-processed/xqtl_single_snp.csv", stringsAsFactors=FALSE)

#Filter the results down to eQTL and significant p-value results (p=P < 3.5 × 10−7)
threshold = 3.5 * 1e-7
multi_snp2 <- multi_snp[multi_snp$p < threshold,]
single_snp2 <- single_snp[single_snp$p < threshold,]
multi_snp2 <- multi_snp2[multi_snp2$qtl_type == "eQTL",]
single_snp2 <- single_snp2[single_snp2$qtl_type == "eQTL",]

multi_snp2 <- multi_snp2[multi_snp2$mr_method == "IVW",]

merged_multi <- merge(multi_snp2, mr_mh_slimmed, by.x="outcome", by.y="id.outcome")
merged_single <- merge(single_snp2, mr_mh_slimmed, by.x="outcome", by.y="id.outcome")
write.table(merged_multi, "merged_multi_significant.txt", quote=F, row.names=F)
write.table(merged_single, "merged_single_significant.txt", quote=F, row.names=F)