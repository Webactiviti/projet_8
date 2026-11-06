-- models/stg_weather_la_madeleine.sql
SELECT
    "Time"::timestamp AS recorded_at,
    "Temperature"::numeric AS temperature,
    "Humidity"::numeric AS humidity,
    "Pressure"::numeric AS pressure,
    "Wind" AS wind_direction,
    "Speed"::numeric AS wind_speed,
    "Gust"::numeric AS wind_gust,
    "UV"::numeric AS uv_index,
    "Solar"::numeric AS solar_radiation,
    "Dew_Point"::numeric AS dew_point,
    "Precip__Rate_"::numeric AS precip_rate,
    "Precip__Accum_"::numeric AS precip_accum
FROM {{ source('weather_la_madeleine', 'weather_la_madeleine') }}