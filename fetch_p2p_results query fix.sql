SELECT
  destination.*,
  departure.* ,
  COALESCE(fa.price, fa2.price) AS price,
  string_agg(DISTINCT concat(sf.service_feature_name, '-', sf.service_feature_icon_url), ',') AS route_service_features,
  string_agg(DISTINCT concat(sf2.service_feature_name, '-', sf2.service_feature_icon_url), ',') AS agency_service_features,
  string_agg(DISTINCT concat(sf3.service_feature_name, '-', sf3.service_feature_icon_url), ',') AS from_stop_service_features,
  string_agg(DISTINCT concat(sf3.service_feature_name, '-', sf4.service_feature_icon_url), ',') AS to_stop_service_features
FROM (
  SELECT
    s.stop_name AS destination_city,
    p.code AS destination_province_code,
    s.zone_id AS destination_zone_id,
    s.sid AS destination_sid,
    s.stop_desc AS destination_description,
    st.arrival_time AS destination_arrival_time,
    st.departure_time AS destination_departure_time,
    st.stop_sequence AS destination_stop_sequence,
    a.aid AS destination_aid,
    a.agency_name AS destination_agency_name,
    a.agency_url AS destination_agency_url,
    a.agency_fare_url AS agency_fare_url,
    a.agency_info AS agency_info,
    a.agency_phone AS agency_phone,
    a.agency_email AS agency_email,
    r.route_long_name,
    r.rid,
    to_char(CAST(:date AS TIMESTAMP), 'day') AS destination_day,
    CAST(:epoc AS TEXT) AS date,
    tz.hour_offset AS destination_offset
  FROM
    stops AS s
      JOIN provinces AS p ON p.province_id = s.province_id
      JOIN stop_times AS st ON st.sid = s.sid
      JOIN trips AS t ON t.tid = st.tid
      JOIN calendar AS c ON c.service_id = t.service_id
      JOIN routes AS r ON r.rid = t.rid
      JOIN agencies AS a ON a.aid = r.aid
      JOIN time_zones AS tz ON tz.time_zone_id = s.time_zone_id
    WHERE
      s.stop_name = CAST(:d AS TEXT)
      AND p.code = CAST(:dpc AS TEXT)
      AND CAST(:epoc AS INTEGER) BETWEEN c.start_date AND c.end_date
) AS destination
JOIN (
  SELECT
    s.stop_name AS departure_city,
    p.code AS departure_province_code,
    s.zone_id AS departure_zone_id,
    s.sid AS departure_sid,
    s.stop_desc AS departure_description,
    st.departure_time AS departure_departure_time,
    st.arrival_time AS departure_arrival_time,
    st.stop_sequence AS departure_stop_sequence,
    a.agency_name AS departure_agency_name,
    a.agency_url AS departure_agency_url,
    r.route_long_name,
    r.rid,
    to_char(CAST(:date AS TIMESTAMP), 'day') AS departure_day,
    tt.transportation_type_name AS transportation_type,
    CASE
      WHEN CAST(s.wheelchair_boarding AS INTEGER) = 1 THEN 'Wheelchair access'
      ELSE ''
    END AS wheelchair_access,
    tz.hour_offset AS departure_offset
  FROM
    stops AS s
      JOIN provinces AS p ON p.province_id = s.province_id
      JOIN stop_times AS st ON st.sid = s.sid
      JOIN trips AS t ON t.tid = st.tid
      JOIN calendar AS c ON c.service_id = t.service_id
      JOIN routes AS r ON r.rid = t.rid
      JOIN agencies AS a ON a.aid = r.aid
      JOIN transportation_types AS tt ON tt.transportation_type_id = r.transportation_type_id
      JOIN time_zones AS tz ON tz.time_zone_id = s.time_zone_id
  WHERE
    s.stop_name = CAST(:o AS TEXT)
    AND p.code = CAST(:opc AS TEXT)
    AND CAST(:epoc AS INTEGER) between c.start_date AND c.end_date
    AND
    (
      ((SELECT extract(DOW FROM CAST(:date AS TIMESTAMP))) = 1 AND CAST(c.monday AS INTEGER) = 1) OR
      ((SELECT extract(DOW FROM CAST(:date AS TIMESTAMP))) = 2 AND CAST(c.tuesday AS INTEGER) = 1) OR
      ((SELECT extract(DOW FROM CAST(:date AS TIMESTAMP))) = 3 AND CAST(c.wednesday AS INTEGER) = 1) OR
      ((SELECT extract(DOW FROM CAST(:date AS TIMESTAMP))) = 4 AND CAST(c.thursday AS INTEGER) = 1) OR
      ((SELECT extract(DOW FROM CAST(:date AS TIMESTAMP))) = 5 AND CAST(c.friday AS INTEGER) = 1) OR
      ((SELECT extract(DOW FROM CAST(:date AS TIMESTAMP))) = 6 AND CAST(c.saturday AS INTEGER) = 1) OR
      ((SELECT extract(DOW FROM CAST(:date AS TIMESTAMP))) = 0 AND CAST(c.sunday AS INTEGER) = 1)
    )
  ) AS departure ON departure.rid = destination.rid
