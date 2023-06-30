from config import *
import psycopg2 as pg
import pandas as pd
import pandas.io.sql as sqlio

conn = pg.connect(f"host={aact_host} port={aact_port} dbname={aact_dbname} user={aact_user} password={aact_password}")
null_signifiers = ["None", "none", "NONE", "NA", "N/A", "na", "n/a", "nan", "NaN", "Null", "null", "NULL", " "]
#Brief Summaries table
def run_query(conn, sql):
    cur = conn.cursor()
    dat = sqlio.read_sql_query(sql, conn)
    cur.close()
    return(dat)

def remove_empty(df, my_cols):
	df.dropna(subset=my_cols, inplace=True)
	for m in my_cols:
		inverse_boolean_series = ~df[m].isin(null_signifiers)
		df = df[inverse_boolean_series]
	return(df)

####BRIEF SUMMARIES
sql = """select nct_id, description from brief_summaries"""
results = run_query(conn,sql)
#Remove empty entries on key columns
results = remove_empty(results, ["nct_id", "description"])
#Save to file.
results.to_csv("brief_summaries.txt", sep="\t", index=False)


####ALL CONDITIONS
sql = """select * from all_conditions"""
results = run_query(conn,sql)
#Remove empty entries on key columns
results = remove_empty(results, ["names"])
#Save to file.
results.to_csv("all_conditions.txt", sep="\t", index=False)


####ALL INTERVENTIONS
sql = """select * from all_interventions"""
results = run_query(conn,sql)
#Remove empty entries on key columns
results = remove_empty(results, ["names"])
#Save to file.
results.to_csv("all_interventions.txt", sep="\t", index=False)


####ALL INTERVENTIONS_TYPES
sql = """select * from all_intervention_types"""
results = run_query(conn,sql)
#Remove empty entries on key columns
results = remove_empty(results, ["names"])
#Save to file.
results.to_csv("all_intervention_types.txt", sep="\t", index=False)

###DESIGNS
sql = """select nct_id, intervention_model, primary_purpose, allocation from designs"""
results = run_query(conn,sql)
#Remove empty entries on key columns
results = remove_empty(results, ["intervention_model", "primary_purpose", "allocation"])
#Only Parallel Assignment and Crossover Assignment
to_keep = results['intervention_model'].isin(["Parallel Assignment", "Crossover Assignment"])
results = results[to_keep]
#Only Randomized design
to_keep = results['allocation'].isin(["Randomized"])
results = results[to_keep]
#Save to file.
results.to_csv("designs.txt", sep="\t", index=False)

#DESIGN GROUPS
sql = """select nct_id, group_type, title, description from design_groups"""
results = run_query(conn,sql)
results.to_csv("design_groups.txt", sep="\t", index=False)

#INTERVENTIONS
sql = """select nct_id, name, description, intervention_type from interventions"""
results = run_query(conn,sql)
results = remove_empty(results, ["intervention_type", "name"])
results.to_csv("interventions.txt", sep="\t", index=False)

#ELIGIBILITIES
sql = """select nct_id, gender, criteria, minimum_age, maximum_age from eligibilities"""
results = run_query(conn,sql)
results = remove_empty(results, ["gender", "criteria"])
results.to_csv("eligibilities.txt", sep="\t", index=False)

#CONDITIONS
sql = """select nct_id, name from conditions"""
results = run_query(conn,sql)
results.to_csv("conditions.txt", sep="\t", index=False)

#OUTCOME ANALYSES
sql = """select * from outcome_analyses"""
results = run_query(conn,sql)
#results = remove_empty(results, ["outcome_id", "param_type", "param_value", "p_value", "method"])
results.to_csv("outcome_analyses.txt", sep="\t", index=False)

###OUTCOMES
sql = """select nct_id, id, outcome_type, title, description, time_frame, population, units from outcomes"""
results = run_query(conn,sql)
results.to_csv("outcomes.txt", sep="\t", index=False)

###STUDY REF
sql = """select nct_id, pmid, reference_type, citation from study_references"""
results = run_query(conn,sql)
results.to_csv("study_references.txt", sep="\t", index=False)

###STUDIES
###Total number of studies found: 206,079
sql = """select nct_id, brief_title, study_type, baseline_population, official_title, overall_status, phase, number_of_arms, limitations_and_caveats, enrollment from studies"""
results = run_query(conn,sql)
results = remove_empty(results, ["brief_title", "study_type", "overall_status", "number_of_arms", "enrollment"])
to_keep = results['study_type'].isin(["Interventional"])
results = results[to_keep]
results = results.loc[results['number_of_arms'] > 1]
results.to_csv("studies.txt", sep="\t", index=False)

sql = """select nct_id, brief_title, study_type, baseline_population, official_title, overall_status, phase, number_of_arms, limitations_and_caveats, enrollment from studies"""
results = run_query(conn,sql)
results = remove_empty(results, ["brief_title", "study_type", "overall_status", "number_of_arms", "enrollment"])
to_keep = results['study_type'].isin(["Interventional"])
results = results[to_keep]
results = results.loc[results['number_of_arms'] > 1]
results.to_csv("studies.txt", sep="\t", index=False)

sql = """select * from studies"""
results = run_query(conn,sql)
results = remove_empty(results, ["brief_title", "study_type", "overall_status", "number_of_arms", "enrollment"])
to_keep = results['study_type'].isin(["Interventional"])
results = results[to_keep]
results = results.loc[results['number_of_arms'] > 1]
results.to_csv("studies_ext.txt", sep="\t", index=False)


#MESH terms - interventions
sql = """select * from browse_interventions"""
results = run_query(conn,sql)
results.to_csv("mesh-interventions.txt", sep="\t", index=False)

#MESH terms - conditions
sql = """select * from browse_conditions"""
results = run_query(conn,sql)
results.to_csv("mesh-conditions.txt", sep="\t", index=False)


#RESULT_GROUPS
sql = """select * from mesh_terms"""
results = run_query(conn,sql)
results.to_csv("mesh_terms.txt", sep="\t", index=False)


#RESULT_GROUPS
sql = """select * from mesh_headings"""
results = run_query(conn,sql)
results.to_csv("mesh_headings.txt", sep="\t", index=False)
