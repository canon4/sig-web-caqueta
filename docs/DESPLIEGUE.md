# Despliegue en un servidor

Hay dos formas de desplegar:

| | **A. Docker (recomendada)** | B. Instalación nativa |
|---|---|---|
| Qué instala en el sistema | Solo usa Docker | PostgreSQL, Java, GeoServer y Nginx con `apt` |
| Convive con otros sitios | Sí: todo queda en `127.0.0.1` | Riesgo de choques (Nginx, puertos 80/443) |
| Comando de despliegue | `docker compose up -d --build` | Scripts `infra/scripts/01` a `07` |
| Quitarlo | `docker compose down -v` | Desinstalar paquete por paquete |

Requisitos: Ubuntu 22.04/24.04 (u otro Linux con Docker), **2 GB de RAM libres** como mínimo y acceso root.

---

## A. Despliegue con Docker

### 1. Docker y el código

```bash
docker --version && docker compose version     # si falta: curl -fsSL https://get.docker.com | sh
cd /srv
git clone https://github.com/TU_USUARIO/sig-web-caqueta.git
cd sig-web-caqueta
```

Si el repositorio es privado, usa una *deploy key*: `ssh-keygen -t ed25519 -f ~/.ssh/github` en el servidor, agrega la clave pública en GitHub (**Settings → Deploy keys**) y clona con `git@github.com:...`.

### 2. Variables de entorno

```bash
cp .env.example .env
nano .env          # cambia DB_OWNER_PASS, DB_APP_PASS y GS_ADMIN_PASS
chmod 600 .env
```

Revisa que los puertos `DB_PORT`, `GS_PORT` y `WEB_PORT` estén libres en el servidor:

```bash
ss -tlnp | grep -E ':(5432|8086|8090)\b' || echo "libres"
```

### 3. Levantar todo

```bash
docker compose up -d --build
docker compose ps -a
```

La primera vez tarda unos minutos (descarga ~1,5 GB de imágenes). El orden lo maneja Compose:

1. `postgis` arranca y crea la base, la extensión y el usuario de solo lectura.
2. `importador` carga `datos/`, crea la vista espacial, valida y **termina** (estado `Exited (0)`).
3. `geoserver` arranca (~1 minuto).
4. `configurador` crea el workspace, el data store, las capas y los estilos, y **termina** (`Exited (0)`).
5. `web` sirve el visor en `127.0.0.1:8090` y reenvía `/geoserver/` a GeoServer.

```bash
docker compose logs importador configurador     # qué hicieron los pasos automáticos
source .env && BASE=http://127.0.0.1:$WEB_PORT bash infra/scripts/07_verificar.sh
```

### 4. Publicar en internet con el servidor web existente

Los contenedores solo escuchan en `127.0.0.1`: Docker se salta `ufw`, así que nunca se publican en `0.0.0.0`. El acceso público lo da el servidor web que ya tiene la máquina.

**Apache, en una ruta de un sitio existente** (no modifica ningún VirtualHost):

```bash
sudo cp infra/apache/sig-caqueta-ruta.conf /etc/apache2/conf-available/sig-caqueta.conf
sudo a2enmod proxy proxy_http headers
sudo a2enconf sig-caqueta
sudo apache2ctl configtest && sudo systemctl reload apache2
```

Visor: `https://DOMINIO/sig-caqueta/` (con el mismo certificado HTTPS del sitio).
Para quitarlo: `sudo a2disconf sig-caqueta && sudo systemctl reload apache2`.

**Apache, en un subdominio propio:** usa `infra/apache/sig-caqueta-subdominio.conf` (instrucciones dentro del archivo).

**Nginx del servidor:** un `location /sig-caqueta/ { proxy_pass http://127.0.0.1:8090/; }` dentro del `server` existente.

### 5. Administrar

```bash
# Panel de GeoServer, desde TU computador:
ssh -L 8086:localhost:8086 root@IP_DEL_SERVIDOR
# navegador: http://localhost:8086/geoserver/web   (admin / GS_ADMIN_PASS)

# Base de datos con QGIS o DBeaver por el mismo túnel:
ssh -L 5432:localhost:5432 root@IP_DEL_SERVIDOR   # host localhost, puerto 5432
```

