with zonas as (

    select distinct
        zona_conformada

    from {{ ref('silver_zonas_conformadas') }}

    where zona_conformada is not null

),

dimension as (

    select

        row_number() over (
            order by zona_conformada
        )::integer as zona_key,

        zona_conformada as zona_nombre,

        case

            when zona_conformada ~ '^Zona [0-9]+$'
                then 'ZONA_URBANA'

            else 'MUNICIPIO_SECTOR'

        end as tipo_zona

    from zonas

)

select *
from dimension