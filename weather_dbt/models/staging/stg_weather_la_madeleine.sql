-- models/staging/stg_weather_la_madeleine.sql


WITH raw_data AS (
    -- ÉTAPE 1 : Récupération des données brutes de la source Airbyte
    SELECT * FROM {{ source('weather_la_madeleine', 'weather_la_madeleine') }}
),

cleaned_strings AS (
    -- ÉTAPE 2 : Nettoyage global des caractères invisibles et des unités
    SELECT
        "Time"::time AS recorded_at,
        
        -- On ajoute ::text sur les colonnes qui peuvent être lues comme numériques par défaut
        REPLACE(REPLACE(REPLACE("Temperature"::text, E'\\xA0', ''), ' °F', ''), '°F', '') AS raw_temp,
        REPLACE(REPLACE("Humidity"::text, E'\\xA0', ''), '%', '') AS raw_humidity,
        REPLACE(REPLACE("Pressure"::text, E'\\xA0', ''), 'in', '') AS raw_pressure,
        TRIM(REPLACE("Wind"::text, E'\\xA0', '')) AS wind_direction,
        REPLACE(REPLACE("Speed"::text, E'\\xA0', ''), 'mph', '') AS raw_speed,
        REPLACE(REPLACE("Gust"::text, E'\\xA0', ''), 'mph', '') AS raw_gust,
        
        -- AJOUT DU CAST ::text ICI pour éviter l'erreur de fonction REPLACE sur un type numeric
        REPLACE("UV"::text, E'\\xA0', '') AS raw_uv,
        
        REPLACE(REPLACE(REPLACE("Solar"::text, E'\\xA0', ''), ' w/m²', ''), 'w/m²', '') AS raw_solar,
        REPLACE(REPLACE(REPLACE("Dew_Point"::text, E'\\xA0', ''), ' °F', ''), '°F', '') AS raw_dew_point,
        REPLACE(REPLACE("Precip__Rate_"::text, E'\\xA0', ''), 'in', '') AS raw_precip_rate,
        REPLACE(REPLACE("Precip__Accum_"::text, E'\\xA0', ''), 'in', '') AS raw_precip_accum
    FROM raw_data
),

extracted_numbers AS (
    -- ÉTAPE 3 : Extraction chirurgicale des nombres via Regex et conversion en NULL si vide
    SELECT
        recorded_at,
        NULLIF(TRIM(REGEXP_REPLACE(raw_temp, '[^0-9.-]', '', 'g')), '')::numeric AS temp_f,
        NULLIF(TRIM(REGEXP_REPLACE(raw_humidity, '[^0-9.]', '', 'g')), '')::numeric AS humidity,
        NULLIF(TRIM(REGEXP_REPLACE(raw_pressure, '[^0-9.]', '', 'g')), '')::numeric AS pressure_in,
        wind_direction,
        NULLIF(TRIM(REGEXP_REPLACE(raw_speed, '[^0-9.]', '', 'g')), '')::numeric AS speed_mph,
        NULLIF(TRIM(REGEXP_REPLACE(raw_gust, '[^0-9.]', '', 'g')), '')::numeric AS gust_mph,
        NULLIF(TRIM(REGEXP_REPLACE(raw_uv, '[^0-9.]', '', 'g')), '')::numeric AS uv_index,
        NULLIF(TRIM(REGEXP_REPLACE(raw_solar, '[^0-9.]', '', 'g')), '')::numeric AS solar_radiation,
        NULLIF(TRIM(REGEXP_REPLACE(raw_dew_point, '[^0-9.-]', '', 'g')), '')::numeric AS dew_point_f,
        NULLIF(TRIM(REGEXP_REPLACE(raw_precip_rate, '[^0-9.]', '', 'g')), '')::numeric AS precip_rate_in,
        NULLIF(TRIM(REGEXP_REPLACE(raw_precip_accum, '[^0-9.]', '', 'g')), '')::numeric AS precip_accum_in
    FROM cleaned_strings
)

-- ÉTAPE 4 : Conversion finale aux unités métriques (Celsius, km/h, hPa, mm)
SELECT
    recorded_at,
    ROUND((temp_f - 32) / 1.8, 2) AS temperature,
    humidity,
    ROUND(pressure_in * 33.8639, 2) AS pressure,
    wind_direction,
    ROUND(speed_mph * 1.60934, 2) AS wind_speed,
    ROUND(gust_mph * 1.60934, 2) AS wind_gust,
    uv_index,
    solar_radiation,
    ROUND((dew_point_f - 32) / 1.8, 2) AS dew_point,
    ROUND(precip_rate_in * 25.4, 2) AS precip_rate,
    ROUND(precip_accum_in * 25.4, 2) AS precip_accum
FROM extracted_numbers

