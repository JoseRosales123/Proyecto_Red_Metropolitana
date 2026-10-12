# Gobernanza de datos — Red Metropolitana de Transporte

## Objetivo

La gobernanza del proyecto busca que los cuatro sistemas integrados
utilicen definiciones consistentes y que cualquier métrica presentada
en Gold o Tableau pueda rastrearse hasta su fuente original.

## Definiciones oficiales

### Evento de movilidad

Se utiliza el término evento de movilidad cuando se analiza de manera
integrada la actividad de los cuatro sistemas.

Esto se debe a que el grano no es idéntico:

- Transmetro: un abordaje válido.
- Transurbano: una transacción o abordaje válido.
- Aerómetro: un abordaje válido.
- MetroRiel: un viaje completo válido.

Por lo tanto, no se debe interpretar un evento de cada sistema como
exactamente la misma unidad de negocio.

### Viaje

Para MetroRiel, un viaje corresponde a un registro válido con estación
de origen, estación de destino y tiempos de entrada y salida.

En análisis agregados de toda la red se evita utilizar el término viaje
como equivalente para los cuatro operadores.

### Usuario activo

Se considera usuario activo a una identidad seudonimizada que presenta
al menos un evento válido dentro de la ventana temporal evaluada.

La identidad entre Transmetro, Transurbano y MetroRiel es aproximada.
Aerómetro se mantiene separado por no contar con una llave comparable.

### Usuario multimodal aproximado

Identidad seudonimizada asociada con más de un sistema de transporte.

Debe denominarse aproximado porque no existe una llave maestra oficial
compartida entre todos los operadores.

### Hora pico

Se consideran horas pico:

- mañana: 05:00 a 08:59;
- tarde: 16:00 a 19:59.

### Zona con servicio

Una zona tiene servicio cuando existe al menos un punto de servicio de
alguno de los cuatro modos dentro del universo integrado.

## Dueños por dominio

| Dominio | Responsable propuesto | Responsabilidad |
|---|---|---|
| Tiempo | Agencia Metropolitana de Transporte | Autorizar cambios en calendario, día hábil y definición de hora pico. |
| Zona | Unidad de Planeación Territorial | Autorizar equivalencias, nombres y conformación territorial. |
| Usuario | Unidad de Gobernanza y Seguridad de Datos | Autorizar reglas de identidad, seudonimización y acceso al detalle individual. |
| Modo de transporte | Unidad de Integración Operativa | Mantener catálogo oficial de operadores y modos. |
| Punto de servicio | Cada operador, bajo estándar de la Agencia | Mantener estaciones, paradas, rutas y relación con zonas. |
| Métricas Gold | Unidad de Analítica de la Agencia | Mantener las definiciones oficiales utilizadas en reportes y Tableau. |

## Diccionario resumido de Gold

### dim_usuario

| Campo | Significado |
|---|---|
| usuario_key | Llave sustituta de Gold. |
| usuario_seudonimo | Identificador seudonimizado usado en análisis. |
| cantidad_sistemas | Cantidad de sistemas asociados a la identidad aproximada. |
| sistemas_asociados | Lista de sistemas asociados. |
| es_multimodal_aprox | Indica si la identidad aparece en más de un sistema. |
| estrategia_identidad | Estrategia utilizada para construir la identidad. |

### dim_tiempo

| Campo | Significado |
|---|---|
| tiempo_key | Llave de fecha y hora. |
| fecha | Fecha calendario. |
| hora | Hora del día. |
| anio | Año. |
| trimestre | Trimestre. |
| mes_numero | Número de mes. |
| mes_nombre | Nombre del mes. |
| dia_mes | Día del mes. |
| dia_semana_numero | Día ISO de la semana. |
| dia_semana_nombre | Nombre del día. |
| es_fin_semana | Indica sábado o domingo. |
| es_dia_habil | Indica lunes a viernes. |
| es_hora_pico | Indica si pertenece a las franjas pico definidas. |

### dim_zona

| Campo | Significado |
|---|---|
| zona_key | Llave sustituta de zona. |
| zona_nombre | Nombre conformado de la zona o municipio. |
| tipo_zona | Clasificación ZONA_URBANA o MUNICIPIO_SECTOR. |
| tiene_servicio | Indica presencia de al menos un sistema. |

### dim_modo_transporte

Contiene el catálogo conformado de Transmetro, Transurbano, MetroRiel
y Aerómetro.

### dim_punto_servicio

Representa estaciones o paradas conformadas por modo y zona.

### fact_abordajes

Grano oficial:

Una fila representa un abordaje válido.

Incluye Transmetro, Transurbano y Aerómetro.

Medida principal:

`cantidad_abordajes = 1`

### fact_viajes_metroriel

Grano oficial:

Una fila representa un viaje completo válido de MetroRiel.

Medida principal:

`cantidad_viajes = 1`

## Calidad

Los registros inválidos no se eliminan silenciosamente.

Se mantienen en cuarentena con su motivo de rechazo.

Las reglas y conteos se encuentran documentados en:

`docs/reglas_calidad.md`

## Identidad y privacidad

La estrategia de integración de usuarios se encuentra documentada en:

`docs/estrategia_identidad.md`

Gold utiliza usuarios seudonimizados y no expone las llaves fuente.

## Linaje

El linaje se genera mediante dbt.

El flujo conceptual es:

Fuente
→ Staging
→ Silver
→ Gold / Features
→ Tableau

Los modelos Gold no leen directamente desde Bronze.

La evidencia gráfica del linaje se genera con `dbt docs generate` y
se conserva junto con la documentación final del proyecto.