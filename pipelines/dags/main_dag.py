import os
import sys
from datetime import datetime
from airflow.sdk import dag, task

# Add project root to Python path so scripts module can be imported
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
sys.path.insert(0, PROJECT_ROOT)

# Create DAG
@dag(
    dag_id='my_pipeline',
    start_date=datetime(2026, 3, 8),
    schedule='@hourly',
    catchup=False,
    description='ingest data and run dbt models',
    tags=['data-pipeline'],
)
def my_dag():

    @task(task_id='ingest_data', retries=1)
    def task_ingest_data(**context):
      from scripts.ingest import convert_files

      try:
          convert_files()
          return "Data ingestion completed successfully"
      except Exception as e:
          raise Exception(f"Error in task_ingest_data: {str(e)}") from e

    @task(task_id='create_duckdb_table', retries=1)
    def task_create_duckdb_table(**context):
      from scripts.ingest import create_duckdb_table

      try:
          create_duckdb_table()
          return "✅ DuckDB table created successfully"
      except Exception as e:
          raise Exception(f"Error in task_create_duckdb_table: {str(e)}") from e

    # Set dependencies
    task_ingest_data() >> task_create_duckdb_table()

my_dag()