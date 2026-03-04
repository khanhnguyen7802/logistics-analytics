<h1 align="center">Logistics Operation Analytics</h1>

<p align="center">
  An integrated DE + DA project building an automated data pipeline to power scalable analytics and executive-ready dashboards for logistics operations.
</p>

## About 

## Tech stack
- Dataset: provided **.csv file** (in [data/ folder](./data/logistics_data.csv))
- Database: [DuckDB](https://duckdb.org/) 
- Orchestration: [Airflow](https://airflow.apache.org/)
- Data transformation: [dbt](https://www.getdbt.com/) *(data build tool)*
- Visualization: [Apache Superset](https://superset.apache.org/) 
- Containerization: Docker

## Architecture

## Setup 

## 

dbt_project.yml
├── models/
│   ├── staging/
│   │   └── stg_raw_trips.sql (deduplication, type casting)
│   ├── marts/
│   │   ├── dimensions/
│   │   │   ├── dim_vehicles.sql
│   │   │   ├── dim_drivers.sql
│   │   │   ├── dim_customers.sql
│   │   │   ├── dim_suppliers.sql
│   │   │   ├── dim_locations.sql
│   │   │   └── dim_materials.sql
│   │   └── facts/
│   │       └── fct_trips.sql
│   └── sources.yml (define raw Parquet as source)
└── tests/


1. trips (FACT TABLE - Core transactional)
   - booking_id (PK)
   - booking_date, trip_start_date, trip_end_date
   - vehicle_id (FK)
   - driver_id (FK)
   - customer_id (FK)
   - supplier_id (FK)
   - origin_location_id (FK)
   - destination_location_id (FK)
   - material_id (FK)
   - shipment_type
   - transportation_distance_km
   - planned_eta, actual_eta
   - ontime (Yes/No)

2. vehicles (DIMENSION)
   - vehicle_id (PK)
   - vehicle_registration
   - vehicle_type
   - minimum_kms_per_day

3. drivers (DIMENSION)
   - driver_id (PK)
   - driver_name
   - driver_mobile_no

4. customers (DIMENSION)
   - customer_id (PK)
   - customer_name

5. suppliers (DIMENSION)
   - supplier_id (PK)
   - supplier_name

6. locations (DIMENSION)
   - location_id (PK)
   - location_name
   - latitude
   - longitude

7. materials (DIMENSION)
   - material_id (PK)
   - material_name

8. gps_tracking (FACT TABLE - Real-time tracking)
   - tracking_id (PK)
   - booking_id (FK)
   - gps_provider
   - data_ping_time
   - current_location
   - current_latitude, current_longitude