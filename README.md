## Python/R scripts for analyses described in "Systematic comparison of Mendelian randomization studies and randomized controlled trials using electronic databases"

#### A Jupyter notebook with basic exploration of data strored within ClinicalTrials.Gov database
##### [explore-rct.ipynb](https://github.com/marynias/mr-rct/blob/master/explore-rct.ipynb)
#### Extract required tables from ClinicalTrials.Gov
##### [extract_filtered_tables.py](https://github.com/marynias/mr-rct/blob/master/extract_filtered_tables.py) 
#### Process (filter, merge) tables from ClinicalTrials.Gov
##### [process_tables.R](https://github.com/marynias/mr-rct/blob/master/process_tables.R)
#### Quantitative and qualitative description of the filtered RCT dataset from ClinicalTrials.Gov
##### [clingov_data_explorer.R](https://github.com/marynias/mr-rct/blob/master/clingov_data_explorer.R)

### Analyses comparing eQTL and pQTL MR results with RCT results

#### Link pQTL MR results with RCT results via drug matching using EpigraphDB
##### [get_drug_data_EpigraphDB_pQTL.R](https://github.com/marynias/mr-rct/blob/master/get_drug_data_EpigraphDB_pQTL.R)

#### Pre-process eQTL MR results for further analysis
##### [xQTL-processing.R](https://github.com/marynias/mr-rct/blob/master/xQTL-processing.R)
#### Link eQTL MR results (multi-SNP instruments) with RCT results via drug matching using EpigraphDB
##### [get_drug_data_EpigraphDB_eQTL_multi.R](https://github.com/marynias/mr-rct/blob/master/get_drug_data_EpigraphDB_eQTL_multi.R)
#### Link eQTL MR results (single-SNP instruments) with RCT results via drug matching using EpigraphDB
##### [get_drug_data_EpigraphDB_eQTL_single.R](https://github.com/marynias/mr-rct/blob/master/get_drug_data_EpigraphDB_eQTL_single.R)

### Analyses for MR and RCT records retrieved from PubMed combined with SemMedDb semantic triples retrieved via EpigraphDB

##### [mr-rtc_pubmed_epigraphdb.R](https://github.com/marynias/mr-rct/blob/master/mr-rtc_pubmed_epigraphdb.R)

