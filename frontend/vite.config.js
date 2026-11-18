import { defineConfig, loadEnv } from 'vite';

// En desarrollo, /geoserver se reenvía al GeoServer de Docker (puerto GS_PORT=8086)
// para imitar lo que hace Nginx en producción: mismo origen, sin CORS.
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  const destino = env.GEOSERVER_PROXY || 'http://localhost:8086';   // GS_PORT de .env
  return {
    base: './',   // rutas relativas: el build funciona en / o en una subruta
    server: {
      port: 5173,
      proxy: { '/geoserver': { target: destino, changeOrigin: true } },
    },
    preview: {
      port: 4173,
      proxy: { '/geoserver': { target: destino, changeOrigin: true } },
    },
    build: { outDir: 'dist', sourcemap: true },
  };
});
