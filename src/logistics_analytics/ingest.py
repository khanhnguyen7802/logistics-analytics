"""Data ingestion helpers for logistics analytics workflows."""

import os
from pathlib import Path

import duckdb
import pandas as pd


PRIMARY_SHEET_NAME = "Primary Data"
PARSE_DATE_COLUMNS = [
    "Booking Date",
    "Data Ping time",
    "Planned ETA",
    "Actual ETA",
    "Trip Start Date",
    "Trip End Date",
]


def get_project_root() -> Path:
  """Find project root by override env var, docker-compose.yaml, or .git marker."""

  current = Path(__file__).resolve()
  for parent in current.parents:
      if (parent / "docker-compose.yaml").exists() or (parent / ".git").exists():
          return parent
  return current.parent


BASE_DIR = os.getenv("LOGISTICS_PROJECT_ROOT")
DATA_EXCEL_PATH = f"{BASE_DIR}/data/transportation_logistics_tracking_dataset.xlsx"
DATA_PARQUET_PATH = f"{BASE_DIR}/data/logistics_data.parquet"
DUCKDB_PATH = f"{BASE_DIR}/db/logistics_tracking.duckdb"


def read_excel_file() -> pd.DataFrame:
  """Read logistics source data from the Primary Data worksheet."""
  xl = pd.ExcelFile(DATA_EXCEL_PATH)
  print("Sheets found:", xl.sheet_names)

  df = pd.read_excel(
      DATA_EXCEL_PATH,
      sheet_name=PRIMARY_SHEET_NAME,
      parse_dates=PARSE_DATE_COLUMNS,
  )

  print(f"\nLoaded {len(df):} rows!")
  return df


def convert_to_parquet() -> str:
  """Convert source Excel data to parquet if it does not already exist."""
  df = read_excel_file()
  print("Converting to parquet file ...")

  if Path(DATA_PARQUET_PATH).is_file():
      print("File already existed!")
      return "Skipping conversion since parquet file already exists at: " + DATA_PARQUET_PATH
  else:
      df.to_parquet(DATA_PARQUET_PATH, index=False, engine="pyarrow")
      print(f"\nSaved to '{DATA_PARQUET_PATH}'")
      return "Completed converting into " + DATA_PARQUET_PATH
  


def create_duckdb_table() -> None:
  """Create or replace the raw tracking_data table from parquet data."""
  with duckdb.connect(str(DUCKDB_PATH)) as con:
      con.execute("CREATE SCHEMA IF NOT EXISTS raw")
      con.execute(
          f"""
          CREATE OR REPLACE TABLE raw.tracking_data AS
          SELECT * FROM read_parquet('{DATA_PARQUET_PATH}')
          """
      )


def main() -> None:
  """CLI entrypoint for ad hoc ingestion runs."""
  convert_to_parquet()
  create_duckdb_table()


if __name__ == "__main__":
  main()
