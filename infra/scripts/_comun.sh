#!/usr/bin/env bash
# Funciones comunes: se carga al inicio de cada script de infra/scripts/
set -euo pipefail

# Ir a la raíz del repositorio, se ejecute desde donde se ejecute
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$RAIZ"

# Cargar variables de entorno (.env no se sube a Git; se crea desde .env.example)
ENV_FILE="${ENV_FILE:-.env}"
if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: falta el archivo $ENV_FILE"
  echo "  cp .env.example .env   y luego edita las contraseñas"
  exit 1
fi
# Las variables pasadas en la línea de comandos tienen prioridad sobre .env
# (ej.: GS_URL=http://localhost:8080/geoserver bash infra/scripts/05_configurar_geoserver.sh)
_previas="$(export -p)"
set -a; source "$ENV_FILE"; set +a
eval "$_previas" 2>/dev/null || true

if grep -q "CambiaEsto" "$ENV_FILE"; then
  echo "AVISO: $ENV_FILE todavía tiene contraseñas de ejemplo (CambiaEsto...)."
fi

paso () { echo; echo "==> $*"; }
