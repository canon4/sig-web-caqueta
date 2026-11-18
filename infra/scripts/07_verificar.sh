#!/usr/bin/env bash
# ==============================================================
#  Pruebas clave (diapositiva 15): GetCapabilities, GetMap, GetFeature
#  Uso:  bash infra/scripts/07_verificar.sh                 (dentro del servidor)
#        BASE=http://IP_PUBLICA bash infra/scripts/07_verificar.sh   (desde afuera)
# ==============================================================
source "$(dirname "$0")/_comun.sh"
set +e   # las pruebas cuentan fallos en lugar de detenerse
BASE="${BASE:-http://127.0.0.1}"
WS="$GS_WORKSPACE"
OWS="$BASE/geoserver/$WS/ows"
pass=0; fail=0

prueba () {  # descripción url patrón_esperado
  local out; out=$(curl -s --max-time 30 "$2")
  if echo "$out" | grep -q "$3"; then echo "  [OK]    $1"; pass=$((pass+1));
  else echo "  [FALLA] $1"; echo "          $2"; echo "          -> $(echo "$out" | head -c 200)"; fail=$((fail+1)); fi
}
prueba_img () {
  local t; t=$(curl -s --max-time 30 -o /tmp/getmap.png -w "%{content_type}" "$2")
  if [ "$t" = "image/png" ]; then echo "  [OK]    $1 ($(stat -c %s /tmp/getmap.png) bytes)"; pass=$((pass+1));
  else echo "  [FALLA] $1 (content-type: $t)"; echo "          -> $(head -c 200 /tmp/getmap.png)"; fail=$((fail+1)); fi
}

echo "== Servicios en $BASE =="
prueba "Visor web (index.html)"            "$BASE/"  "SIG Web"
# en la URL del workspace, WMS lista las capas sin prefijo (<Name>municipios</Name>)
prueba "WMS GetCapabilities lista capas"   "$OWS?service=WMS&version=1.3.0&request=GetCapabilities" "municipios</Name>"
prueba_img "WMS GetMap devuelve PNG"       "$OWS?service=WMS&version=1.1.1&request=GetMap&layers=$WS:municipios,$WS:zonas_riesgo,$WS:vias&styles=&bbox=-76.4,-0.8,-71.2,3.0&width=800&height=600&srs=EPSG:4326&format=image/png"
prueba "WFS GetCapabilities"               "$OWS?service=WFS&version=2.0.0&request=GetCapabilities" "$WS:hospitales"
prueba "WFS GetFeature hospitales (GeoJSON)" "$OWS?service=WFS&version=1.0.0&request=GetFeature&typeName=$WS:hospitales&outputFormat=application/json" '"FeatureCollection"'
prueba "WFS filtro CQL (Florencia)"        "$OWS?service=WFS&version=1.0.0&request=GetFeature&typeName=$WS:hospitales&outputFormat=application/json&CQL_FILTER=municipio%3D%27Florencia%27" '"Florencia"'
prueba "Consulta espacial (vista PostGIS)" "$OWS?service=WFS&version=1.0.0&request=GetFeature&typeName=$WS:v_hospitales_en_riesgo&outputFormat=application/json" '"tipo_riesgo"'
code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/geoserver/web/")
if [ "$code" = "403" ] || [ "$BASE" = "http://127.0.0.1:8080" ]; then echo "  [OK]    Panel admin bloqueado desde afuera ($code)"; pass=$((pass+1));
else echo "  [AVISO] Panel admin responde $code a través de Nginx"; fi

echo; echo "Resultado: $pass correctas, $fail fallidas"
[ $fail -eq 0 ]
