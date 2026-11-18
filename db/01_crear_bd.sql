-- ==============================================================
--  Crear roles y base de datos del proyecto
--  (se ejecuta como superusuario postgres desde 02_instalar_postgis.sh)
-- ==============================================================

-- Dueño de los datos: es quien importa y modifica tablas
SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'owner', :'owner_pass')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'owner') \gexec

-- Usuario de aplicación para GeoServer: SOLO LECTURA (permisos mínimos)
SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'app', :'app_pass')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'app') \gexec

SELECT format('CREATE DATABASE %I OWNER %I ENCODING ''UTF8'' TEMPLATE template0', :'db', :'owner')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'db') \gexec

SELECT format('REVOKE ALL ON DATABASE %I FROM PUBLIC', :'db') \gexec
SELECT format('GRANT CONNECT ON DATABASE %I TO %I', :'db', :'app') \gexec
