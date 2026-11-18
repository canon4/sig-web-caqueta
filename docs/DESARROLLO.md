# Desarrollo local con Visual Studio Code

## Requisitos

- [Git](https://git-scm.com/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (en Windows, con WSL 2)
- [Node.js](https://nodejs.org/) 18 o superior
- VS Code. Al abrir la carpeta, acepta instalar las extensiones recomendadas (`.vscode/extensions.json`).

> En Windows ejecuta los scripts `.sh` desde **Git Bash** o desde una terminal WSL, no desde PowerShell.

## 1. Clonar y configurar

```bash
git clone https://github.com/TU_USUARIO/sig-web-caqueta.git
cd sig-web-caqueta
cp .env.example .env        # cambia las contraseñas
code .
```

## 2. Levantar la base de datos y GeoServer

En VS Code: **Terminal → Run Task…** y ejecuta en orden:

1. `Docker: levantar entorno`
2. `Docker: importar datos`
3. `Docker: crear vista espacial`
4. `GeoServer: configurar (local)` (espera ~1 minuto a que GeoServer arranque)

Equivalente en la terminal:

```bash
docker compose up -d
docker compose --profile tools run --rm importador
docker compose exec -T postgis sh -c 'psql -U $POSTGRES_USER -d $POSTGRES_DB -v app=$DB_APP_USER -f /db/02_vistas.sql'
GS_URL=http://localhost:8080/geoserver DB_HOST=postgis bash infra/scripts/05_configurar_geoserver.sh
```

| Servicio | URL |
|---|---|
| Panel de GeoServer | http://localhost:8080/geoserver/web (admin / `GS_ADMIN_PASS`) |
| PostGIS (QGIS, DBeaver, SQLTools) | `localhost:5432`, base `sig_caqueta`, usuario `sig_admin` |

## 3. Trabajar en el visor

```bash
cd frontend
npm install
npm run dev          # http://localhost:5173 con recarga automática
```

Vite reenvía `/geoserver` al GeoServer de Docker (`vite.config.js`), igual que Nginx en producción.
Para apuntar a otro GeoServer, crea `frontend/.env.local` con `GEOSERVER_PROXY=http://IP:8080`.

| Archivo | Responsabilidad |
|---|---|
| `src/main.js` | Crea el mapa, la lista de capas, la leyenda y conecta los eventos |
| `src/config.js` | URL de GeoServer, workspace y extensión del Caquetá |
| `src/servicios.js` | Peticiones WMS, WFS, GetFeatureInfo y GetLegendGraphic |
| `src/capas.js` | Catálogo de capas (cuáles van por WMS y cuáles por WFS) |
| `src/consultas.js` | Filtro por municipio y consulta espacial de riesgo |
| `src/ui.js` | Estado, registro de peticiones, popups e íconos |

Para probar el build de producción: `npm run build` y abre http://localhost:8081 (Nginx de Docker).

## 4. Flujo de trabajo con Git

```bash
git checkout -b mejora-filtros     # una rama por cambio
# ... editar, probar ...
git add -A && git commit -m "feat: filtro de instituciones por zona"
git push -u origin mejora-filtros  # abre un Pull Request en GitHub
```

Cada push ejecuta la validación de `.github/workflows/ci-cd.yml`. Al fusionar en `main`, GitHub Actions despliega en el servidor (ver [DESPLIEGUE.md](DESPLIEGUE.md#despliegue-automático-con-github-actions)).

## 5. Editar directamente en el servidor (Remote - SSH)

1. `F1` → **Remote-SSH: Connect to Host…** → `root@IP_DEL_SERVIDOR`
2. **File → Open Folder** → `/srv/sig-web-caqueta`
3. La terminal integrada ya es la del servidor.

Úsalo para revisar y depurar. Los cambios de código conviene hacerlos en local y subirlos con Git, para que el repositorio siga siendo la única fuente de verdad.

## Detener o reiniciar el entorno

```bash
docker compose down          # detiene (conserva los datos)
docker compose down -v       # borra también la base y la config de GeoServer
```
