/**
 * Consultas del panel lateral.
 *  - Filtro por municipio: WFS con CQL_FILTER (lo filtra GeoServer)
 *  - Hospitales en zona de riesgo: la intersección la calcula PostGIS
 *    (vista v_hospitales_en_riesgo) y GeoServer la publica por WFS
 */
import { obtenerWFS } from './servicios.js';
import { hospitales, colegios, enRiesgo } from './capas.js';
import { escapar } from './ui.js';

const resultado = () => document.getElementById('resultado');

// Cada consulta recibe un turno; si el usuario lanza otra (o limpia) antes de que
// llegue la respuesta, la respuesta vieja se descarta en lugar de pintarse encima.
let turno = 0;
const nuevoTurno = () => ++turno;
const vigente = (t) => t === turno;

export async function cargarHospitales(mapa, municipio = '') {
  const t = nuevoTurno();
  const cql = municipio ? `municipio='${municipio.replace(/'/g, "''")}'` : undefined;
  const datos = await obtenerWFS('hospitales', { cql });
  if (!vigente(t)) return;
  hospitales.clearLayers().addData(datos);
  if (!mapa.hasLayer(hospitales)) hospitales.addTo(mapa);

  const n = datos.features.length;
  if (!municipio) { resultado().innerHTML = ''; return; }
  if (!n) { resultado().textContent = 'Sin resultados'; return; }
  mapa.fitBounds(hospitales.getBounds().pad(2), { maxZoom: 12 });
  resultado().innerHTML = `<b>${n}</b> hospital(es) en ${escapar(municipio)}`;
}

export async function cargarColegios() {
  try {
    colegios.clearLayers().addData(await obtenerWFS('instituciones_educativas'));
  } catch {
    resultado().innerHTML = 'La capa <b>instituciones_educativas</b> aún no está publicada en GeoServer.';
  }
}

export async function hospitalesEnRiesgo(mapa) {
  const t = nuevoTurno();
  const datos = await obtenerWFS('v_hospitales_en_riesgo');
  if (!vigente(t)) return;
  enRiesgo.clearLayers().addData(datos).addTo(mapa);
  if (datos.features.length) mapa.fitBounds(enRiesgo.getBounds().pad(0.2));

  const filas = datos.features.map(({ properties: p }) =>
    `<tr><td>${escapar(p.nombre)}</td><td>${escapar(p.tipo_riesgo)} · ${escapar(p.nivel_riesgo)}</td></tr>`).join('');
  resultado().innerHTML = `<b>${datos.features.length}</b> hospitales dentro de zonas de riesgo:` +
    `<table><tr><th>Hospital</th><th>Riesgo</th></tr>${filas}</table>`;
}

export function limpiar(mapa) {
  nuevoTurno();
  enRiesgo.clearLayers();
  mapa.removeLayer(enRiesgo);
  document.getElementById('sel-mun').value = '';
  return cargarHospitales(mapa, '');
}

/** Llena el selector de municipios pidiendo solo el atributo nombre (sin geometría). */
export async function cargarMunicipios() {
  const datos = await obtenerWFS('municipios', { propiedades: ['nombre'] });
  const sel = document.getElementById('sel-mun');
  datos.features
    .map((f) => f.properties.nombre)
    .sort((a, b) => a.localeCompare(b, 'es'))
    .forEach((nombre) => sel.add(new Option(nombre, nombre)));
  return datos.features.length;
}
