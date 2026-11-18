/**
 * Utilidades de interfaz: estado de conexión, registro de peticiones,
 * tablas de atributos e íconos.
 */
import L from 'leaflet';

const MAX_PETICIONES = 12;

export function mostrarEstado(clase, texto) {
  document.getElementById('punto').className = `punto ${clase}`;
  document.getElementById('estado-txt').textContent = texto;
}

/** Agrega una petición al panel "Peticiones al servidor" (útil para explicar WMS/WFS). */
export function registrarPeticion(tipo, url) {
  const abs = new URL(url, location.href).href;
  const div = document.createElement('div');
  const b = document.createElement('b');
  b.textContent = tipo;
  const a = document.createElement('a');
  a.href = abs;
  a.target = '_blank';
  a.rel = 'noopener';
  a.textContent = decodeURIComponent(abs);
  div.append(b, ' ', a);
  const caja = document.getElementById('peticiones');
  caja.prepend(div);
  while (caja.children.length > MAX_PETICIONES) caja.lastChild.remove();
}

const escapar = (v) => String(v ?? '').replace(/[&<>"']/g, (c) => (
  { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]
));

/** Tabla HTML con los atributos de una entidad. */
export function tablaAtributos(props, ocultar = []) {
  const filas = Object.entries(props)
    .filter(([k]) => !ocultar.includes(k))
    .map(([k, v]) => `<tr><td>${escapar(k)}</td><td>${escapar(v)}</td></tr>`)
    .join('');
  return `<table>${filas}</table>`;
}

export function popupEntidad(props, prefijo = '') {
  return `<h3>${prefijo}${escapar(props.nombre)}</h3>${tablaAtributos(props, ['nombre', 'id'])}`;
}

/** Ícono simple (círculo o cuadro) para los puntos WFS. */
export function icono(color, forma = 'circulo') {
  const t = forma === 'cuadro' ? 11 : 13;
  const radio = forma === 'cuadro' ? '2px' : '50%';
  return L.divIcon({
    className: '',
    iconSize: [t, t],
    html: `<div style="width:${t}px;height:${t}px;background:${color};border:2px solid #fff;` +
          `border-radius:${radio};box-shadow:0 0 2px rgba(0,0,0,.6)"></div>`,
  });
}

export { escapar };
