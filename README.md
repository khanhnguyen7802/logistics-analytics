<h1 align="center">Logistics Operation Analytics</h1>

<p align="center">
  An integrated DE + DA project building an automated data pipeline to power scalable analytics and executive-ready dashboards for logistics operations.
</p>

## About

## Tech stack

- Dataset: provided **.csv file** (in [data/ folder](./data/logistics_data.csv))
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

1. Airflow runs ingestion from CSV to parquet and then to DuckDB raw schema.
2. Airflow executes `dbt deps`, `dbt run`, and `dbt test`.
3. Superset initializes metadata, creates admin account, and starts web UI.
4. Superset connects to DuckDB at `duckdb:////workspace/logistics_tracking.duckdb`.

## Setup

### 1) Configure environment

Copy `.env.example` to `.env` and adjust credentials as needed.

### 2) Build and start the stack

```bash
docker compose up --build -d
```

### 3) Access services

- Airflow UI: `http://localhost:8080`
- Superset UI: `http://localhost:8088`

### 4) Run the pipeline

Trigger DAG `my_pipeline` in Airflow to execute:

1. `ingest_data`
2. `create_duckdb_table`
3. `dbt_deps`
4. `dbt_run`
5. `dbt_test`

### 5) Expected output datasets for BI

Superset should query dashboard-serving marts:

- `marts.agg_exec_summary`
- `marts.agg_problem_on_time`
- `marts.agg_problem_routes`
- `marts.agg_problem_supplier_route`
- `marts.agg_problem_vehicle_utilization`
