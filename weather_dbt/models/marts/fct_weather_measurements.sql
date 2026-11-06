-- models/marts/fct_weather_measurements.sql
{{ config(materialized='table') }}

SELECT
    -- Clé surrogate ou composite pour la table de faits
    md5(station_id || coach_timestamp_to_string(recorded_at)) AS measurement_id, -- ou simplement un UUID / identifiant
    station_id,
    recorded_at,
    temperature,
    humidity,
    pressure,
    wind_direction,
    wind_speed,
    wind_gust,
    uv_index,
    solar_radiation,
    dew_point,
    precipitation,
    nebulosite
FROM {{ ref('int_weather_unified') }}
WHERE recorded_at IS NOT NULL