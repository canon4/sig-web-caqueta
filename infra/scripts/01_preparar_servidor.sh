#!/usr/bin/env bash
# ==============================================================
#  PASO 1 y 2 · Preparar el servidor Ubuntu y el firewall
#  Uso:  sudo bash infra/scripts/01_preparar_servidor.sh
# ==============================================================
source "$(dirname "$0")/_comun.sh"

echo "==> 1. Actualizando el sistema"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
apt-get install -y curl wget unzip ca-certificates gnupg lsb-release htop ufw jq

echo "==> 2. Zona horaria"
timedatectl set-timezone America/Bogota || true

echo "==> 3. Firewall: solo 22 (SSH), 80 (HTTP) y 443 (HTTPS)"
# 5432 (PostgreSQL) y 8080 (GeoServer) quedan CERRADOS hacia internet:
# solo se usan dentro del servidor (Nginx -> GeoServer -> PostGIS).
if command -v netfilter-persistent >/dev/null 2>&1 && iptables -S INPUT | grep -q "REJECT"; then
  # Las imágenes Ubuntu de Oracle Cloud traen reglas iptables propias con un REJECT final.
  # Hay que insertar las reglas ANTES de ese REJECT.
  echo "   Detectadas reglas iptables de Oracle Cloud: abriendo 80 y 443"
  for p in 80 443; do
    iptables -C INPUT -p tcp --dport $p -m state --state NEW -j ACCEPT 2>/dev/null || \
      iptables -I INPUT 5 -p tcp --dport $p -m state --state NEW -j ACCEPT
  done
  netfilter-persistent save
else
  ufw allow 22/tcp
  ufw allow 80/tcp
  ufw allow 443/tcp
  ufw --force enable
  ufw status verbose
fi

echo
echo "LISTO. Abre también 80 y 443 en el firewall del proveedor si tiene uno"
echo "(Oracle: Security List de la VCN · Hostinger: firewall de hPanel, si está activo)."
