#!/usr/bin/env bash
# Espera a que la API REST de GeoServer responda y aplica la configuración
# (workspace, data store, capas y estilos) con infra/scripts/05_configurar_geoserver.sh
set -euo pipefail
: "${GS_URL:?falta GS_URL}" "${GS_ADMIN_PASS:?falta GS_ADMIN_PASS}"
echo "Esperando a GeoServer en $GS_URL ..."
for i in $(seq 1 90); do
  code=$(curl -s -o /dev/null -w "%{http_code}" -u "admin:$GS_ADMIN_PASS" "$GS_URL/rest/about/version.json" || true)
  [ "$code" = "200" ] && break
  sleep 5
done
[ "$code" = "200" ] || { echo "GeoServer no respondió (último código: $code)"; exit 1; }
exec bash "$(dirname "$0")/../scripts/05_configurar_geoserver.sh"
