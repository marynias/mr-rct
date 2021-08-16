from config import *
import psycopg2 as pg
import pandas as pd
import pandas.io.sql as sqlio

conn = pg.connect(f"host={aact_host} port={aact_port} dbname={aact_dbname} user={aact_user} password={aact_password}")

def run_query(conn, sql):
    cur = conn.cursor()
    dat = sqlio.read_sql_query(sql, conn)
    cur.close()
    return(dat)


pd.set_option('display.max_columns', None)

sql = """select distinct 
    oa.nct_id,
    intv.name, intv.intervention_type,
    cnd.downcase_name,
    oa.outcome_id, oa.param_type, oa.param_value, oa.ci_lower_limit, oa.ci_upper_limit, oa.ci_percent, oa.p_value, oa.method
from 
    outcome_analyses oa
    LEFT JOIN interventions intv on intv.nct_id = oa.nct_id
    LEFT JOIN conditions cnd on cnd.nct_id = oa.nct_id
"""
sql2 = """select 
        out.id, out.nct_id, out.title, out.time_frame, out.population, out.units_analyzed
from
    outcomes out
"""

results = run_query(conn,sql)
outcomes = run_query(conn, sql2)
output = results.merge(outcomes, how="left", left_on="outcome_id", right_on="id")
output.to_csv("clintrials_results.csv")
conn.close()