import duckdb
from pathlib import Path




# get the project root directory by using marker file 
def get_project_root():
    """Find project root by looking for docker-compose.yaml or .git"""
    current = Path(__file__).resolve()
    for parent in current.parents:
        if (parent / 'docker-compose.yaml').exists() or (parent / '.git').exists():
            return parent
    return current.parent  # fallback

BASE_DIR = get_project_root()
DATA_CSV_PATH = BASE_DIR / 'data' / 'logistics_data.csv'
DATA_PARQUET_PATH = BASE_DIR / 'data' / 'logistics_data.parquet'


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

    print(f"✅ Completed converting into {DATA_PARQUET_PATH}")

def create_duckdb_table():
  con = duckdb.connect("logistics_tracking.duckdb")
  con.execute("CREATE SCHEMA IF NOT EXISTS raw")

  con.execute(f"""
      CREATE OR REPLACE TABLE raw.tracking_data AS
      SELECT * FROM read_parquet('{DATA_PARQUET_PATH}')
      """)

  con.close()


if __name__ == "__main__":
  convert_files()
  create_duckdb_table()
