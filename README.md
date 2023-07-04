## Python/R scripts for analyses described in "Systematic comparison of Mendelian randomization studies and randomized controlled trials using electronic databases"

#### A Jupyter notebook with basic exploration of data stored within ClinicalTrials.Gov database
##### [explore-rct.ipynb](https://github.com/marynias/mr-rct/blob/master/explore-rct.ipynb)
##### *Dependencies*: 
* pandas
* psycopg2 
#### Extract required tables from ClinicalTrials.Gov
##### [extract_filtered_tables.py](https://github.com/marynias/mr-rct/blob/master/extract_filtered_tables.py) 
##### *Dependencies*: 
* pandas
* psycopg2 
#### Process (filter, merge) tables from ClinicalTrials.Gov
##### [process_tables.R](https://github.com/marynias/mr-rct/blob/master/process_tables.R)
##### *Dependencies*: 
* dplyr
* stringr
* tidyr
#### Quantitative and qualitative description of the filtered RCT dataset from ClinicalTrials.Gov
##### [clingov_data_explorer.R](https://github.com/marynias/mr-rct/blob/master/clingov_data_explorer.R)
##### *Dependencies*: 
* DataExplorer
* dplyr
* ggplot2
* patchwork
* ggpubr
* anytime
* lubridate
* reshape2
#### Statistical comparison of features of RCTs with results published on ClinicalTrials.Gov relative to all the RCTs in the database
##### [chi_squared_comparison.R](https://github.com/marynias/mr-rct/blob/master/chi_squared_comparison.R)
##### *Dependencies*: 
* tibble
* dplyr
### Analyses comparing eQTL and pQTL MR results with RCT results

#### Link pQTL MR results with RCT results via drug matching using EpigraphDB
##### [get_drug_data_EpigraphDB_pQTL.R](https://github.com/marynias/mr-rct/blob/master/get_drug_data_EpigraphDB_pQTL.R)
##### *Dependencies*: 
* epigraphdb
* dplyr
* tidyr

#### Pre-process eQTL MR results for further analysis
##### [xQTL-processing.R](https://github.com/marynias/mr-rct/blob/master/xQTL-processing.R)
##### *Dependencies*: 
* tidyverse
#### Link eQTL MR results (multi-SNP instruments) with RCT results via drug matching using EpigraphDB
##### [get_drug_data_EpigraphDB_eQTL_multi.R](https://github.com/marynias/mr-rct/blob/master/get_drug_data_EpigraphDB_eQTL_multi.R)
##### *Dependencies*: 
* epigraphdb
* dplyr
* tidyr
#### Link eQTL MR results (single-SNP instruments) with RCT results via drug matching using EpigraphDB
##### [get_drug_data_EpigraphDB_eQTL_single.R](https://github.com/marynias/mr-rct/blob/master/get_drug_data_EpigraphDB_eQTL_single.R)
##### *Dependencies*: 
* epigraphdb
* dplyr
* tidyr
### Analyses for MR and RCT records retrieved from PubMed combined with SemMedDb semantic triples retrieved via EpigraphDB

##### [mr-rtc_pubmed_epigraphdb.R](https://github.com/marynias/mr-rct/blob/master/mr-rtc_pubmed_epigraphdb.R)
##### *Dependencies*: 
* tidyverse
* epigraphdb
* patchwork
* data.table
## Data sources
##### ClinicalTrials.Gov data was accessed via AACT: https://aact.ctti-clinicaltrials.org/download and analysed data subset is featured in *Supplementary Datasets 1 & 2*.
##### pQTL and eQTL MR analysis results are available via EpigraphDB: https://epigraphdb.org/xqtl 
##### PubMed database can be accessed on https://pubmed.ncbi.nlm.nih.gov/ and analysed data subset is featured in *Supplementary Dataset 4*.
##### SemMedDB can be accessed on https://lhncbc.nlm.nih.gov/ii/tools/SemRep_SemMedDB_SKR/SemMedDB_download.html and analysed data subset is featured in *Supplementary Dataset 4*.
##### Case series of MR and RCT studies with matching exposures (interventions) and outcomes (conditions) is featured in *Supplementary Dataset 4*.
##### *Supplementary Datasets 1-5* are available for download on Zenodo: https://doi.org/10.5281/zenodo.8104176


