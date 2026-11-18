#!/usr/bin/env bash
# ==============================================================
#  PASO 3.1 / 3.2 · Importar las capas a PostGIS y validarlas
#  Uso:  bash infra/scripts/03_importar_datos.sh
# ==============================================================
source "$(dirname "$0")/_comun.sh"
DB_HOST="${DB_HOST:-localhost}"

export PGPASSWORD="$DB_OWNER_PASS"

# Esperar a que PostgreSQL acepte conexiones (máx. 2 minutos)
for i in $(seq 1 60); do
  pg_isready -q -h "$DB_HOST" -U "$DB_OWNER" -d "$DB_NAME" && break
  [ "$i" = 1 ] && echo "==> Esperando a PostgreSQL en $DB_HOST ..."
  sleep 2
done
PG="PG:host=$DB_HOST dbname=$DB_NAME user=$DB_OWNER password=$DB_OWNER_PASS"

importar () {   # $1 = archivo, $2 = tabla, $3 = tipo de geometría
  echo "   -> $2"
  ogr2ogr -f PostgreSQL "$PG" "datos/$1" \
    -nln "$2" -nlt "$3" -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geom -lco FID=id -lco SPATIAL_INDEX=GIST \
    -overwrite
}

echo "==> Importando GeoJSON a PostGIS con ogr2ogr"
# la vista depende de las tablas: se borra antes de re-importar (se recrea abajo)
psql -h "$DB_HOST" -U "$DB_OWNER" -d "$DB_NAME" -q -c "DROP VIEW IF EXISTS v_hospitales_en_riesgo;"
importar municipios.geojson               municipios               MULTIPOLYGON
importar zonas_riesgo.geojson             zonas_riesgo             MULTIPOLYGON
importar vias.geojson                     vias                     LINESTRING
importar hospitales.geojson               hospitales               POINT
importar instituciones_educativas.geojson instituciones_educativas POINT

echo "==> Vista espacial para la demo y permisos de lectura"
psql -h "$DB_HOST" -U "$DB_OWNER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -v app="$DB_APP_USER" -f db/02_vistas.sql

echo "==> Validando geometrías, SRID e índices"
psql -h "$DB_HOST" -U "$DB_OWNER" -d "$DB_NAME" -f db/03_validar.sql

echo
echo "LISTO. Prueba las consultas con:"
echo "  psql -h "$DB_HOST" -U $DB_OWNER -d $DB_NAME -f db/04_consultas_demo.sql"
