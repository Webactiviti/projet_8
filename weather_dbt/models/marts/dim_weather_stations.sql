-- models/marts/dim_weather_stations.sql
{{ config(materialized='table') }}

SELECT 
    'ILAMAD25' AS station_id,
    'La Madeleine' AS station_name,
    'la_madeleine' AS source_type,
    50.659 AS latitude,
    3.07 AS longitude,
    23 AS elevation,
    'La Madeleine' AS city,
    'EasyWeatherPro_V5.1.6' AS software

UNION ALL

SELECT 
    'IICHTE19' AS station_id,
    'WeerstationBS' AS station_name,
    'ichtegem' AS source_type,
    51.092 AS latitude,
    2.999 AS longitude,
    15 AS elevation,
    'Ichtegem' AS city,
    'EasyWeatherV1.6.6' AS software

UNION ALL

-- Vous pouvez aussi y intégrer dynamiquement les stations d'Infoclimat si besoin
SELECT DISTINCT
    station_id,
    'Station Infoclimat ' || station_id AS station_name,
    'infoclimat' AS source_type,
    NULL::numeric AS latitude,
    NULL::numeric AS longitude,
    NULL::integer AS elevation,
    NULL AS city,
    NULL AS software
FROM {{ ref('stg_infoclimat') }}