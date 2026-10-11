# Preparación de la capa Gold para la Fase 2

## 1. Cobertura territorial

Durante la revisión inicial de la capa Gold para la construcción del tablero se verificó que `dim_zona` contenía únicamente las zonas que aparecían en los catálogos de estaciones y paradas de los operadores.

El modelo original se construía a partir de `silver_zonas_conformadas`, por lo que representaba solamente zonas con presencia de algún servicio de transporte.

Sin embargo, el análisis del conjunto de datos mostró que el universo de zonas observado es mayor. El padrón de usuarios contiene 16 zonas de residencia diferentes, mientras que los catálogos de transporte presentan servicio únicamente en 15.

La zona adicional identificada fue:

- Santa Catarina Pinula

Esta zona aparece en el padrón de usuarios, pero no está incluida dentro de las zonas servidas por Transmetro, Transurbano, MetroRiel o Aerómetro.

### Modificación realizada

Se amplió `gold.dim_zona` utilizando dos fuentes de la capa Silver:

- `silver_zonas_conformadas`, para identificar las zonas con servicio.
- `silver_padron_usuarios_scd2`, para obtener el universo de zonas de residencia observado.

Ambas fuentes se integran en Gold sin acceder directamente a Bronze ni Staging.

También se agregó el atributo:

`tiene_servicio`

Este campo permite identificar si una zona cuenta con presencia de al menos uno de los sistemas de transporte.

### Resultado

Después de la modificación se obtuvieron:

- 16 zonas totales.
- 15 zonas con servicio.
- 1 zona sin servicio.
- Santa Catarina Pinula fue identificada como la única zona sin servicio.

La reconstrucción de los modelos dependientes mantuvo los conteos originales de las tablas de hechos:

- `fact_abordajes`: 1,393,448 registros.
- `fact_viajes_metroriel`: 295,511 registros.
- `dim_punto_servicio`: 468 registros.

La dimensión `dim_zona` pasó de 15 a 16 registros.

### Validación

Se ejecutaron las pruebas asociadas a la dimensión y sus dependencias sin encontrar errores.

Posteriormente se agregaron pruebas específicas para:

- no nulidad y unicidad de `zona_key`;
- no nulidad y unicidad de `zona_nombre`;
- valores permitidos de `tipo_zona`;
- no nulidad de `tiene_servicio`.

El modelo actualizado permite que el tablero de Tableau responda correctamente qué zonas tienen cobertura y cuáles quedan fuera de la red integrada.