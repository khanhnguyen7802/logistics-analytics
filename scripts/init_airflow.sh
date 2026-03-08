#!/usr/bin/env bash
set -euo pipefail

echo "Starting Airflow initialization..."

# --------------------------------------------------
# 1. Ensure AIRFLOW_UID exists
# --------------------------------------------------

if [[ -z "${AIRFLOW_UID:-}" ]]; then
  echo "AIRFLOW_UID not set. Using current user id."
  export AIRFLOW_UID=$(id -u)
fi

echo "Using AIRFLOW_UID=${AIRFLOW_UID}"

# --------------------------------------------------
# 2. Check system resources (optional but useful)
# --------------------------------------------------

MIN_MEM_MB=4000
MIN_CPUS=2
MIN_DISK_MB=10240

MEM_MB=$(($(getconf _PHYS_PAGES) * $(getconf PAGE_SIZE) / 1048576))
CPUS=$(grep -cE 'cpu[0-9]+' /proc/stat)
DISK_MB=$(df / | tail -1 | awk '{print int($4/1024)}')

echo "Detected resources:"
echo "Memory: ${MEM_MB} MB"
echo "CPUs: ${CPUS}"
echo "Disk: ${DISK_MB} MB"

if (( MEM_MB < MIN_MEM_MB )); then
  echo "WARNING: Less than ${MIN_MEM_MB}MB RAM available."
fi

if (( CPUS < MIN_CPUS )); then
  echo "WARNING: Less than ${MIN_CPUS} CPUs available."
fi

if (( DISK_MB < MIN_DISK_MB )); then
  echo "WARNING: Less than ${MIN_DISK_MB}MB disk available."
fi

# --------------------------------------------------
# 3. Create Airflow directories
# --------------------------------------------------

AIRFLOW_PROJECT=/opt/airflow/logistics_analytics_project
PIPELINES_DIR=${AIRFLOW_PROJECT}/pipelines

echo "Creating Airflow directories..."

mkdir -p \
  ${PIPELINES_DIR}/dags \
  ${PIPELINES_DIR}/config \
  ${PIPELINES_DIR}/logs \
  ${PIPELINES_DIR}/plugins

# --------------------------------------------------
# 4. Fix file permissions
# --------------------------------------------------

# Change ownership of the newly created directories to ${AIRFLOW_UID}:0"
echo "Setting ownership to ${AIRFLOW_UID}:0"

chown -R "${AIRFLOW_UID}:0" ${PIPELINES_DIR} || true

# --------------------------------------------------
# 5. Initialize Airflow configuration and Database
# --------------------------------------------------

echo "Generating Airflow config and migrating database..."

/entrypoint airflow config list

# --------------------------------------------------
# 6. Show environment info
# --------------------------------------------------

echo "Airflow version:"
/entrypoint airflow version

echo
echo "Directory structure:"
ls -la ${PIPELINES_DIR}


# --------------------------------------------------
# 7. Fix folder permissions
# --------------------------------------------------

# Change ownership of the newly created directories to ${AIRFLOW_UID}:0"
echo "Setting ownership to ${AIRFLOW_UID}:0"

chown -R "${AIRFLOW_UID}:0" ${AIRFLOW_PROJECT} || true


echo
echo "Airflow initialization complete."