#!/usr/bin/env bash
# ==============================================================
#  PASO 5 y 6 · Configurar GeoServer por API REST (PLAN B)
#  Hace exactamente lo mismo que los clics del panel web:
#  workspace -> data store PostGIS -> capas -> estilos -> límites WFS
#
#  En clase se recomienda hacerlo EN VIVO desde el panel web
#  y dejar este script como respaldo por si algo falla.
#
#  Uso:  bash infra/scripts/05_configurar_geoserver.sh
# ==============================================================
source "$(dirname "$0")/_comun.sh"

GS="${GS_URL:-http://127.0.0.1:8080/geoserver}"
AUTH="admin:$GS_ADMIN_PASS"
WS="$GS_WORKSPACE"
ST="$GS_STORE"

rest () {  # método ruta [curl args...]  -> imprime código HTTP
  local m=$1 p=$2; shift 2
  curl -s -o /tmp/gs_resp.txt -w "%{http_code}" -u "$AUTH" -X "$m" "$GS/rest$p" "$@"
}
ok () { case "$1" in 200|201) echo "ok";; *) echo "FALLÓ ($1): $(head -c 300 /tmp/gs_resp.txt)";; esac; }

echo "==> Comprobando acceso a la API REST"
c=$(rest GET /about/version.json); [ "$c" = "200" ] || { echo "No hay acceso ($c). ¿Contraseña de admin correcta en .env?"; exit 1; }
jq -r '.about.resource[] | select(."@name"=="GeoServer") | "   GeoServer " + .Version' /tmp/gs_resp.txt 2>/dev/null || true

echo -n "==> 1. Workspace '$WS': "
if [ "$(rest GET /workspaces/$WS.json)" = "200" ]; then echo "ya existe"; else
  ok "$(rest POST /workspaces -H 'Content-Type: application/json' \
        -d "{\"workspace\":{\"name\":\"$WS\"}}")"
fi

echo -n "==> 2. Data Store PostGIS '$ST': "
STORE_JSON=$(cat <<EOF
{"dataStore":{"name":"$ST","description":"PostGIS sig_caqueta (usuario solo lectura)",
 "connectionParameters":{"entry":[
  {"@key":"dbtype","\$":"postgis"},
  {"@key":"host","\$":"${DB_HOST:-localhost}"},
  {"@key":"port","\$":"5432"},
  {"@key":"database","\$":"$DB_NAME"},
  {"@key":"schema","\$":"public"},
  {"@key":"user","\$":"$DB_APP_USER"},
  {"@key":"passwd","\$":"$DB_APP_PASS"},
  {"@key":"Expose primary keys","\$":"true"},
  {"@key":"Loose bbox","\$":"true"}
 ]}}}
EOF
)
if [ "$(rest GET /workspaces/$WS/datastores/$ST.json)" = "200" ]; then echo "ya existe"; else
  ok "$(rest POST /workspaces/$WS/datastores -H 'Content-Type: application/json' -d "$STORE_JSON")"
fi

echo "==> 3. Estilos SLD"
for sld in geoserver/estilos/*.sld; do
  name=$(basename "$sld" .sld)
  echo -n "   - $name: "
  if [ "$(rest GET /workspaces/$WS/styles/$name.json)" = "200" ]; then
    ok "$(rest PUT /workspaces/$WS/styles/$name -H 'Content-Type: application/vnd.ogc.sld+xml' --data-binary @"$sld")"
  else
    ok "$(rest POST "/workspaces/$WS/styles?name=$name" -H 'Content-Type: application/vnd.ogc.sld+xml' --data-binary @"$sld")"
  fi
done

echo "==> 4. Publicar capas (tabla -> título -> estilo)"
publicar () {  # tabla título estilo
  local t=$1 title=$2 style=$3
  echo -n "   - $WS:$t: "
  if [ "$(rest GET /workspaces/$WS/datastores/$ST/featuretypes/$t.json)" != "200" ]; then
    c=$(rest POST /workspaces/$WS/datastores/$ST/featuretypes -H 'Content-Type: application/json' \
        -d "{\"featureType\":{\"name\":\"$t\",\"nativeName\":\"$t\",\"title\":\"$title\",\"srs\":\"EPSG:4326\",\"projectionPolicy\":\"FORCE_DECLARED\",\"enabled\":true}}")
    [ "$c" = "201" ] || { ok "$c"; return; }
  fi
  ok "$(rest PUT /layers/$WS:$t -H 'Content-Type: application/json' \
        -d "{\"layer\":{\"defaultStyle\":{\"name\":\"$style\",\"workspace\":\"$WS\"}}}")"
}
publicar municipios               "Municipios del Caquetá (DANE MGN)"        municipios
publicar zonas_riesgo             "Zonas de riesgo (demo)"                  zonas_riesgo
publicar vias                     "Vías principales (esquemático)"          vias
publicar hospitales               "Hospitales y centros de salud (demo)"    hospitales
publicar instituciones_educativas "Instituciones educativas (demo)"         instituciones_educativas
publicar v_hospitales_en_riesgo   "Hospitales en zona de riesgo (consulta)" hospitales_riesgo

echo -n "==> 5. Limitar WFS a 5000 entidades por petición: "
ok "$(rest PUT /services/wfs/settings -H 'Content-Type: application/json' -d '{"wfs":{"maxFeatures":5000}}')"

echo
echo "LISTO. Revisa en el panel: Layer Preview -> $WS:municipios -> OpenLayers"
echo "Prueba rápida:  bash infra/scripts/07_verificar.sh"
