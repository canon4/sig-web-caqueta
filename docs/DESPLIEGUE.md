# Despliegue en un servidor

Probado para **Ubuntu 24.04**. Sirve cualquier VPS con acceso root: Hostinger (KVM), Oracle Cloud, DigitalOcean, AWS, etc.
Mínimo **2 GB de RAM** (recomendado 4 GB); GeoServer es el componente que más memoria usa.

| Proveedor | Usuario SSH | Firewall externo |
|---|---|---|
| Hostinger VPS | `root` | Firewall de hPanel (opcional): permite 22, 80 y 443 |
| Oracle Cloud | `ubuntu` | **Security List** de la VCN: agrega reglas de entrada TCP 80 y 443 |

> En Hostinger elige la plantilla **Ubuntu 24.04 limpia**, sin paneles (CloudPanel, Coolify…), porque instalan su propio Nginx.

## 1. Subir el proyecto al servidor

Opción recomendada, con Git:

```bash
ssh root@IP_DEL_SERVIDOR
apt update && apt install -y git
git clone https://github.com/TU_USUARIO/sig-web-caqueta.git /srv/sig-web-caqueta
cd /srv/sig-web-caqueta
```

Si el repositorio es privado, crea una *deploy key*: `ssh-keygen -t ed25519 -f ~/.ssh/github` en el servidor, agrega la clave pública en GitHub (**Settings → Deploy keys**) y clona con la URL `git@github.com:...`.

## 2. Variables de entorno

```bash
cp .env.example .env
nano .env        # cambia DB_OWNER_PASS, DB_APP_PASS y GS_ADMIN_PASS
chmod 600 .env
```

## 3. Ejecutar los pasos

| Script | Paso | Qué hace | Tiempo |
|---|---|---|---|
| `sudo bash infra/scripts/01_preparar_servidor.sh` | 1-2 | Actualiza el sistema y deja el firewall con 22, 80 y 443 | ~5 min |
| `sudo bash infra/scripts/02_instalar_postgis.sh` | 3 | PostgreSQL + PostGIS, roles y base de datos | ~3 min |
| `bash infra/scripts/03_importar_datos.sh` | 3.1-3.2 | Importa `datos/`, crea la vista y valida geometrías | segundos |
| `sudo bash infra/scripts/04_instalar_geoserver.sh` | 4 | Java 17 + GeoServer como servicio en 127.0.0.1:8080 | ~5 min |
| `bash infra/scripts/05_configurar_geoserver.sh` | 5-6 | Workspace, data store, capas y estilos vía REST | segundos |
| `sudo bash infra/scripts/06_publicar_web.sh` | 7-8 | Compila el visor y configura Nginx | ~1 min |
| `bash infra/scripts/07_verificar.sh` | 15 | Prueba GetCapabilities, GetMap y GetFeature | segundos |

El paso 05 también se puede hacer a mano en el panel de GeoServer; es lo recomendado para la demo en clase.

Visor: `http://IP_DEL_SERVIDOR/`

## 4. Administrar GeoServer

El panel no se publica en internet. Ábrelo con un túnel SSH desde tu computador:

```bash
ssh -L 8080:localhost:8080 root@IP_DEL_SERVIDOR
# navegador: http://localhost:8080/geoserver/web
```

## 5. Actualizar después de un cambio

```bash
cd /srv/sig-web-caqueta
git pull
sudo bash infra/scripts/06_publicar_web.sh      # si cambió frontend/
bash infra/scripts/03_importar_datos.sh         # si cambió datos/ o db/
bash infra/scripts/05_configurar_geoserver.sh   # si cambiaron capas o estilos
```

## Despliegue automático con GitHub Actions

Con los secretos configurados, cada push a `main` valida el proyecto, entra al servidor por SSH, hace `git pull`, recompila el visor y corre las pruebas.

1. Genera una llave solo para despliegues, en tu computador:
   ```bash
   ssh-keygen -t ed25519 -f deploy_sig -C "github-actions"
   ssh-copy-id -i deploy_sig.pub root@IP_DEL_SERVIDOR
   ```
2. En GitHub: **Settings → Secrets and variables → Actions → New repository secret**:

   | Secreto | Valor |
   |---|---|
   | `SSH_HOST` | IP del servidor |
   | `SSH_USER` | `root` (Hostinger) o `ubuntu` (Oracle) |
   | `SSH_KEY` | contenido completo del archivo `deploy_sig` |
   | `APP_DIR` | `/srv/sig-web-caqueta` |

3. Crea el entorno `produccion` en **Settings → Environments** (ahí puedes exigir aprobación antes de desplegar).

## HTTPS

Con un dominio cuyo registro A apunte a la IP del servidor:

```bash
sudo sed -i 's/^PUBLIC_HOST=.*/PUBLIC_HOST=sig.midominio.com/' .env
sudo bash infra/scripts/06_publicar_web.sh
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d sig.midominio.com
```

## Respaldos

```bash
# copia diaria de la base a las 2 a. m., se conservan 7 días
sudo mkdir -p /var/backups/sig && sudo chown postgres /var/backups/sig
echo '0 2 * * * postgres pg_dump -Fc sig_caqueta > /var/backups/sig/sig_$(date +\%u).dump' | sudo tee /etc/cron.d/sig-backup
# restaurar:  pg_restore -d sig_caqueta --clean /var/backups/sig/sig_1.dump
```

## Diagnóstico

| Síntoma | Revisar |
|---|---|
| El visor no abre desde afuera | Firewall del proveedor (puertos 80 y 443) y `sudo ufw status` |
| "No se pudo conectar con GeoServer" | `systemctl status geoserver` · `journalctl -u geoserver -n 80` |
| El data store no conecta | `systemctl status postgresql` y la clave `DB_APP_PASS` |
| Capa fuera de lugar | Declared SRS = EPSG:4326 y recalcular los bounding boxes |
| GetMap devuelve XML | Leer el `ServiceException`: nombra la capa o el estilo que falta |
| GeoServer lento | Subir `GS_JAVA_MEM` en `.env`, volver a correr el script 04 |
