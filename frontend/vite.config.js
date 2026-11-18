import { defineConfig, loadEnv } from 'vite';

// En desarrollo, /geoserver se reenvía al GeoServer local (Docker en el puerto 8080)
// para imitar lo que hace Nginx en producción: mismo origen, sin CORS.
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  const destino = env.GEOSERVER_PROXY || 'http://localhost:8080';
  return {
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
