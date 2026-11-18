/**
 * SIG Web · Departamento del Caquetá
 * Punto de entrada del visor: crea el mapa y conecta la interfaz.
 */
import 'leaflet/dist/leaflet.css';
import './style.css';
import L from 'leaflet';

import { CAQUETA } from './config.js';
import { CAPAS, CON_LEYENDA, capaPorId, colegios } from './capas.js';
import { consultarPixel, urlLeyenda, obtenerWFS } from './servicios.js';
import { mostrarEstado, tablaAtributos, escapar } from './ui.js';
import { cargarHospitales, cargarColegios, cargarMunicipios, hospitalesEnRiesgo, limpiar } from './consultas.js';

/* ---------- Mapa y mapas base ---------- */
const mapa = L.map('mapa');
mapa.fitBounds(CAQUETA);

const osm = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
  maxZoom: 19, attribution: '&copy; OpenStreetMap contributors',
}).addTo(mapa);
const satelite = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
  maxZoom: 19, attribution: 'Imágenes &copy; Esri',
});
L.control.scale({ imperial: false }).addTo(mapa);

/* ---------- Lista de capas ---------- */
function crearListaCapas() {
  const lista = document.getElementById('lista-capas');
  for (const c of CAPAS) {
    const label = document.createElement('label');
    label.className = 'capa';
    label.innerHTML = `<input type="checkbox" ${c.visible ? 'checked' : ''}> ${c.titulo} ` +
                      `<span class="tag ${c.tipo}">${c.tipo.toUpperCase()}</span>`;
    const check = label.querySelector('input');
    check.addEventListener('change', () => {
      if (!check.checked) { mapa.removeLayer(c.capa); return; }
      c.capa.addTo(mapa);
      // si la capa se acaba de publicar en GeoServer, se vuelve a pedir
      if (c.capa === colegios && !colegios.getLayers().length) cargarColegios();
    });
    lista.appendChild(label);
    if (c.visible) c.capa.addTo(mapa);
  }

  const labelSat = document.createElement('label');
  labelSat.className = 'capa';
  labelSat.innerHTML = '<input type="checkbox"> Imagen satelital de fondo';
  labelSat.querySelector('input').addEventListener('change', (e) => {
    const [quitar, poner] = e.target.checked ? [osm, satelite] : [satelite, osm];
    mapa.removeLayer(quitar);
    poner.addTo(mapa).bringToBack();
  });
  lista.appendChild(labelSat);
}

/* ---------- Leyenda generada por GeoServer ---------- */
function crearLeyenda() {
  const leyenda = document.getElementById('leyenda');
  for (const id of CON_LEYENDA) {
    leyenda.insertAdjacentHTML('beforeend',
      `<div class="ley-t">${capaPorId(id).titulo}</div><img alt="Leyenda ${id}" src="${urlLeyenda(id)}">`);
  }
}

/* ---------- Clic en el mapa: WMS GetFeatureInfo ---------- */
mapa.on('click', async (e) => {
  const visibles = CAPAS.filter((c) => c.tipo === 'wms' && mapa.hasLayer(c.capa)).map((c) => c.id);
  if (!visibles.length) return;
  try {
    const datos = await consultarPixel(mapa, e.latlng, visibles);
    if (!datos.features?.length) return;
    const html = datos.features.map((f) => {
      const capa = f.id ? f.id.split('.')[0] : '';
      const p = f.properties;
      const titulo = p.nombre ?? `${p.tipo ?? ''} (${p.nivel ?? ''})`;
      return `<h3>${escapar(titulo)}</h3><div class="capa-origen">capa: ${escapar(capa)}</div>` +
             tablaAtributos(p, ['nombre', 'id']);
    }).join('<hr>');
    L.popup().setLatLng(e.latlng).setContent(html).openOn(mapa);
  } catch (err) {
    console.error('GetFeatureInfo falló', err);
  }
});

/* ---------- Panel de consultas ---------- */
document.getElementById('sel-mun').addEventListener('change', (e) => cargarHospitales(mapa, e.target.value));
document.getElementById('btn-riesgo').addEventListener('click', () => hospitalesEnRiesgo(mapa));
document.getElementById('btn-limpiar').addEventListener('click', async () => {
  await limpiar(mapa);
  mapa.fitBounds(CAQUETA);
});

/* ---------- Arranque ---------- */
async function iniciar() {
  crearListaCapas();
  crearLeyenda();
  try {
    const n = await cargarMunicipios();
    mostrarEstado('ok', `GeoServer conectado · ${n} municipios`);
  } catch (err) {
    console.error(err);
    mostrarEstado('error', 'No se pudo conectar con GeoServer');
    return;
  }
  // cada capa WFS carga por separado: si una no está publicada, las demás siguen funcionando
  obtenerWFS('hospitales')
    .then((d) => capaPorId('hospitales').capa.addData(d))
    .catch(() => console.warn('Capa hospitales no disponible'));
  cargarColegios();
}

iniciar();

// acceso desde la consola del navegador (F12) para depurar en clase
window.mapa = mapa;