LEFT JOIN fare_rules fr ON fr.origin_id = departure.departure_zone_id
  AND fr.destination_id = destination.destination_zone_id
  AND departure.departure_zone_id != 0
  AND destination.destination_zone_id != 0
LEFT JOIN fare_attributes fa ON fa.fare_id = fr.fare_id
LEFT JOIN fare_rules fr2 ON fr2.contains_id = destination.destination_zone_id
  AND fr2.contains_id = departure.departure_zone_id
  AND fr2.contains_id != 0
LEFT JOIN fare_attributes fa2 ON fa2.fare_id = fr2.fare_id
LEFT JOIN route_service_features rsf ON rsf.rid = destination.rid
LEFT JOIN service_features sf ON sf.service_feature_id = rsf.service_feature_id
LEFT JOIN agency_service_features asf ON asf.aid = destination.destination_aid
LEFT JOIN service_features sf2 ON sf2.service_feature_id = asf.service_feature_id
LEFT JOIN stop_service_features ssf ON ssf.sid = departure.departure_sid
LEFT JOIN service_features sf3 ON sf3.service_feature_id = ssf.service_feature_id
LEFT JOIN stop_service_features ssf2 ON ssf2.sid = destination.destination_sid
LEFT JOIN service_features sf4 ON sf4.service_feature_id = ssf2.service_feature_id
GROUP BY 
  destination.destination_aid,
  destination.rid,
  destination.destination_sid,
  departure.departure_sid,

  destination.destination_city,
  destination.destination_province_code,
  destination.destination_zone_id,
  destination.destination_sid,
  destination.destination_description,
  destination.destination_arrival_time,
  destination.destination_departure_time,
  destination.destination_stop_sequence,
  destination.destination_aid,
  destination.destination_agency_name,
  destination.destination_agency_url,
  destination.agency_fare_url,
  destination.agency_info,
  destination.agency_phone,
  destination.agency_email,
  destination.route_long_name,
  destination.rid,
  destination.destination_day,
  destination.date,
  destination.destination_offset,

  departure.departure_city,
  departure.departure_province_code,
  departure.departure_zone_id,
  departure.departure_description,
  departure.departure_departure_time,
  departure.departure_arrival_time,
  departure.departure_stop_sequence,
  departure.departure_agency_name,
  departure.departure_agency_url,
  departure.route_long_name,
  departure.rid,
  departure.departure_day,
  departure.transportation_type,
  departure.wheelchair_access,
  departure.departure_offset,
  fa.price,
  fa2.price
HAVING
  destination.destination_stop_sequence > departure.departure_stop_sequence
