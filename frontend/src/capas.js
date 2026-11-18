/**
 * Catálogo de capas del visor.
 *   WMS -> GeoServer entrega imágenes (municipios, zonas de riesgo, vías)
 *   WFS -> GeoServer entrega GeoJSON con geometría y atributos (puntos)
 */
import L from 'leaflet';
import { capaWMS } from './servicios.js';
import { icono, popupEntidad } from './ui.js';

const puntos = (color, forma) => L.geoJSON(null, {
  pointToLayer: (f, ll) => L.marker(ll, { icon: icono(color, forma) }),
  onEachFeature: (f, l) => l.bindPopup(popupEntidad(f.properties)),
});

export const hospitales = puntos('#C62828');
export const colegios = puntos('#1565C0', 'cuadro');

/** Resultado de la consulta espacial (vista v_hospitales_en_riesgo en PostGIS). */
export const enRiesgo = L.geoJSON(null, {
  pointToLayer: (f, ll) => L.circleMarker(ll, { radius: 14, color: '#E65100', weight: 3, fillOpacity: 0.15 }),
  onEachFeature: (f, l) => l.bindPopup(popupEntidad(f.properties, '⚠ ')),
});

export const CAPAS = [
  { id: 'municipios',               titulo: 'Municipios',               tipo: 'wms', capa: capaWMS('municipios'),   visible: true },
  { id: 'zonas_riesgo',             titulo: 'Zonas de riesgo',          tipo: 'wms', capa: capaWMS('zonas_riesgo'), visible: true },
  { id: 'vias',                     titulo: 'Vías',                     tipo: 'wms', capa: capaWMS('vias'),         visible: true },
  { id: 'hospitales',               titulo: 'Hospitales',               tipo: 'wfs', capa: hospitales,              visible: true },
  { id: 'instituciones_educativas', titulo: 'Instituciones educativas', tipo: 'wfs', capa: colegios,                visible: false },
];

/** Capas que muestran leyenda (GetLegendGraphic) */
export const CON_LEYENDA = ['zonas_riesgo', 'vias', 'hospitales', 'instituciones_educativas'];

export const capaPorId = (id) => CAPAS.find((c) => c.id === id);
