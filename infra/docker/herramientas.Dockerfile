# ==============================================================
#  Imagen de herramientas: GDAL (ogr2ogr) + cliente PostgreSQL + curl
#  La usan los servicios "importador" y "configurador" del compose.
# ==============================================================
FROM ghcr.io/osgeo/gdal:ubuntu-small-latest
RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-client curl jq ca-certificates \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /proyecto
