-- ==============================================================
--  Paso 3.2 · Revisar geometrías y sistemas de referencia
-- ==============================================================

\echo '--- 1. Tipo de geometría y SRID registrados por tabla ---'
SELECT f_table_name AS tabla, type AS tipo_geometria, srid
FROM geometry_columns
WHERE f_table_schema = 'public'
ORDER BY 1;

\echo '--- 2. Geometrías inválidas (debe dar 0 en todas) ---'
SELECT 'municipios' AS tabla, count(*) FILTER (WHERE NOT ST_IsValid(geom)) AS invalidas, count(*) AS total FROM municipios
UNION ALL SELECT 'zonas_riesgo', count(*) FILTER (WHERE NOT ST_IsValid(geom)), count(*) FROM zonas_riesgo
UNION ALL SELECT 'vias', count(*) FILTER (WHERE NOT ST_IsValid(geom)), count(*) FROM vias
UNION ALL SELECT 'hospitales', count(*) FILTER (WHERE NOT ST_IsValid(geom)), count(*) FROM hospitales
UNION ALL SELECT 'instituciones_educativas', count(*) FILTER (WHERE NOT ST_IsValid(geom)), count(*) FROM instituciones_educativas;

\echo '--- 3. Índices espaciales (GIST) ---'
SELECT tablename AS tabla, indexname AS indice
FROM pg_indexes
WHERE schemaname = 'public' AND indexdef ILIKE '%gist%'
ORDER BY 1;

\echo '--- 4. Extensión geográfica de los municipios (¿cae en el Caquetá?) ---'
SELECT ST_Extent(geom) AS extension_lon_lat FROM municipios;
-- Esperado aprox.: BOX(-76.3 -0.7, -71.3 3.0)  (Solano llega casi hasta -71.3)

\echo '--- Si una geometría fuera inválida, se corrige así: ---'
\echo '    UPDATE tabla SET geom = ST_MakeValid(geom) WHERE NOT ST_IsValid(geom);'
