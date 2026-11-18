/**
 * Acceso a los servicios OGC de GeoServer (WMS y WFS).
 * Cada petición queda registrada en el panel "Peticiones al servidor".
 */
import L from 'leaflet';
import { WMS_URL, WFS_URL, WS, MAX_FEATURES } from './config.js';
import { registrarPeticion, mostrarEstado } from './ui.js';

/** Capa WMS: GeoServer dibuja la imagen y el navegador solo la muestra. */
export function capaWMS(nombre) {
  const capa = L.tileLayer.wms(WMS_URL, {
    layers: `${WS}:${nombre}`,
    format: 'image/png',
    transparent: true,
    version: '1.1.1',
    tiled: true,
    maxZoom: 19,
  });
  let registrada = false;
  capa.on('tileload', (e) => {
    if (!registrada) { registrarPeticion('WMS GetMap', e.tile.src); registrada = true; }
  });
  capa.on('tileerror', () => mostrarEstado('error', `Error cargando la capa WMS ${nombre}`));
  return capa;
}

/**
 * URL de un WFS GetFeature en GeoJSON.
 * Se usa WFS 1.0.0 porque siempre entrega longitud, latitud (el orden que espera Leaflet);
 * en WFS 1.1 / 2.0 con EPSG:4326 el orden es latitud, longitud.
 */
export function urlWFS(tipo, { cql, propiedades } = {}) {
  const p = new URLSearchParams({
    service: 'WFS',
    version: '1.0.0',
    request: 'GetFeature',
    typeName: `${WS}:${tipo}`,
    outputFormat: 'application/json',
    maxFeatures: MAX_FEATURES,
  });
  if (cql) p.set('CQL_FILTER', cql);
  if (propiedades) p.set('propertyName', propiedades.join(','));
  return `${WFS_URL}?${p}`;
}

/** Descarga entidades por WFS. Lanza error si la capa no existe o no está publicada. */
export async function obtenerWFS(tipo, opciones) {
  const url = urlWFS(tipo, opciones);
  registrarPeticion('WFS GetFeature', url);
  const r = await fetch(url);
  if (!r.ok) throw new Error(`HTTP ${r.status} en ${tipo}`);
  // si la capa no existe, GeoServer responde 200 con un XML de excepción: r.json() falla
  return r.json();
}

/** WMS GetFeatureInfo: qué hay en el pixel donde el usuario hizo clic. */
export async function consultarPixel(mapa, latlng, capas) {
  const tam = mapa.getSize();
  const sw = mapa.options.crs.project(mapa.getBounds().getSouthWest());
  const ne = mapa.options.crs.project(mapa.getBounds().getNorthEast());
  const pt = mapa.latLngToContainerPoint(latlng).round();
  const nombres = capas.map((c) => `${WS}:${c}`).join(',');
  const p = new URLSearchParams({
    service: 'WMS',
    version: '1.1.1',
    request: 'GetFeatureInfo',
    layers: nombres,
    query_layers: nombres,
    styles: '',
    srs: 'EPSG:3857',
    bbox: [sw.x, sw.y, ne.x, ne.y].join(','),
    width: tam.x,
    height: tam.y,
    x: pt.x,
    y: pt.y,
    info_format: 'application/json',
    feature_count: 5,
  });
  const url = `${WMS_URL}?${p}`;
  registrarPeticion('WMS GetFeatureInfo', url);
  const r = await fetch(url);
  return r.json();
}

/** URL de la leyenda que genera GeoServer a partir del estilo SLD. */
export function urlLeyenda(nombre) {
  return `${WMS_URL}?service=WMS&version=1.1.1&request=GetLegendGraphic&format=image/png` +
    `&layer=${WS}:${nombre}&legend_options=fontAntiAliasing:true;fontSize:11;forceLabels:on`;
}
