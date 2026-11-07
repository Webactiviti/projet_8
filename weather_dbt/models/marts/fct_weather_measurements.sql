-- models/marts/fct_weather_measurements.sql
{{ config(materialized='table') }}

SELECT
    station_id,
    temperature,
    humidity,
    pressure,
    wind_direction,
    wind_speed,
    wind_gust,
    uv_index,
    solar_radiation,
    dew_point,
    precipitation
FROM {{ ref('int_weather_unified') }}

