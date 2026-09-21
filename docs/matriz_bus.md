# Matriz del Bus - Red Metropolitana de Transporte

## Grano preliminar

Debido a que Transmetro, Transurbano y Aerómetro registran abordajes,
mientras que MetroRiel registra el viaje completo con origen y destino,
se trabajarán inicialmente dos procesos de negocio diferentes.

1. Abordajes:
   Una fila representa un abordaje realizado por un usuario en un
   sistema de transporte, en una fecha, hora y punto determinado.

2. Viajes MetroRiel:
   Una fila representa un viaje completo realizado por un usuario,
   incluyendo estación de origen y estación de destino.

## Matriz del Bus

| Proceso de negocio | Usuario | Tiempo | Zona | Modo de transporte | Estación / Parada | Línea / Ruta | Origen | Destino |
|---|---|---|---|---|---|---|---|---|
| Abordajes Transmetro | X | X | X | X | X | X |  |  |
| Abordajes Transurbano | X | X | X | X | X | X |  |  |
| Abordajes Aerómetro | X | X | X | X | X | X |  |  |
| Viajes MetroRiel | X | X | X | X | X |  | X | X |

## Dimensiones conformadas preliminares

- Usuario
- Tiempo
- Zona
- Modo de transporte
- Punto de servicio (estación o parada)
- Línea / ruta

Para MetroRiel también será necesario representar el origen y el destino
del viaje utilizando la dimensión de estación con distintos roles.

## Observación

Esta matriz es preliminar y podrá ajustarse durante la construcción de
Silver y Gold, pero establece desde el inicio qué dimensiones deben
compartir los diferentes procesos.