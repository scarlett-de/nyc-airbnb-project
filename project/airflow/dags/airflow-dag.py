from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.utils.dates import days_ago
from datetime import timedelta
from pathlib import Path
import logging
import os
import sys

sys.path.insert(0, "/opt/airflow")

# Use container paths (matches volume mounts)
PROJECT_ROOT = Path("/opt/airflow")
LOAD_SCRIPT = PROJECT_ROOT / "load" / "load.py"
DBT_DIR = PROJECT_ROOT / "dbt_transform"

default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'project_workflow',
    default_args=default_args,
    description='Data pipeline from GCS to BigQuery with dbt',
    schedule_interval='@daily',
    catchup=False,
)

def load_data_to_bigquery():
    """Load data from GCS to BigQuery"""
    try:
        logging.info(f"Running {LOAD_SCRIPT}")
        if not LOAD_SCRIPT.exists():
            raise FileNotFoundError(f"Script not found at {LOAD_SCRIPT}")
            
        # Option 1: Import directly (preferred)
        from load.load import main  # Assuming load.py has main()
        main()
        
        # Option 2: Or use subprocess with container Python
        # subprocess.run(["/usr/local/bin/python", str(LOAD_SCRIPT)], check=True)
        
    except Exception as e:
        logging.error(f"Load failed: {e}")
        raise

def run_dbt_transformations():
    """Run dbt transformations"""
    try:
        if not (DBT_DIR / "profiles.yml").exists():
            raise FileNotFoundError(f"profiles.yml not found in {DBT_DIR}")
            
        logging.info(f"Running dbt in {DBT_DIR}")
        subprocess.run(
            ["dbt", "run", "--profiles-dir", str(DBT_DIR)],
            check=True,
            cwd=str(DBT_DIR)  # Run from dbt directory
        )
    except Exception as e:
        logging.error(f"dbt failed: {e}")
        raise

load_task = PythonOperator(
    task_id='load_data_to_bigquery',
    python_callable=load_data_to_bigquery,
    dag=dag,
)

dbt_task = PythonOperator(
    task_id='run_dbt_transformations',
    python_callable=run_dbt_transformations,
    dag=dag,
)

load_task >> dbt_task