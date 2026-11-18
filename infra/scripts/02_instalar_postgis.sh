#!/usr/bin/env bash
# ==============================================================
#  PASO 3 · Instalar PostgreSQL + PostGIS y crear la base espacial
#  Uso:  sudo bash infra/scripts/02_instalar_postgis.sh
# ==============================================================
source "$(dirname "$0")/_comun.sh"

echo "==> Instalando PostgreSQL, PostGIS y GDAL (ogr2ogr)"
export DEBIAN_FRONTEND=noninteractive
apt-get install -y postgresql postgresql-contrib postgis gdal-bin
systemctl enable --now postgresql

PGVER=$(ls /etc/postgresql | sort -V | tail -1)
echo "   PostgreSQL $PGVER instalado"

echo "==> Creando roles, base de datos y extensión PostGIS"
sudo -u postgres psql -v ON_ERROR_STOP=1 \
  -v db="$DB_NAME" -v owner="$DB_OWNER" -v owner_pass="$DB_OWNER_PASS" \
  -v app="$DB_APP_USER" -v app_pass="$DB_APP_PASS" \
  -f db/01_crear_bd.sql

sudo -u postgres psql -v ON_ERROR_STOP=1 -d "$DB_NAME" \
  -c "CREATE EXTENSION IF NOT EXISTS postgis;" \
  -c "ALTER SCHEMA public OWNER TO $DB_OWNER;" \
  -c "GRANT USAGE ON SCHEMA public TO $DB_APP_USER;" \
  -c "ALTER DEFAULT PRIVILEGES FOR ROLE $DB_OWNER IN SCHEMA public GRANT SELECT ON TABLES TO $DB_APP_USER;" \
  -c "SELECT postgis_full_version();"

echo "==> PostgreSQL escucha solo en localhost (no se expone a internet)"
grep -E "^#?listen_addresses" /etc/postgresql/$PGVER/main/postgresql.conf || true

echo
echo "LISTO. Siguiente: bash infra/scripts/03_importar_datos.sh"
