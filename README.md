# Red Metropolitana de Transporte

Proyecto de Ciencia de Datos orientado a integrar información de cuatro
sistemas de transporte del área metropolitana de Guatemala:

- Transmetro
- Transurbano
- MetroRiel
- Aerómetro

El proyecto construye una arquitectura de datos desde fuentes heterogéneas
hasta una capa analítica Gold, un tablero en Tableau y una capa de features
para futuros modelos de ciencia de datos.

---

## Arquitectura

La arquitectura general es:

```text
FUENTES
│
├── Streaming
│   ├── Transmetro
│   └── Aerómetro
│
├── Batch
│   ├── Transurbano
│   ├── MetroRiel
│   └── Catálogos
│
└── CDC
    └── Padrón de usuarios

        ↓

BRONZE
Parquet / lake local

        ↓

STAGING
PostgreSQL

        ↓

SILVER
dbt
├── normalización
├── calidad
├── cuarentena
├── zonas conformadas
├── identidad aproximada
├── seudonimización
└── SCD Tipo 2

        ↓

GOLD
Modelo dimensional
├── dimensiones
├── hechos
└── marts para Tableau

        ↓

TABLEAU
Dashboards de análisis

        ↓

FEATURES
Tabla por usuario para futuros modelos

---------------------------------------------------------------------------------------------------


Tecnologías utilizadas:

- Python 3.12
- Docker
- Docker Compose
- Apache Kafka
- PostgreSQL 16
- dbt-postgres
- Prefect 3
- Parquet
- Tableau Desktop
- Git / GitHub

---------------------------------------------------------------------------------------------------

Requisitos:

Antes de ejecutar el proyecto se requiere:
- Python 3.12
- Docker Desktop
- Git
- Tableau Desktop para visualizar el tablero
- PowerShell en Windows

---------------------------------------------------------------------------------------------------

Configuración inicial:

Clonar el repositorio:
git clone https://github.com/JoseRosales123/Proyecto_Red_Metropolitana.git
cd .\Proyecto_Red_Metropolitana

Crear el entorno virtual:
python -m venv .venv

Activarlo:
.\.venv\Scripts\Activate.ps1

Instalar dependencias:
pip install -r requirements.txt

---------------------------------------------------------------------------------------------------

Variables de entorno:

Crear un archivo .env en la raíz tomando como referencia:
.env.example

El archivo real .env no debe subirse al repositorio.
Ejemplo:
POSTGRES_DB=red_metropolitana
POSTGRES_USER=usuario
POSTGRES_PASSWORD=password
PSEUDONYMIZATION_KEY=clave_aleatoria

La clave de seudonimización debe ser distinta en cada instalación.

---------------------------------------------------------------------------------------------------

Levantar infraestructura:

Desde la raíz del proyecto:
docker compose up -d

Verificar:
docker compose ps

Los principales servicios utilizados son:
- Kafka: localhost:9092
- PostgreSQL: localhost:5433

---------------------------------------------------------------------------------------------------

Configuración de seudonimización:

Antes de ejecutar dbt:
. .\scripts\configurar_entorno_dbt.ps1

La extensión pgcrypto debe existir en PostgreSQL.
Puede habilitarse con:
docker compose exec postgres psql -U red_admin -d red_metropolitana -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"

También se incluye:
sql/habilitar_pgcrypto.sql

---------------------------------------------------------------------------------------------------

Ejecución del pipeline:

La orquestación principal se encuentra en:
scripts/orquestacion/flujo_fase1.py

El flujo ejecuta:
Validación Bronze
↓
Carga CDC
↓
Aplicación CDC
↓
Carga Staging
↓
Construcción Silver
↓
Calidad y cuarentena
↓
Construcción Gold
↓
Pruebas dbt
↓
Captura de métricas

---------------------------------------------------------------------------------------------------

DBT:

Entrar al proyecto dbt:
cd .\dbt_red_metropolitana

Ejecutar modelos:
dbt run

Ejecutar pruebas:
dbt test

Generar documentación y linaje:
dbt docs generate
dbt docs serve

---------------------------------------------------------------------------------------------------

Capas del proyecto:

Bronze
Contiene los datos ingeridos desde las distintas fuentes en su forma más cercana al origen.

Staging
Carga técnica previa a la transformación.

Silver
Contiene información normalizada, integrada y validada.
Incluye:
- normalización de fechas;
- montos en quetzales;
- conversión UTC a hora local;
- conformación de zonas;
- identidad aproximada;
- seudonimización;
- SCD Tipo 2;
- reglas de calidad;
- cuarentena.

Gold
Contiene el modelo dimensional utilizado para análisis.
Dimensiones principales:
dim_tiempo
dim_usuario
dim_zona
dim_modo_transporte
dim_punto_servicio

Hechos:
fact_abordajes
fact_viajes_metroriel

Marts para Tableau:
mart_demanda_horaria
mart_cobertura_zona
mart_multimodalidad
mart_metroriel_evaluacion

---------------------------------------------------------------------------------------------------

Tabla de features:

Se construyó:
features.feat_usuario_movilidad

Grano:
una fila = un usuario seudonimizado

Incluye features como:
- eventos últimos 7 días;
- eventos últimos 30 días;
- eventos dentro de la ventana disponible de hasta 90 días;
- modo más usado;
- cantidad de modos;
- días desde último evento;
- proporción en hora pico;
- zona frecuente;
- gasto acumulado;
- gasto promedio.
La tabla fue construida exclusivamente desde Silver.
No se entrenó ningún modelo.


---------------------------------------------------------------------------------------------------

Tableau:

El libro de Tableau se encuentra en:
docs/Red_Metropolitana_Fase2_Tableau.twb

Dashboards:
Panorama General — Demanda y Cobertura
Incluye:
- demanda por modo;
- demanda por hora;
- demanda por zona;
- cobertura territorial;
- multimodalidad.
Multimodalidad y evaluación MetroRiel
Incluye:
- combinaciones de sistemas;
- evaluación del trazado MetroRiel frente a la demanda observada.

---------------------------------------------------------------------------------------------------

Resultados principales:

Entre los resultados obtenidos:
- 15 de 16 zonas analizadas tienen cobertura.
- Santa Catarina Pinula es la única zona sin servicio.
- Se identificaron 70,380 usuarios aproximados.
- 36,827 utilizan más de un sistema.
- La multimodalidad aproximada es 52.33%.
- La combinación más frecuente es Transmetro + Transurbano.
- Mixco y Zona 7 presentan alta demanda observada y quedan fuera del trazado de MetroRiel.
- El trazado sí cubre zonas importantes como Zona 17 y Zona 12.

---------------------------------------------------------------------------------------------------

Calidad:

Los registros inválidos no se eliminan silenciosamente.
Se envían a cuarentena y se conserva el motivo de rechazo.
La documentación se encuentra en:
docs/reglas_calidad.md

---------------------------------------------------------------------------------------------------

Identidad y seguridad:

No existe una llave maestra real entre los operadores.
Por ello:
- Transmetro, Transurbano y MetroRiel utilizan una identidad aproximada.
- Aerómetro se mantiene separado.
- Las llaves de usuario se seudonimizan antes de Gold.
- Gold no expone identificadores fuente.
- Las credenciales no se almacenan en Git.
Documentación:
docs/estrategia_identidad.md
docs/seguridad_fase2.md

---------------------------------------------------------------------------------------------------

Gobernanza:

La gobernanza incluye:
- definiciones oficiales;
- responsables por dominio;
- diccionario de Gold;
- reglas de calidad;
- estrategia de identidad;
- linaje dbt.
Documentación:
docs/gobernanza_fase2.md

---------------------------------------------------------------------------------------------------

Idempotencia:

El pipeline fue ejecutado dos veces sin modificar los datos.
Los conteos fueron idénticos entre corridas.
Evidencias:
docs/metricas_prefect/

---------------------------------------------------------------------------------------------------

Documentación adicional:

La carpeta docs/ contiene:
arquitectura_fase1.md
estrategia_identidad.md
features_fase2.md
gobernanza_fase2.md
matriz_bus.md
modelo_dimensional.md
preparacion_gold_fase2.md
recomendacion_fase2.md
reglas_calidad.md
seguridad_fase2.md
Red_Metropolitana_Fase2_Tableau.twb
linaje_dbt_fact_abordajes.png

---------------------------------------------------------------------------------------------------

Repositorio

Rama principal:
main

Repositorio:
https://github.com/JoseRosales123/Proyecto_Red_Metropolitana

---------------------------------------------------------------------------------------------------