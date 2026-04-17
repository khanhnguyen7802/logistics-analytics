from datetime import datetime

from airflow.sdk import dag, task
from logistics_analytics.ingest import convert_to_parquet, create_duckdb_table

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

    @task(task_id='ingest_data')
    def task_ingest_data():
      try:
        conversion = convert_to_parquet()
        return conversion
      except Exception as e:
        raise Exception(f"Error in task_ingest_data: {str(e)}") from e

    @task(task_id='create_duckdb_table')
    def task_create_duckdb_table():
      try:
          create_duckdb_table()
          return "DuckDB table created successfully"
      except Exception as e:
          raise Exception(f"Error in task_create_duckdb_table: {str(e)}") from e

    # Set dependencies
    task_ingest_data() >> task_create_duckdb_table()
    # task_ingest_data() >> task_create_duckdb_table() >> task_dbt_deps() >> task_dbt_run() >> task_dbt_test()

my_dag()