ORDER BY
  departure_departure_time ASC,
  destination_arrival_time ASC

  Test Query:

SELECT
  destination.*,
  departure.* ,
  COALESCE(fa.price, fa2.price) AS price,
  string_agg(DISTINCT concat(sf.service_feature_name, '-', sf.service_feature_icon_url), ',') AS route_service_features,
  string_agg(DISTINCT concat(sf2.service_feature_name, '-', sf2.service_feature_icon_url), ',') AS agency_service_features,
  string_agg(DISTINCT concat(sf3.service_feature_name, '-', sf3.service_feature_icon_url), ',') AS from_stop_service_features,
  string_agg(DISTINCT concat(sf3.service_feature_name, '-', sf4.service_feature_icon_url), ',') AS to_stop_service_features
FROM (
SELECT
    s.stop_name AS destination_city,
    p.code AS destination_province_code,
    s.zone_id AS destination_zone_id,
    s.sid AS destination_sid,
    s.stop_desc AS destination_description,
    st.arrival_time AS destination_arrival_time,
    st.departure_time AS destination_departure_time,
    st.stop_sequence AS destination_stop_sequence,
    a.aid AS destination_aid,
    a.agency_name AS destination_agency_name,
    a.agency_url AS destination_agency_url,
    a.agency_fare_url AS agency_fare_url,
    a.agency_info AS agency_info,
    a.agency_phone AS agency_phone,
    a.agency_email AS agency_email,
    r.route_long_name,
    r.rid,
    to_char(TIMESTAMP '2014-08-29', 'day') AS destination_day,
    1409281200 AS date,
    tz.hour_offset AS destination_offset
  FROM
    stops AS s
      JOIN provinces AS p ON p.province_id = s.province_id
      JOIN stop_times AS st ON st.sid = s.sid
      JOIN trips AS t ON t.tid = st.tid
      JOIN calendar AS c ON c.service_id = t.service_id
      JOIN routes AS r ON r.rid = t.rid
      JOIN agencies AS a ON a.aid = r.aid
      JOIN time_zones AS tz ON tz.time_zone_id = s.time_zone_id
    WHERE
      s.stop_name = 'Halifax Airport'
      AND p.code = 'NS'
      AND 1409281200 BETWEEN c.start_date AND c.end_date
) AS destination
JOIN (
  SELECT
    s.stop_name AS departure_city,
    p.code AS departure_province_code,
    s.zone_id AS departure_zone_id,
    s.sid AS departure_sid,
    s.stop_desc AS departure_description,
    st.departure_time AS departure_departure_time,
    st.arrival_time AS departure_arrival_time,
    st.stop_sequence AS departure_stop_sequence,
    a.agency_name AS departure_agency_name,
    a.agency_url AS departure_agency_url,
    r.route_long_name,
    r.rid,
    to_char(TIMESTAMP '2014-08-29', 'day') AS departure_day,
    tt.transportation_type_name AS transportation_type,
    CASE
      WHEN CAST(s.wheelchair_boarding AS INTEGER) = 1 THEN 'Wheelchair access'
      ELSE ''
    END AS wheelchair_access,
    tz.hour_offset AS departure_offset
  FROM
    stops AS s
      JOIN provinces AS p ON p.province_id = s.province_id
      JOIN stop_times AS st ON st.sid = s.sid
      JOIN trips AS t ON t.tid = st.tid
      JOIN calendar AS c ON c.service_id = t.service_id
      JOIN routes AS r ON r.rid = t.rid
      JOIN agencies AS a ON a.aid = r.aid
      JOIN transportation_types AS tt ON tt.transportation_type_id = r.transportation_type_id
      JOIN time_zones AS tz ON tz.time_zone_id = s.time_zone_id
  WHERE
    s.stop_name = 'Halifax'
    AND p.code = 'NS'
    AND 1409281200 between c.start_date AND c.end_date
    AND
    (
      ((SELECT extract(DOW FROM TIMESTAMP '2014-08-29')) = 1 AND CAST(c.monday AS INTEGER) = 1) OR
      ((SELECT extract(DOW FROM TIMESTAMP '2014-08-29')) = 2 AND CAST(c.tuesday AS INTEGER) = 1) OR
      ((SELECT extract(DOW FROM TIMESTAMP '2014-08-29')) = 3 AND CAST(c.wednesday AS INTEGER) = 1) OR
      ((SELECT extract(DOW FROM TIMESTAMP '2014-08-29')) = 4 AND CAST(c.thursday AS INTEGER) = 1) OR
      ((SELECT extract(DOW FROM TIMESTAMP '2014-08-29')) = 5 AND CAST(c.friday AS INTEGER) = 1) OR
      ((SELECT extract(DOW FROM TIMESTAMP '2014-08-29')) = 6 AND CAST(c.saturday AS INTEGER) = 1) OR
      ((SELECT extract(DOW FROM TIMESTAMP '2014-08-29')) = 0 AND CAST(c.sunday AS INTEGER) = 1)
    )
  ) AS departure ON departure.rid = destination.rid
