-- models/stg_infoclimat.sql
SELECT
    _airbyte_extracted_at AS extracted_at,
    
    -- Récupération de l'identifiant de la station depuis la clé du dictionnaire hourly
    station_key.key AS station_id,
    
    -- Extraction et typage des champs météo horaires
    (record.value ->> 'dh_utc')::timestamp AS dh_utc,
    (record.value ->> 'temperature')::numeric AS temperature,
    (record.value ->> 'pression')::numeric AS pression,
    (record.value ->> 'humidite')::numeric AS humidite,
    (record.value ->> 'point_de_rosee')::numeric AS point_de_rosee,
    (record.value ->> 'vent_moyen')::numeric AS vent_moyen,
    (record.value ->> 'vent_rafales')::numeric AS vent_rafales,
    (record.value ->> 'vent_direction')::numeric AS vent_direction,
    (record.value ->> 'pluie_1h')::numeric AS pluie_1h,
    (record.value ->> 'pluie_3h')::numeric AS pluie_3h,
    (record.value ->> 'nebulosite')::numeric AS nebulosite

FROM {{ source('infoclimat', 'infoclimat') }}

-- 1. On parcourt les clés du dictionnaire 'hourly' (les codes des stations)
CROSS JOIN LATERAL jsonb_each(hourly) AS station_key(key, value)

-- 2. Pour chaque station, on éclate le tableau de mesures en lignes individuelles
CROSS JOIN LATERAL jsonb_array_elements(station_key.value) AS record(value)