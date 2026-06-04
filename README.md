<h1 align="center">Logistics Operation Analytics</h1>

<p align="center">
  An integrated DE + DA project building an automated data pipeline to power scalable analytics and executive-ready dashboards for logistics operations.
</p>

## About

## Tech stack

- Dataset: provided **Excel file** (in [data/ folder](./data/logistics_data.csv))
- Database: [DuckDB](https://duckdb.org/)
- Orchestration: [Airflow](https://airflow.apache.org/)
- Data transformation: [dbt](https://www.getdbt.com/) _(data build tool)_
- Visualization: [Apache Superset](https://superset.apache.org/)
- Containerization: Docker

## Architecture

### Runtime services

- Airflow (`airflow-apiserver`, `airflow-scheduler`, `airflow-dag-processor`) orchestrates ingestion and dbt tasks.
- Postgres (`postgres`) stores Airflow and Superset metadata.
- dbt (`dbt`) provides transformation runtime and project dependencies.
- Superset (`superset-init`, `superset`) initializes and serves BI dashboards.

### End-to-end flow

1. Start the services using Docker. The services include: Airflow, Postgres, Duckdb and dbt. 
2. `Airflow` will be responsible for automating ingestion:
    - ingest data from Excel file
    - convert into parquet file 
    - create duckdb database

    When starting Airflow-related services, the script `airflow-init.sh` is triggered to initialize Airflow credentials, to create required DAG folders and to set appropriate ownership. 


3. `dbt` then transforms the data. The models are already defined, so Airflow just needs to execute `dbt deps`, `dbt run`, and `dbt test` to actually create those models inside duckdb database. 
4. As soon as we have everything in the databse (i.e., **.duckdb**), `Superset` will initialize metadata, create admin account, and start web UI.
    > Superset connects to DuckDB at `duckdb:////workspace/logistics_tracking.duckdb`.

Superset dashboard can be seen as below: 

![alt text](logistics-overview-superset.jpg)

## Setup

### 1) Configure environment
Since this is only for learning purpose, you can just copy my whole `.env` file and put into the root folder

```bash
LOGISTICS_PROJECT_ROOT=/opt/airflow/logistics_analytics_project

AIRFLOW_UID=50000
AIRFLOW_PROJ_DIR=.
_AIRFLOW_WWW_USER_USERNAME=airflow
_AIRFLOW_WWW_USER_PASSWORD=airflow


# Make sure you set this to a unique secure random value on production
DATABASE_USER=superset
DATABASE_PASSWORD=superset
POSTGRES_USER=superset
POSTGRES_PASSWORD=superset
EXAMPLES_USER=examples
EXAMPLES_PASSWORD=examples


SUPERSET_ADMIN_USERNAME=admin
SUPERSET_ADMIN_PASSWORD=admin
SUPERSET_ADMIN_FIRSTNAME=Superset
SUPERSET_ADMIN_LASTNAME=Admin
SUPERSET_ADMIN_EMAIL=admin@superset.com
SUPERSET__SQLALCHEMY_DATABASE_URI=postgresql+psycopg2://airflow:airflow@postgres/superset
SUPERSET_DB_SCHEMA=marts
SUPERSET_DASHBOARD_TITLE=Logistics Executive Risk Dashboard
SUPERSET_METADATA_DB_URI=postgresql+psycopg2://airflow:airflow@postgres/superset

```

### 2) Build and start the stack

```bash
docker compose up --build -d
```

### 3) Access services

- Airflow UI: `http://localhost:8080`
- Superset UI: `http://localhost:8088`
- Duckdb UI: `http://localhost:4123`

### 4) Run the pipeline

Trigger DAG `my_pipeline` in Airflow to execute:

1. `ingest_data`
2. `create_duckdb_table`
3. `dbt_deps`
4. `dbt_run`
5. `dbt_test`

### 5) Expected output datasets for BI
As soon as you have the .duckdb database, you can access Superset UI and then add the database into Superset to start building dashboards.
