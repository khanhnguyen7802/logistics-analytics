import os
import sys
import subprocess
from datetime import datetime
from pathlib import Path
from airflow.sdk import dag, task

# Add project root to Python path so scripts module can be imported
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
sys.path.insert(0, PROJECT_ROOT)
# DBT_PROJECT_DIR = Path(PROJECT_ROOT) / 'dbt' / 'logistics_analytics'
# DBT_PROFILES_DIR = Path(PROJECT_ROOT) / '.dbt'


# def run_dbt_command(args: list[str]) -> str:
#     env = os.environ.copy()
#     env['DBT_PROFILES_DIR'] = str(DBT_PROFILES_DIR)

#     result = subprocess.run(
#         ['dbt', *args],
#         cwd=str(DBT_PROJECT_DIR),
#         capture_output=True,
#         text=True,
#         check=False,
#         env=env,
#     )

#     if result.returncode != 0:
#         raise RuntimeError(
#             f"dbt command failed: {' '.join(args)}\n"
#             f"STDOUT:\n{result.stdout}\nSTDERR:\n{result.stderr}"
#         )

#     return result.stdout

# Create DAG
@dag(
    dag_id='my_pipeline',
    start_date=datetime(2026, 3, 8),
    schedule=None,
    catchup=False,
    description='ingest data and run dbt models',
    tags=['data-pipeline'],
)
def my_dag():

    @task(task_id='ingest_data', retries=1)
    def task_ingest_data(**context):
      from scripts.ingest import convert_to_parquet
      
      try:
        convert_to_parquet()
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

    # @task(task_id='dbt_deps', retries=1)
    # def task_dbt_deps(**context):
    #   try:
    #       output = run_dbt_command(['deps'])
    #       return f"dbt deps completed successfully\n{output}"
    #   except Exception as e:
    #       raise Exception(f"Error in task_dbt_deps: {str(e)}") from e

    # @task(task_id='dbt_run', retries=1)
    # def task_dbt_run(**context):
    #   try:
    #       output = run_dbt_command(['run'])
    #       return f"dbt run completed successfully\n{output}"
    #   except Exception as e:
    #       raise Exception(f"Error in task_dbt_run: {str(e)}") from e

    # @task(task_id='dbt_test', retries=1)
    # def task_dbt_test(**context):
    #   try:
    #       output = run_dbt_command(['test'])
    #       return f"dbt test completed successfully\n{output}"
    #   except Exception as e:
    #       raise Exception(f"Error in task_dbt_test: {str(e)}") from e

    # Set dependencies
    task_ingest_data() >> task_create_duckdb_table()
    # task_ingest_data() >> task_create_duckdb_table() >> task_dbt_deps() >> task_dbt_run() >> task_dbt_test()

my_dag()