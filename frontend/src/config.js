/**
 * Configuración del visor.
 *
 * GEOSERVER: ruta RELATIVA "geoserver". Nginx la reenvía a GeoServer en el mismo
 * dominio, así el navegador no necesita CORS, y el visor funciona igual en la raíz
 * (https://sig.dominio.com/) o en una subruta (http://IP/sig-caqueta/).
 * En desarrollo, Vite hace el mismo proxy (vite.config.js).
 * Se puede cambiar con VITE_GEOSERVER_URL o, para pruebas, con
 * ?geoserver=http://otro-servidor/geoserver en la URL.
 */
const params = new URLSearchParams(location.search);

export const GEOSERVER = params.get('geoserver') || import.meta.env.VITE_GEOSERVER_URL || 'geoserver';
export const WS = import.meta.env.VITE_WORKSPACE || 'caqueta';

export const WMS_URL = `${GEOSERVER}/${WS}/wms`;
export const WFS_URL = `${GEOSERVER}/${WS}/ows`;

/** Extensión del departamento del Caquetá [[sur, oeste], [norte, este]] */
export const CAQUETA = [[-0.75, -76.35], [3.0, -71.2]];

/** Máximo de entidades por petición WFS (GeoServer también lo limita) */
export const MAX_FEATURES = 1000;
