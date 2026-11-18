# Datos

Todas las capas están en **EPSG:4326** (WGS 84, longitud/latitud) y se importan con `ogr2ogr`.

| Archivo | Entidades | Campos | Origen |
|---|---|---|---|
| `municipios.geojson` | 16 | `cod_dane`, `nombre`, `area_km2`, `acto_admin` | DANE, Marco Geoestadístico Nacional 2018 (geometría simplificada), vía [caticoa3/colombia_mapa](https://github.com/caticoa3/colombia_mapa) |
| `hospitales.geojson` | 17 | `id`, `nombre`, `nivel`, `municipio`, `cod_dane`, `fuente` | Ilustrativo: un punto cerca de cada cabecera municipal |
| `instituciones_educativas.geojson` | 32 | `id`, `nombre`, `zona`, `municipio`, `cod_dane`, `fuente` | Ilustrativo: una sede urbana y una rural por municipio |
| `vias.geojson` | 6 | `id`, `nombre`, `tipo`, `fuente` | Ilustrativo: líneas rectas entre cabeceras, no el trazado real |
| `zonas_riesgo.geojson` | 8 | `id`, `tipo`, `nivel`, `municipio`, `fuente` | Ilustrativo: áreas circulares de inundación y remoción en masa |

Las capas ilustrativas tienen `fuente = "Dato ilustrativo para la demo"` y **no deben usarse para decisiones reales**.
Todas las entidades se validaron con PostGIS: geometrías válidas y cada punto dentro de su municipio.
