# Seguridad y manejo de datos personales

## 1. Manejo de credenciales

Las credenciales reales del proyecto se mantienen en el archivo `.env`, el cual está excluido del repositorio mediante `.gitignore`.

En Git únicamente se conserva `.env.example`, que documenta las variables necesarias sin incluir valores reales.

Para la seudonimización también se utiliza `PSEUDONYMIZATION_KEY`, cuyo valor real se genera localmente y no se almacena en el repositorio.

## 2. Seudonimización de usuarios

Los sistemas de transporte utilizan identificadores diferentes y la integración realizada en Silver produce una identidad aproximada.

Esta identidad es necesaria para relacionar registros entre operadores, pero no debe exponerse directamente en la capa Gold.

Se implementó una etapa adicional en Silver que genera `usuario_seudonimo` mediante HMAC-SHA256 y una clave secreta almacenada fuera del repositorio.

De esta manera, la misma identidad aproximada produce siempre el mismo seudónimo, pero Gold no necesita conservar la llave original ni el identificador utilizado internamente para la integración.

La capa Gold únicamente conserva:

- `usuario_key`
- `usuario_seudonimo`
- cantidad de sistemas asociados
- sistemas asociados
- indicador aproximado de multimodalidad
- estrategia de identidad

Se verificó además que Gold no contiene las columnas `usuario_integrado_aprox`, `llave_original` ni `usuario_fuente`.

## 3. Acceso por tipo de usuario

Se propone separar el acceso según la función de cada usuario.

Un analista de inteligencia de negocios o usuario de Tableau debe trabajar únicamente con Gold, donde la información ya está integrada y seudonimizada.

El equipo de ingeniería de datos puede requerir acceso a Silver para mantener los procesos de integración, calidad y trazabilidad.

El acceso al detalle que permita relacionar identificadores fuente debe reservarse a personal autorizado, por ejemplo para investigaciones de auditoría o fraude, y no formar parte del acceso normal de los analistas.

La administración de credenciales y secretos debe mantenerse restringida a los responsables técnicos de la plataforma.

## 4. Retención

Como política propuesta, el detalle individual se conservaría durante un máximo de 180 días.

Este período permite realizar análisis históricos y construir ventanas de características de hasta 90 días, dejando además margen para revisiones operativas o auditorías.

Después de ese período, el detalle individual debería eliminarse o archivarse bajo controles de acceso más restrictivos. Las métricas agregadas necesarias para análisis históricos pueden conservarse por períodos mayores debido a que presentan un menor nivel de exposición individual.

La seudonimización reduce la exposición de los identificadores, pero no convierte los datos de movilidad en información completamente anónima, por lo que los controles de acceso y retención continúan siendo necesarios.