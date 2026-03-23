import pandas as pd
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
DATA_EXCEL_PATH = BASE_DIR / 'data' / 'transportation_logistics_tracking_dataset.xlsx'
DATA_PARQUET_PATH = BASE_DIR / 'data' / 'logistics_data.parquet'

def read_excel_file():

  xl = pd.ExcelFile(DATA_EXCEL_PATH)
  print("Sheets found:", xl.sheet_names)


  df = pd.read_excel(
      DATA_EXCEL_PATH,
      sheet_name="Primary Data",
      parse_dates=["Booking Date", "Data Ping time", "Planned ETA", "Actual ETA", "Trip Start Date", "Trip End Date"],
  )

  print(f"\nLoaded {len(df):} rows!")

  return df 



def convert_to_parquet():
  df = read_excel_file()

  print(f"Converting  to parquet file ...")
  
  parquet_path = Path(DATA_PARQUET_PATH)

  if parquet_path.is_file():
    print("File already existed!")
  else:
    df.to_parquet(DATA_PARQUET_PATH, index=False, engine="pyarrow")
    print(f"\n Saved to '{DATA_PARQUET_PATH}'")

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
  convert_to_parquet()
  create_duckdb_table()
