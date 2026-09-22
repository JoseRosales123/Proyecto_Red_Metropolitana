with fechas_fuente as (

    select
        fecha_hora_local::date as fecha
    from {{ ref('silver_transmetro_validaciones') }}

    union all

    select
        fecha_hora_local::date as fecha
    from {{ ref('silver_transurbano_transacciones') }}

    union all

    select
        entry_ts::date as fecha
    from {{ ref('silver_metroriel_viajes') }}

    union all

    select
        fecha_hora_local::date as fecha
    from {{ ref('silver_aerometro_boardings') }}

),

limites as (

    select
        min(fecha) as fecha_minima,
        max(fecha) as fecha_maxima
    from fechas_fuente

),

calendario as (

    select
        generate_series(
            fecha_minima,
            fecha_maxima,
            interval '1 day'
        )::date as fecha

    from limites

)

select

    to_char(fecha, 'YYYYMMDD')::integer
        as tiempo_key,

    fecha,

    extract(year from fecha)::integer
        as anio,

    extract(quarter from fecha)::integer
        as trimestre,

    extract(month from fecha)::integer
        as mes_numero,

    case extract(month from fecha)::integer
        when 1 then 'Enero'
        when 2 then 'Febrero'
        when 3 then 'Marzo'
        when 4 then 'Abril'
        when 5 then 'Mayo'
        when 6 then 'Junio'
        when 7 then 'Julio'
        when 8 then 'Agosto'
        when 9 then 'Septiembre'
        when 10 then 'Octubre'
        when 11 then 'Noviembre'
        when 12 then 'Diciembre'
    end as mes_nombre,

    extract(day from fecha)::integer
        as dia_mes,

    extract(isodow from fecha)::integer
        as dia_semana_numero,

    case extract(isodow from fecha)::integer
        when 1 then 'Lunes'
        when 2 then 'Martes'
        when 3 then 'Miercoles'
        when 4 then 'Jueves'
        when 5 then 'Viernes'
        when 6 then 'Sabado'
        when 7 then 'Domingo'
    end as dia_semana_nombre,

    case
        when extract(isodow from fecha) in (6, 7)
            then true
        else false
    end as es_fin_semana

from calendario