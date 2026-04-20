#!/usr/bin/env bash
set -euo pipefail

# If running locally, allow loading variables from a .env file.
if [ -f ".env" ]; then
	set -a
	source .env
	set +a
	echo "[INFO] Loaded variables from .env"
fi

REQUIRED_VARS=(
	"DATABASE_HOST"
	"DATABASE_PORT"
	"POSTGRES_USER"
	"POSTGRES_PASSWORD"
	"DATABASE_USER"
	"DATABASE_PASSWORD"
	"DATABASE_DB"
	"EXAMPLES_USER"
	"EXAMPLES_PASSWORD"
	"EXAMPLES_DB"
)

MISSING=()
for VAR in "${REQUIRED_VARS[@]}"; do
	if [ -z "${!VAR:-}" ]; then
		MISSING+=("$VAR")
	fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
	echo "[ERROR] Missing required environment variables:" >&2
	for VAR in "${MISSING[@]}"; do
		echo "  - $VAR" >&2
	done
	exit 1
fi

echo "[INFO] All required environment variables present"

echo "[INFO] Waiting for Postgres at ${DATABASE_HOST}:${DATABASE_PORT}..."
MAX_RETRIES=10
RETRY_INTERVAL=2
COUNT=0

until PGPASSWORD="${POSTGRES_PASSWORD}" psql \
	-h "${DATABASE_HOST}" \
	-p "${DATABASE_PORT}" \
	-U "${POSTGRES_USER}" \
	-d postgres \
	-tAc "SELECT 1" >/dev/null 2>&1; do

	COUNT=$((COUNT + 1))
	if [ "${COUNT}" -ge "${MAX_RETRIES}" ]; then
		echo "[ERROR] Postgres not reachable after ${MAX_RETRIES} retries. Exiting." >&2
		exit 1
	fi
	echo "[INFO] Postgres not ready yet. Retry ${COUNT}/${MAX_RETRIES}..."
	sleep "${RETRY_INTERVAL}"
done

echo "[INFO] Postgres is ready"

run_query() {
	local QUERY="$1" # first argument
	local DB="${2:-postgres}" # second argument; if none passed, default to 'postgres'

	PGPASSWORD="${POSTGRES_PASSWORD}" psql \
		-h "${DATABASE_HOST}" \
		-p "${DATABASE_PORT}" \
		-U "${POSTGRES_USER}" \
		-d "${DB}" \
		-v ON_ERROR_STOP=1 \
		-c "${QUERY}" # the query to run
}




# CREATE SUPERSET USER AND DATABASE AND GRANT PRIVILEGES
echo "[INFO] Creating or updating user '${DATABASE_USER}'..."
## CREATE SUPERSET USER 
run_query "
DO \$\$
BEGIN
	IF NOT EXISTS (
		SELECT 1 FROM pg_catalog.pg_roles
		WHERE rolname = '${DATABASE_USER}'
	) THEN
		CREATE ROLE ${DATABASE_USER} LOGIN PASSWORD '${DATABASE_PASSWORD}'
		NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
	ELSE
		ALTER ROLE ${DATABASE_USER} WITH LOGIN PASSWORD '${DATABASE_PASSWORD}'
		NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
	END IF;
END
\$\$;
"
## CREATE SUPERSET DATABASE
echo "[INFO] Creating database '${DATABASE_DB}' if not exists..."
DB_EXISTS=$(PGPASSWORD="${POSTGRES_PASSWORD}" psql \
	-h "${DATABASE_HOST}" \
	-p "${DATABASE_PORT}" \
	-U "${POSTGRES_USER}" \
	-d postgres \
	-tAc "SELECT 1 FROM pg_database WHERE datname='${DATABASE_DB}'") # format to return only the value of the query

if [ "${DB_EXISTS}" != "1" ]; then
	run_query "CREATE DATABASE ${DATABASE_DB} OWNER ${DATABASE_USER};"
	echo "[INFO] Database '${DATABASE_DB}' created"
else
	echo "[INFO] Database '${DATABASE_DB}' already exists, skipping"
fi

run_query "ALTER DATABASE ${DATABASE_DB} OWNER TO ${DATABASE_USER};"
## GRANT PRIVILEGES TO SUPERSET USER
echo "[INFO] Granting privileges to '${DATABASE_USER}' on '${DATABASE_DB}'..."
run_query "GRANT ALL PRIVILEGES ON DATABASE ${DATABASE_DB} TO ${DATABASE_USER};"
run_query "
GRANT ALL ON SCHEMA public TO ${DATABASE_USER};
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${DATABASE_USER};
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${DATABASE_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL ON TABLES TO ${DATABASE_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL ON SEQUENCES TO ${DATABASE_USER};
" "${DATABASE_DB}"





# CREATE 'EXAMPLES' USER AND DATABASE AND GRANT PRIVILEGES
echo "[INFO] Creating or updating user '${EXAMPLES_USER}'..."
run_query "
DO \$\$
BEGIN
	IF NOT EXISTS (
		SELECT 1 FROM pg_catalog.pg_roles
		WHERE rolname = '${EXAMPLES_USER}'
	) THEN
		CREATE ROLE ${EXAMPLES_USER} LOGIN PASSWORD '${EXAMPLES_PASSWORD}'
		NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
	ELSE
		ALTER ROLE ${EXAMPLES_USER} WITH LOGIN PASSWORD '${EXAMPLES_PASSWORD}'
		NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
	END IF;
END
\$\$;
"

echo "[INFO] Creating database '${EXAMPLES_DB}' if not exists..."
EXAMPLES_DB_EXISTS=$(PGPASSWORD="${POSTGRES_PASSWORD}" psql \
	-h "${DATABASE_HOST}" \
	-p "${DATABASE_PORT}" \
	-U "${POSTGRES_USER}" \
	-d postgres \
	-tAc "SELECT 1 FROM pg_database WHERE datname='${EXAMPLES_DB}'")

if [ "${EXAMPLES_DB_EXISTS}" != "1" ]; then
	run_query "CREATE DATABASE ${EXAMPLES_DB} OWNER ${EXAMPLES_USER};"
	echo "[INFO] Database '${EXAMPLES_DB}' created"
else
	echo "[INFO] Database '${EXAMPLES_DB}' already exists, skipping"
fi

run_query "ALTER DATABASE ${EXAMPLES_DB} OWNER TO ${EXAMPLES_USER};"

echo "[INFO] Granting privileges to '${EXAMPLES_USER}' on '${EXAMPLES_DB}'..."
run_query "GRANT ALL PRIVILEGES ON DATABASE ${EXAMPLES_DB} TO ${EXAMPLES_USER};"
run_query "
GRANT ALL ON SCHEMA public TO ${EXAMPLES_USER};
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${EXAMPLES_USER};
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${EXAMPLES_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public
	GRANT ALL ON TABLES TO ${EXAMPLES_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public
	GRANT ALL ON SEQUENCES TO ${EXAMPLES_USER};
" "${EXAMPLES_DB}"

echo "[INFO] Verifying setup..."
run_query "
SELECT
	r.rolname AS role_name,
	d.datname AS database_name,
	r.rolsuper AS is_superuser,
	r.rolcreatedb AS can_create_db
FROM pg_catalog.pg_roles r
JOIN pg_catalog.pg_database d ON d.datdba = r.oid
WHERE r.rolname IN ('${DATABASE_USER}', '${EXAMPLES_USER}')
ORDER BY r.rolname, d.datname;
"

echo "[SUCCESS] Postgres initialization complete"
