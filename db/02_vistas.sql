-- ==============================================================
--  Vista espacial: hospitales que están dentro de una zona de riesgo
--  GeoServer la publica como una capa más (consulta espacial en vivo).
-- ==============================================================
DROP VIEW IF EXISTS v_hospitales_en_riesgo;

CREATE VIEW v_hospitales_en_riesgo AS
SELECT h.id,
       h.nombre,
       h.nivel,
       m.nombre  AS municipio,          -- municipio calculado espacialmente
       z.tipo    AS tipo_riesgo,
       z.nivel   AS nivel_riesgo,
       h.geom::geometry(Point, 4326) AS geom
FROM hospitales h
JOIN zonas_riesgo z ON ST_Intersects(h.geom, z.geom)
JOIN municipios  m ON ST_Within(h.geom, m.geom);

-- GeoServer solo necesita LEER
SELECT format('GRANT SELECT ON municipios, zonas_riesgo, vias, hospitales, instituciones_educativas, v_hospitales_en_riesgo TO %I', :'app') \gexec
