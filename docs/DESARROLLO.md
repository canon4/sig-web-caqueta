# Desarrollo local con Visual Studio Code

## Requisitos

- [Git](https://git-scm.com/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (en Windows, con WSL 2)
- [Node.js](https://nodejs.org/) 18 o superior
- VS Code. Al abrir la carpeta, acepta instalar las extensiones recomendadas (`.vscode/extensions.json`).

> En Windows ejecuta los scripts `.sh` desde **Git Bash** o WSL, no desde PowerShell.

## 1. Clonar y configurar

```bash
git clone https://github.com/TU_USUARIO/sig-web-caqueta.git
cd sig-web-caqueta
cp .env.example .env        # en local puedes dejar las contraseñas de ejemplo
code .
```

## 2. Levantar el sistema completo

El mismo `compose.yaml` que corre en producción corre en tu PC:

```bash
docker compose up -d --build
docker compose ps -a        # importador y configurador deben quedar en Exited (0)
```

En VS Code: **Terminal → Run Task… → Docker: levantar todo (build)**.

| Servicio | URL |
|---|---|
| Visor (build de producción) | http://localhost:8090 |
| Panel de GeoServer | http://localhost:8086/geoserver/web (admin / `GS_ADMIN_PASS`) |
| PostGIS (QGIS, DBeaver, SQLTools) | `localhost:5432`, base `sig_caqueta`, usuario `sig_admin` |

## 3. Programar el visor con recarga en vivo

```bash
cd frontend
npm install
npm run dev          # http://localhost:5173
```

Vite reenvía `/geoserver` al GeoServer de Docker (`localhost:8086`, ver `vite.config.js`), igual que Nginx en producción.
Para apuntar a otro GeoServer, crea `frontend/.env.local` con `GEOSERVER_PROXY=http://host:puerto`.

| Archivo | Responsabilidad |
|---|---|
| `src/main.js` | Crea el mapa, la lista de capas, la leyenda y conecta los eventos |
| `src/config.js` | URL de GeoServer, workspace y extensión del Caquetá |
| `src/servicios.js` | Peticiones WMS, WFS, GetFeatureInfo y GetLegendGraphic |
| `src/capas.js` | Catálogo de capas (cuáles van por WMS y cuáles por WFS) |
| `src/consultas.js` | Filtro por municipio y consulta espacial de riesgo |
| `src/ui.js` | Estado, registro de peticiones, popups e íconos |

Cuando termines, `docker compose up -d --build web` reconstruye el visor de producción.

## 4. Cambios en datos, SQL o estilos

| Cambiaste | Ejecuta |
|---|---|
| `datos/*.geojson` o `db/02_vistas.sql` | `docker compose up importador` |
| `geoserver/estilos/*.sld` o capas | `docker compose up configurador` |
| `frontend/` | `docker compose up -d --build web` |

## 5. Flujo de trabajo con Git

```bash
git checkout -b mejora-filtros
# ... editar, probar ...
git add -A && git commit -m "feat: filtro de instituciones por zona"
git push -u origin mejora-filtros     # abre un Pull Request en GitHub
```

Cada push ejecuta la validación de `.github/workflows/ci-cd.yml`. Al fusionar en `main`, GitHub Actions despliega en el servidor ([DESPLIEGUE.md](DESPLIEGUE.md#despliegue-automático-con-github-actions)).

## 6. Conectarte al servidor desde VS Code (Remote - SSH)

1. `F1` → **Remote-SSH: Connect to Host…** → `root@IP_DEL_SERVIDOR`
2. **File → Open Folder** → `/srv/sig-web-caqueta`
3. La terminal integrada ya es la del servidor.

Úsalo para revisar logs y depurar. Los cambios de código conviene hacerlos en local y subirlos con Git, así el repositorio sigue siendo la única fuente de verdad.