| Tarea | Comando |
|---|---|
| Ver estado | `docker compose ps -a` |
| Ver logs | `docker compose logs -f geoserver` |
| Actualizar tras un cambio | `git pull && docker compose up -d --build` |
| Reiniciar un servicio | `docker compose restart geoserver` |
| Consola SQL | `docker compose exec postgis psql -U sig_admin -d sig_caqueta` |
| Consultas de la demo | `docker compose exec -T postgis psql -U sig_admin -d sig_caqueta < db/04_consultas_demo.sql` |
| Detener (conserva datos) | `docker compose down` |
| Borrar todo, datos incluidos | `docker compose down -v` |

### 6. Respaldos

```bash
sudo mkdir -p /var/backups/sig
# diario a las 2 a. m., se conservan 7 días
echo '0 2 * * * root cd /srv/sig-web-caqueta && docker compose exec -T postgis pg_dump -U sig_admin -Fc sig_caqueta > /var/backups/sig/sig_$(date +\%u).dump' | sudo tee /etc/cron.d/sig-backup
# restaurar:
docker compose exec -T postgis pg_restore -U sig_admin -d sig_caqueta --clean < /var/backups/sig/sig_1.dump
```

---

## Despliegue automático con GitHub Actions

Cada push a `main` valida el proyecto, construye las imágenes y luego entra al servidor por SSH para ejecutar `git pull && docker compose up -d --build` y las pruebas.

1. Genera una llave solo para despliegues, en tu computador:
   ```bash
   ssh-keygen -t ed25519 -f deploy_sig -C "github-actions"
   ssh-copy-id -i deploy_sig.pub root@IP_DEL_SERVIDOR
   ```
2. En GitHub: **Settings → Secrets and variables → Actions → New repository secret**:

   | Secreto | Valor |
   |---|---|
   | `SSH_HOST` | IP o dominio del servidor |
   | `SSH_USER` | usuario SSH (`root` en Hostinger) |
   | `SSH_KEY` | contenido completo del archivo `deploy_sig` |
   | `APP_DIR` | `/srv/sig-web-caqueta` |

3. Crea el entorno `produccion` en **Settings → Environments** (ahí puedes exigir aprobación antes de cada despliegue).

---

## B. Instalación nativa (sin Docker)

Útil para explicar cada componente por separado o en un servidor dedicado sin otros sitios.
**No la uses en un servidor con Apache u otros sitios en producción**: el script 06 instala Nginx en los puertos 80/443.

| Script | Paso | Qué hace |
|---|---|---|
| `sudo bash infra/scripts/01_preparar_servidor.sh` | 1-2 | `apt upgrade` y firewall con 22, 80 y 443 |
| `sudo bash infra/scripts/02_instalar_postgis.sh` | 3 | PostgreSQL + PostGIS, roles y base |
| `bash infra/scripts/03_importar_datos.sh` | 3.1-3.2 | Importa, crea la vista y valida |
| `sudo bash infra/scripts/04_instalar_geoserver.sh` | 4 | Java 17 + GeoServer como servicio en 127.0.0.1:8080 |
| `bash infra/scripts/05_configurar_geoserver.sh` | 5-6 | Workspace, store, capas y estilos vía REST |
| `sudo bash infra/scripts/06_publicar_web.sh` | 7-8 | Compila el visor y configura Nginx |
| `bash infra/scripts/07_verificar.sh` | 15 | Pruebas WMS/WFS |

En Oracle Cloud abre además los puertos 80 y 443 en la *Security List* de la VCN.

---

## Diagnóstico

| Síntoma | Revisar |
|---|---|
| `importador` o `configurador` en `Exited (1)` | `docker compose logs importador configurador` |
| El visor dice "No se pudo conectar con GeoServer" | `docker compose ps` (¿geoserver arriba?) y `docker compose logs geoserver` |
| 502/503 desde Apache | ¿`web` está arriba? `curl -I http://127.0.0.1:8090/` en el servidor |
| `/sig-caqueta/` carga sin estilos | Falta la barra final; la regla `RedirectMatch` del archivo la agrega |
| Capa fuera de lugar | Declared SRS = EPSG:4326 y recalcular los bounding boxes en GeoServer |
| GeoServer lento | Sube `GS_JAVA_MEM` en `.env` y `docker compose up -d geoserver` |
