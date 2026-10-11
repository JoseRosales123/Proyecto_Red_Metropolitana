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

## 2. Granularidad temporal para análisis de demanda

Durante la revisión de la capa Gold se identificó que `dim_tiempo` tenía inicialmente un grano diario. La dimensión contenía 45 registros, uno por cada fecha del período analizado.

Aunque las tablas de hechos conservaban los timestamps completos de los abordajes y viajes, la relación con `dim_tiempo` se realizaba únicamente por fecha. Esto impedía utilizar la dimensión para analizar directamente la demanda por hora y clasificar los registros según hora pico.

### Modificación realizada

Se cambió el grano de `dim_tiempo` a:

**Una fila por combinación de fecha y hora.**

Para cada uno de los 45 días del período se generaron las 24 horas del día, obteniendo 1,080 registros.

La dimensión incorpora ahora:

- `hora`, con valores entre 0 y 23;
- `fecha_hora_inicio`, que representa el inicio de cada hora;
- `es_dia_habil`, para diferenciar lunes a viernes de fines de semana;
- `es_hora_pico`, para identificar las franjas de mayor demanda.

La llave `tiempo_key` también fue ampliada para representar fecha y hora. Por ejemplo:

`2026060107`

representa el 1 de junio de 2026 a las 07:00.

### Definición de hora pico

La definición se basó en la distribución utilizada por el generador de datos del proyecto, el cual simula dos períodos de mayor demanda durante el día.

Se clasificaron como horas pico:

- 05:00 a 08:59
- 16:00 a 19:59

El resto de horas se consideran fuera de hora pico.

Para `es_dia_habil` se consideran hábiles los días de lunes a viernes. No se incorporó un calendario de días festivos debido a que esa información no forma parte de los datos proporcionados.

### Integración con las tablas de hechos

`fact_abordajes` se relaciona ahora con la dimensión utilizando la fecha y la hora de `fecha_hora_local`.

Para MetroRiel se utiliza la fecha y hora de `entry_ts`, por lo que el momento temporal asociado al viaje corresponde al inicio del trayecto.

Después de reconstruir los modelos se conservaron los conteos originales:

- `fact_abordajes`: 1,393,448 registros.
- `fact_viajes_metroriel`: 295,511 registros.

La dimensión `dim_tiempo` pasó de 45 a 1,080 registros.

### Validación

Se verificó que:

- existen 45 fechas distintas;
- cada fecha cuenta con las 24 horas;
- la hora mínima es 0 y la máxima es 23;
- existen 360 combinaciones fecha-hora clasificadas como hora pico;
- existen 792 combinaciones correspondientes a días hábiles;
- las horas pico corresponden únicamente a 5, 6, 7, 8, 16, 17, 18 y 19.

Las pruebas de dbt asociadas a la dimensión tiempo y sus tablas de hechos finalizaron correctamente sin errores.

Este cambio permite analizar desde Tableau cuándo se concentra la demanda y comparar el comportamiento entre horas pico y períodos de menor demanda.