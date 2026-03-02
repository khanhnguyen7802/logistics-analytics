import duckdb
from pathlib import Path


DATA_CSV_PATH = '.\data\logistics_data.csv'
DATA_PARQUET_PATH = '.\data\logistics_data.parquet'
def convert_files():
    
  print(f"Converting csv to parquet...")
  
  parquet_path = Path(DATA_PARQUET_PATH)

  if parquet_path.is_file():
    print("File already existed!")
  else: 
    con = duckdb.connect()
    con.execute(f"""
          COPY (SELECT * FROM read_csv_auto('{DATA_CSV_PATH}'))
          TO '{DATA_PARQUET_PATH}' (FORMAT PARQUET)
      """)
    con.close()

    print(f"Completed {DATA_PARQUET_PATH}")


if __name__ == "__main__":
  
  con = duckdb.connect("logistics_tracking.duckdb")
  con.execute("CREATE SCHEMA IF NOT EXISTS raw")

  con.execute(f"""
      CREATE OR REPLACE TABLE raw.primary_data AS
      SELECT * FROM read_parquet('{DATA_PARQUET_PATH}')
      """)

  con.close()