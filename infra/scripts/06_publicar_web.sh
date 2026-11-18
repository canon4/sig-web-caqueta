#!/usr/bin/env bash
# ==============================================================
#  PASO 7 y 8 · Compilar el visor (Vite) y publicarlo con Nginx
#  Uso:  sudo bash infra/scripts/06_publicar_web.sh
#  Se vuelve a correr cada vez que cambie el frontend (o lo hace GitHub Actions).
# ==============================================================
source "$(dirname "$0")/_comun.sh"
export DEBIAN_FRONTEND=noninteractive

paso "1. Nginx y Node.js"
command -v nginx >/dev/null || apt-get install -y nginx
command -v npm   >/dev/null || apt-get install -y nodejs npm
echo "   node $(node -v) · npm $(npm -v)"

paso "2. Compilando el frontend (frontend/ -> frontend/dist)"
( cd frontend && npm ci --no-audit --no-fund && npm run build )

paso "3. Copiando el build a $WEB_ROOT"
mkdir -p "$WEB_ROOT"
rm -rf "${WEB_ROOT:?}"/*
cp -r frontend/dist/* "$WEB_ROOT"/
chown -R www-data:www-data "$WEB_ROOT"

paso "4. Sitio de Nginx (visor + proxy /geoserver/)"
sed -e "s|__PUBLIC_HOST__|$PUBLIC_HOST|" -e "s|__WEB_ROOT__|$WEB_ROOT|" \
    infra/nginx/sig-caqueta.conf > /etc/nginx/sites-available/sig-caqueta
ln -sf /etc/nginx/sites-available/sig-caqueta /etc/nginx/sites-enabled/sig-caqueta
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl enable nginx >/dev/null 2>&1 || true
systemctl reload nginx || systemctl restart nginx

IP=$(curl -fs --max-time 5 https://ifconfig.me || hostname -I | awk '{print $1}')
echo
echo "LISTO. Abre desde cualquier dispositivo:  http://$IP/"
echo
echo "HTTPS (opcional, requiere un dominio que apunte a esta IP):"
echo "   sudo apt install -y certbot python3-certbot-nginx"
echo "   sudo certbot --nginx -d tu-dominio.com"
