#!/usr/bin/env bash
# ==============================================================
#  PASO 4 · Instalar GeoServer (binario con Jetty) como servicio
#  Uso:  sudo bash infra/scripts/04_instalar_geoserver.sh
# ==============================================================
source "$(dirname "$0")/_comun.sh"

echo "==> 1. Java 17 (GeoServer 3 requiere Java 17 o 21)"
export DEBIAN_FRONTEND=noninteractive
apt-get install -y openjdk-17-jre-headless unzip
java -version
JAVA_HOME_DIR=$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")

echo "==> 2. Usuario de sistema sin login para correr GeoServer"
id geoserver >/dev/null 2>&1 || useradd --system --home "$GS_HOME" --shell /usr/sbin/nologin geoserver

echo "==> 3. Descargando GeoServer $GS_VERSION (binario independiente de plataforma)"
ZIP="/tmp/geoserver-$GS_VERSION-bin.zip"
if [ ! -s "$ZIP" ]; then
  curl -fL --retry 3 -o "$ZIP" \
    "https://sourceforge.net/projects/geoserver/files/GeoServer/$GS_VERSION/geoserver-$GS_VERSION-bin.zip/download"
fi
unzip -tq "$ZIP" >/dev/null   # verifica que el zip no esté corrupto

rm -rf "$GS_HOME" && mkdir -p "$GS_HOME"
unzip -q "$ZIP" -d "$GS_HOME"
# si el zip trae una carpeta raíz, se sube un nivel
if [ ! -f "$GS_HOME/start.jar" ] && [ "$(ls "$GS_HOME" | wc -l)" = "1" ]; then
  sub="$GS_HOME/$(ls "$GS_HOME")"; mv "$sub"/* "$GS_HOME"/; rmdir "$sub"
fi
test -f "$GS_HOME/bin/startup.sh" || { echo "No se encontró bin/startup.sh en $GS_HOME"; exit 1; }

echo "==> 4. Directorio de datos fuera de la instalación (facilita actualizar y respaldar)"
if [ ! -d "$GS_DATA_DIR" ]; then
  cp -r "$GS_HOME/data_dir" "$GS_DATA_DIR"
fi
chown -R geoserver:geoserver "$GS_HOME" "$GS_DATA_DIR"

echo "==> 5. Servicio systemd (arranca solo y escucha SOLO en 127.0.0.1:8080)"
cat > /etc/systemd/system/geoserver.service <<EOF
[Unit]
Description=GeoServer $GS_VERSION
After=network.target postgresql.service

[Service]
Type=simple
User=geoserver
Group=geoserver
Environment=JAVA_HOME=$JAVA_HOME_DIR
Environment=GEOSERVER_HOME=$GS_HOME
Environment=GEOSERVER_DATA_DIR=$GS_DATA_DIR
Environment="JAVA_OPTS=-server $GS_JAVA_MEM -Djava.awt.headless=true"
Environment="JETTY_OPTS=jetty.http.host=127.0.0.1 jetty.http.port=8080"
WorkingDirectory=$GS_HOME
ExecStart=/bin/sh $GS_HOME/bin/startup.sh
ExecStop=/bin/sh $GS_HOME/bin/shutdown.sh
Restart=on-failure
TimeoutStartSec=180

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now geoserver

echo "==> 6. Esperando a que GeoServer responda..."
for i in $(seq 1 60); do
  if curl -fs -o /dev/null http://127.0.0.1:8080/geoserver/web/; then
    echo "   GeoServer está arriba (intento $i)"; break
  fi
  sleep 3
done
curl -fs -o /dev/null http://127.0.0.1:8080/geoserver/web/ || { echo "GeoServer no respondió. Revisa: journalctl -u geoserver -n 100"; exit 1; }

echo "==> 7. Cambiando la contraseña por defecto del admin (admin/geoserver)"
code=$(curl -s -o /dev/null -w "%{http_code}" -u admin:geoserver -X PUT \
  -H "Content-Type: application/json" \
  -d "{\"newPassword\":\"$GS_ADMIN_PASS\"}" \
  http://127.0.0.1:8080/geoserver/rest/security/self/password)
case "$code" in
  200) echo "   Contraseña del admin cambiada." ;;
  401) echo "   La clave por defecto ya no funciona (probablemente ya se había cambiado)." ;;
  *)   echo "   Respuesta inesperada ($code): cámbiala a mano en Security > Users." ;;
esac

echo
echo "LISTO. GeoServer corre en 127.0.0.1:8080 (no expuesto a internet)."
echo "Para entrar al panel desde TU computador, abre un túnel SSH:"
echo "   ssh -L 8080:localhost:8080 USUARIO@IP_PUBLICA   (root en Hostinger, ubuntu en Oracle)"
echo "y luego en el navegador:  http://localhost:8080/geoserver/web"
