with base as (

    select
        usuario_integrado_aprox,

        count(distinct sistema) as cantidad_sistemas,

        string_agg(
            distinct sistema,
            ', '
            order by sistema
        ) as sistemas_asociados

    from {{ ref('silver_identidad_usuarios') }}

    group by usuario_integrado_aprox

),

dimension as (

    select

        row_number() over (
            order by usuario_integrado_aprox
        )::bigint as usuario_key,

        usuario_integrado_aprox,

        cantidad_sistemas,

        sistemas_asociados,

        (
            cantidad_sistemas > 1
        ) as es_multimodal_aprox,

        case
            when usuario_integrado_aprox like 'AM:%'
                then 'IDENTIDAD_SEPARADA_AEROMETRO'

            else 'IDENTIDAD_NUMERICA_APROX'
        end as estrategia_identidad

    from base

)

select *
from dimension