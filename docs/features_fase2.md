# Capa de features para Ciencia de Datos

## Objetivo

Se construyó una tabla de features orientada a usuario utilizando
exclusivamente información de la capa Silver.

La tabla resultante se encuentra en:

`features.feat_usuario_movilidad`

El objetivo de esta capa es dejar información agregada y preparada para
ser utilizada posteriormente por un modelo de ciencia de datos, sin
entrenar ningún modelo durante esta fase.

## Grano

Una fila representa una identidad de usuario seudonimizada.

Cantidad total de usuarios:

70,380

La llave utilizada es:

`usuario_seudonimo`

No se exponen identificadores originales de tarjetas o usuarios.

## Fecha de corte

La fecha de corte utilizada para construir las ventanas temporales es:

`2026-07-15`

Esta fecha corresponde a la fecha máxima encontrada en los eventos
válidos disponibles en Silver.

## Ventana temporal

Se definieron features para ventanas de 7, 30 y hasta 90 días anteriores
a la fecha de corte.

Los datos fuente disponibles abarcan aproximadamente 45 días, por lo
que `eventos_ultimos_90_dias` representa todos los eventos disponibles
dentro de una ventana máxima de 90 días y no implica que existan 90 días
completos de historia.

## Diccionario de features

| Campo | Descripción |
|---|---|
| usuario_seudonimo | Identificador seudonimizado utilizado para representar al usuario sin exponer su llave original. |
| fecha_corte | Fecha máxima de los datos utilizada como referencia para construir las ventanas temporales. |
| eventos_ultimos_7_dias | Cantidad de eventos del usuario durante los últimos 7 días respecto a la fecha de corte. |
| eventos_ultimos_30_dias | Cantidad de eventos del usuario durante los últimos 30 días respecto a la fecha de corte. |
| eventos_ultimos_90_dias | Cantidad de eventos disponibles dentro de la ventana máxima de 90 días. |
| modo_mas_usado | Sistema de transporte con mayor cantidad de eventos registrados para el usuario. |
| cantidad_modos_distintos | Número de sistemas de transporte distintos utilizados por el usuario. |
| dias_desde_ultimo_evento | Cantidad de días transcurridos entre el último evento del usuario y la fecha de corte. |
| proporcion_eventos_hora_pico | Proporción de eventos realizados durante las horas pico definidas: 05:00–08:59 y 16:00–19:59. |
| zona_origen_mas_frecuente | Zona en la que el usuario registra con mayor frecuencia el origen de sus eventos. |
| gasto_acumulado_gtq | Suma de los importes asociados a los eventos observados para el usuario, expresada en quetzales. |
| gasto_promedio_evento_gtq | Promedio del importe por evento del usuario, expresado en quetzales. |

## Definición de evento

Se utiliza el término `evento` en lugar de `viaje` porque los sistemas
no tienen exactamente el mismo grano:

- Transmetro registra abordajes.
- Transurbano registra transacciones/abordajes.
- Aerómetro registra abordajes.
- MetroRiel registra viajes completos.

Esta decisión evita presentar registros con diferentes granularidades
como si fueran conceptualmente idénticos.

## Resultados de validación

La tabla produjo:

- 70,380 usuarios.
- 33,553 usuarios con un modo.
- 26,831 usuarios con dos modos.
- 9,996 usuarios con tres modos.
- 36,827 usuarios con más de un modo.

La distribución de modo más utilizado fue:

- Transurbano: 35,693 usuarios.
- Aerómetro: 14,496 usuarios.
- Transmetro: 11,317 usuarios.
- MetroRiel: 8,874 usuarios.

La zona de origen más frecuente fue Mixco, con 13,446 usuarios.

Las métricas agregadas obtenidas fueron:

- promedio de eventos últimos 7 días: 3.76;
- promedio de eventos últimos 30 días: 16.09;
- promedio de eventos en la ventana disponible de hasta 90 días: 24.00;
- proporción media de eventos en hora pico: 55.05%;
- gasto promedio por evento, promediado entre usuarios: Q1.80.

## Pruebas de calidad

Se ejecutaron 14 pruebas dbt sobre el modelo.

Resultado:

`PASS=14 WARN=0 ERROR=0`

Además de las pruebas de no nulidad y unicidad, se validó que:

`eventos_ultimos_7_dias <= eventos_ultimos_30_dias <= eventos_ultimos_90_dias`

y que:

`0 <= proporcion_eventos_hora_pico <= 1`

## Posible uso predictivo

Con esta tabla podría entrenarse posteriormente un modelo que estime la
probabilidad de que un usuario utilice más de un sistema de transporte
durante un período futuro.

Para la Agencia Metropolitana de Transporte esto podría ser útil para
identificar usuarios con mayor probabilidad de realizar viajes
multimodales y apoyar decisiones relacionadas con integración entre
modos, puntos de transbordo, capacidad e integración tarifaria.

No se entrenó ningún modelo en esta fase.