LEFT JOIN fare_rules fr ON fr.origin_id = departure.departure_zone_id
  AND fr.destination_id = destination.destination_zone_id
  AND departure.departure_zone_id != 0
  AND destination.destination_zone_id != 0
LEFT JOIN fare_attributes fa ON fa.fare_id = fr.fare_id
LEFT JOIN fare_rules fr2 ON fr2.contains_id = destination.destination_zone_id
  AND fr2.contains_id = departure.departure_zone_id
  AND fr2.contains_id != 0
LEFT JOIN fare_attributes fa2 ON fa2.fare_id = fr2.fare_id
LEFT JOIN route_service_features rsf ON rsf.rid = destination.rid
LEFT JOIN service_features sf ON sf.service_feature_id = rsf.service_feature_id
LEFT JOIN agency_service_features asf ON asf.aid = destination.destination_aid
LEFT JOIN service_features sf2 ON sf2.service_feature_id = asf.service_feature_id
LEFT JOIN stop_service_features ssf ON ssf.sid = departure.departure_sid
LEFT JOIN service_features sf3 ON sf3.service_feature_id = ssf.service_feature_id
LEFT JOIN stop_service_features ssf2 ON ssf2.sid = destination.destination_sid
LEFT JOIN service_features sf4 ON sf4.service_feature_id = ssf2.service_feature_id
GROUP BY 
destination.destination_aid,
  destination.rid,
  destination.destination_sid,
  departure.departure_sid,

  destination.destination_city,
  destination.destination_province_code,
  destination.destination_zone_id,
  destination.destination_sid,
  destination.destination_description,
  destination.destination_arrival_time,
  destination.destination_departure_time,
  destination.destination_stop_sequence,
  destination.destination_aid,
  destination.destination_agency_name,
  destination.destination_agency_url,
  destination.agency_fare_url,
  destination.agency_info,
  destination.agency_phone,
  destination.agency_email,
  destination.route_long_name,
  destination.rid,
  destination.destination_day,
  destination.date,
  destination.destination_offset,

  departure.departure_city,
  departure.departure_province_code,
  departure.departure_zone_id,
  departure.departure_description,
  departure.departure_departure_time,
  departure.departure_arrival_time,
  departure.departure_stop_sequence,
  departure.departure_agency_name,
  departure.departure_agency_url,
  departure.route_long_name,
  departure.rid,
  departure.departure_day,
  departure.transportation_type,
  departure.wheelchair_access,
  departure.departure_offset,
  fa.price,
  fa2.price
HAVING
  destination.destination_stop_sequence > departure.departure_stop_sequence
ORDER BY
  departure_departure_time ASC,
  destination_arrival_time ASC


