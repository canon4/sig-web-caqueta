-- ==============================================================
--  Consultas espaciales para mostrar en clase (diapositiva 22)
-- ==============================================================

\echo '--- 1. ¿En qué municipio está cada hospital? (ST_Within) ---'
SELECT h.nombre AS hospital, h.nivel, m.nombre AS municipio
FROM hospitales h
JOIN municipios m ON ST_Within(h.geom, m.geom)
ORDER BY m.nombre;

\echo '--- 2. Hospitales ubicados en zonas de riesgo (ST_Intersects) ---'
SELECT nombre, municipio, tipo_riesgo, nivel_riesgo
FROM v_hospitales_en_riesgo
ORDER BY nivel_riesgo, municipio;

\echo '--- 3. Área de cada municipio en km² calculada con PostGIS ---'
-- geography calcula sobre el elipsoide, en metros reales
SELECT nombre,
       round((ST_Area(geom::geography) / 1e6)::numeric, 1) AS area_km2_postgis,
       area_km2 AS area_km2_dane
FROM municipios
ORDER BY area_km2_postgis DESC
LIMIT 5;

\echo '--- 4. Sedes rurales: distancia al hospital más cercano (operador <-> + índice) ---'
SELECT e.nombre AS institucion, h.nombre AS hospital_mas_cercano,
       round((ST_Distance(e.geom::geography, h.geom::geography) / 1000)::numeric, 2) AS km
FROM instituciones_educativas e
CROSS JOIN LATERAL (
  SELECT nombre, geom FROM hospitales
  ORDER BY hospitales.geom <-> e.geom      -- vecino más cercano usando el índice espacial
  LIMIT 1
) h
WHERE e.zona = 'Rural'
ORDER BY km DESC
LIMIT 8;

\echo '--- 5. Longitud de vías por municipio (ST_Intersection) ---'
SELECT m.nombre AS municipio,
       round((sum(ST_Length(ST_Intersection(v.geom, m.geom)::geography)) / 1000)::numeric, 1) AS km_vias
FROM vias v
JOIN municipios m ON ST_Intersects(v.geom, m.geom)
GROUP BY m.nombre
ORDER BY km_vias DESC;
