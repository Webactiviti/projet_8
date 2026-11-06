-- models/intermediate/int_weather_unified.sql
{{ config(materialized='view') }}

WITH weather_la_madeleine AS (
    SELECT
        'ILAMAD25' AS station_id,
        recorded_at,
        temperature,
        humidity,
        pressure,
        wind_direction::text AS wind_direction,
        wind_speed,
        wind_gust,
        uv_index,
        solar_radiation,
        dew_point,
        precip_rate AS precipitation,
        NULL::numeric AS nebulosite
    FROM {{ ref('stg_weather_la_madeleine') }}
),

weather_ichtegem AS (
    SELECT
        'IICHTE19' AS station_id,
        recorded_at,
        temperature,
        humidity,
        pressure,
        wind_direction::text AS wind_direction,
        wind_speed,
        wind_gust,
        uv_index,
        solar_radiation,
        dew_point,
        precip_rate AS precipitation,
        NULL::numeric AS nebulosite
    FROM {{ ref('stg_weather_ichtegem') }}
),

infoclimat AS (
    SELECT
        station_id,
        dh_utc AS recorded_at,
        temperature,
        humidite AS humidity,
        pression AS pressure,
        wind_direction::text AS wind_direction,
        vent_moyen AS wind_speed,
        vent_rafales AS wind_gust,
        NULL::numeric AS uv_index,
        NULL::numeric AS solar_radiation,
        point_de_rosee AS dew_point,
        pluie_1h AS precipitation,
        nebulosite
    FROM {{ ref('stg_infoclimat') }}
)

SELECT * FROM weather_la_madeleine
UNION ALL
SELECT * FROM weather_ichtegem
UNION ALL
SELECT * FROM infoclimat