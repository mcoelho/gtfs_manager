destination query:
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
    a.agency_fare_url,
    a.agency_info,
    a.agency_phone,
    a.agency_email,
    r.route_long_name,
    r.rid,
    to_char(TIMESTAMP :date, 'day') AS destination_day,
    :epoc AS date,
    tz.hour_offset AS destination_offset
  FROM
    stops s
      JOIN provinces p ON p.province_id = s.province_id
      JOIN stop_times st ON st.sid = s.sid
      JOIN trips t ON t.tid = st.tid
      JOIN calendar c ON c.service_id = t.service_id
      JOIN routes r ON r.rid = t.rid
      JOIN agencies a ON a.aid = r.aid
      JOIN time_zones tz ON tz.time_zone_id = s.time_zone_id
    WHERE
      s.stop_name = :d
      AND p.code = :dpc
      AND :epoc BETWEEN c.start_date AND c.end_date

destination test - WORKS:
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
    a.agency_fare_url,
    a.agency_info,
    a.agency_phone,
    a.agency_email,
    r.route_long_name,
    r.rid,
    to_char(TIMESTAMP '2014-08-23', 'day') AS destination_day,
    1408762800 AS date,
    tz.hour_offset AS destination_offset
  FROM
    stops s
      JOIN provinces p ON p.province_id = s.province_id
      JOIN stop_times st ON st.sid = s.sid
      JOIN trips t ON t.tid = st.tid
      JOIN calendar c ON c.service_id = t.service_id
      JOIN routes r ON r.rid = t.rid
      JOIN agencies a ON a.aid = r.aid
      JOIN time_zones tz ON tz.time_zone_id = s.time_zone_id
    WHERE
      s.stop_name = 'Halifax Airport'
      AND p.code = 'NS'
      AND 1408762800 BETWEEN c.start_date AND c.end_date
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

departure query:

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
  to_char(TIMESTAMP :date, 'day') AS departure_day,
  tt.transportation_type_name AS transportation_type,
  CASE
    WHEN CAST(s.wheelchair_boarding AS INTEGER) = 1 THEN 'Wheelchair access'
    ELSE ''
  END AS wheelchair_access,
  tz.hour_offset AS departure_offset
FROM
  stops s
    JOIN provinces p ON p.province_id = s.province_id
    JOIN stop_times st ON st.sid = s.sid
    JOIN trips t ON t.tid = st.tid
    JOIN calendar c ON c.service_id = t.service_id
    JOIN routes r ON r.rid = t.rid
    JOIN agencies a ON a.aid = r.aid
    JOIN transportation_types tt ON tt.transportation_type_id = r.transportation_type_id
    JOIN time_zones tz ON tz.time_zone_id = s.time_zone_id
WHERE
  s.stop_name = :o
  AND p.code = :opc
  AND :epoc between c.start_date AND c.end_date
  AND
   (
    ((SELECT extract(DOW FROM TIMESTAMP :date)) = 1 AND CAST(c.monday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP :date)) = 2 AND CAST(c.tuesday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP :date)) = 3 AND CAST(c.wednesday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP :date)) = 4 AND CAST(c.thursday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP :date)) = 5 AND CAST(c.friday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP :date)) = 6 AND CAST(c.saturday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP :date)) = 0 AND CAST(c.sunday AS INTEGER) = 1)
  )

departure test - works:

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
  to_char(TIMESTAMP '2014-08-23', 'day') AS departure_day,
  tt.transportation_type_name AS transportation_type,
  CASE
    WHEN CAST(s.wheelchair_boarding AS INTEGER) = 1 THEN 'Wheelchair access'
    ELSE ''
  END AS wheelchair_access,
  tz.hour_offset AS departure_offset
FROM
  stops s
    JOIN provinces p ON p.province_id = s.province_id
    JOIN stop_times st ON st.sid = s.sid
    JOIN trips t ON t.tid = st.tid
    JOIN calendar c ON c.service_id = t.service_id
    JOIN routes r ON r.rid = t.rid
    JOIN agencies a ON a.aid = r.aid
    JOIN transportation_types tt ON tt.transportation_type_id = r.transportation_type_id
    JOIN time_zones tz ON tz.time_zone_id = s.time_zone_id
WHERE
  s.stop_name = 'Halifax'
  AND p.code = 'NS'
  AND 1408762800 between c.start_date AND c.end_date
  AND
  (
    ((SELECT extract(DOW FROM TIMESTAMP '2014-08-23')) = 1 AND CAST(c.monday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP '2014-08-23')) = 2 AND CAST(c.tuesday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP '2014-08-23')) = 3 AND CAST(c.wednesday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP '2014-08-23')) = 4 AND CAST(c.thursday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP '2014-08-23')) = 5 AND CAST(c.friday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP '2014-08-23')) = 6 AND CAST(c.saturday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP '2014-08-23')) = 0 AND CAST(c.sunday AS INTEGER) = 1)
  )
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

FULL QUERY:
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
    a.agency_fare_url,
    a.agency_info,
    a.agency_phone,
    a.agency_email,
    r.route_long_name,
    r.rid,
    to_char(TIMESTAMP :date, 'day') AS destination_day,
    :epoc AS date,
    tz.hour_offset AS destination_offset
  FROM
    stops s
      JOIN provinces p ON p.province_id = s.province_id
      JOIN stop_times st ON st.sid = s.sid
      JOIN trips t ON t.tid = st.tid
      JOIN calendar c ON c.service_id = t.service_id
      JOIN routes r ON r.rid = t.rid
      JOIN agencies a ON a.aid = r.aid
      JOIN time_zones tz ON tz.time_zone_id = s.time_zone_id
    WHERE
      s.stop_name = :d
      AND p.code = :dpc
      AND :epoc BETWEEN c.start_date AND c.end_date
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
  to_char(TIMESTAMP :date, 'day') AS departure_day,
  tt.transportation_type_name AS transportation_type,
  CASE
    WHEN CAST(s.wheelchair_boarding AS INTEGER) = 1 THEN 'Wheelchair access'
    ELSE ''
  END AS wheelchair_access,
  tz.hour_offset AS departure_offset
FROM
  stops s
    JOIN provinces p ON p.province_id = s.province_id
    JOIN stop_times st ON st.sid = s.sid
    JOIN trips t ON t.tid = st.tid
    JOIN calendar c ON c.service_id = t.service_id
    JOIN routes r ON r.rid = t.rid
    JOIN agencies a ON a.aid = r.aid
    JOIN transportation_types tt ON tt.transportation_type_id = r.transportation_type_id
    JOIN time_zones tz ON tz.time_zone_id = s.time_zone_id
WHERE
  s.stop_name = :o
  AND p.code = :opc
  AND :epoc between c.start_date AND c.end_date
  AND
   (
    ((SELECT extract(DOW FROM TIMESTAMP :date)) = 1 AND CAST(c.monday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP :date)) = 2 AND CAST(c.tuesday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP :date)) = 3 AND CAST(c.wednesday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP :date)) = 4 AND CAST(c.thursday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP :date)) = 5 AND CAST(c.friday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP :date)) = 6 AND CAST(c.saturday AS INTEGER) = 1) OR
    ((SELECT extract(DOW FROM TIMESTAMP :date)) = 0 AND CAST(c.sunday AS INTEGER) = 1)
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
a.agency_fare_url,
a.agency_info,
    a.agency_phone,
    a.agency_email,
    r.route_long_name,
    r.rid,
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
  r.route_long_name,
  r.rid,
  departure.departure_day,
  departure.transportation_type,
  departure.wheelchair_access,
  departure.departure_offset


HAVING
  destination.destination_stop_sequence > departure.departure_stop_sequence
ORDER BY
  destination.destination_aid,
  destination.rid,
  destination.destination_sid,
  departure.departure_sid,
  departure_departure_time ASC,
  destination_arrival_time ASC";
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

HAVING
  destination.destination_stop_sequence > departure.departure_stop_sequence
ORDER BY
  departure_departure_time ASC,
  destination_arrival_time ASC


TEST QUERY:

OLD QUERY:

$query =<<<SQL
  select destination.*
  ,  departure.*
  ,  ifnull(fa.price, fa2.price) as price
  ,  group_concat(distinct concat(sf.service_feature_name, '-', sf.service_feature_icon_url) separator ',') as route_service_features
  ,  group_concat(distinct concat(sf2.service_feature_name, '-', sf2.service_feature_icon_url) separator ',') as agency_service_features
  ,  group_concat(distinct concat(sf3.service_feature_name, '-', sf3.service_feature_icon_url) separator ',') as from_stop_service_features
  ,  group_concat(distinct concat(sf3.service_feature_name, '-', sf4.service_feature_icon_url) separator ',') as to_stop_service_features
from
    (
select s.stop_name as destination_city
,  p.code as destination_province_code
,  s.zone_id as destination_zone_id
,  s.sid as destination_sid
,  s.stop_desc as destination_description
,  st.arrival_time as destination_arrival_time
,  st.departure_time as destination_departure_time
,  st.stop_sequence as destination_stop_sequence
,  a.aid as destination_aid
,  a.agency_name as destination_agency_name
,  a.agency_url as destination_agency_url
,  a.agency_fare_url
,  a.agency_info
,  a.agency_phone
,  a.agency_email
,  r.route_long_name
,  r.rid
,  dayname(:date) as destination_day
,  :epoc as date
,  tz.hour_offset as destination_offset
from
 stops s
join provinces p
  on p.province_id = s.province_id
join stop_times st
  on st.sid = s.sid
join trips t
  on t.tid = st.tid
join calendar c
  on c.service_id = t.service_id
join routes r
  on r.rid = t.rid
join agencies a
  on a.aid = r.aid
join time_zones tz
  on tz.time_zone_id = s.time_zone_id
where s.stop_name = :d
and p.code = :dpc
and :epoc between c.start_date and c.end_date
#and dayname(:date) in (if(c.monday = 1, 'monday', ''), if(c.tuesday = 1, 'tuesday', ''), if(c.wednesday = 1, 'wednesday', ''), if(c.thursday = 1, 'thursday', ''), if(c.friday = 1, 'friday', ''), if(c.saturday = 1, 'saturday', ''), if(c.sunday = 1, 'sunday', ''))
) as destination
join
    (
select s.stop_name as departure_city
,  p.code as departure_province_code
,  s.zone_id as departure_zone_id
,  s.sid as departure_sid
,  s.stop_desc as departure_description
,  st.departure_time as departure_departure_time
,  st.arrival_time as departure_arrival_time
,  st.stop_sequence as departure_stop_sequence
,  a.agency_name as departure_agency_name
,  a.agency_url as departure_agency_url
,  r.route_long_name
,  r.rid
,  dayname(:date) as departure_day
,  tt.transportation_type_name as transportation_type
,  if(s.wheelchair_boarding = 1, 'Wheelchair access', '') as wheelchair_access
,  tz.hour_offset as departure_offset
from
 stops s
join provinces p
  on p.province_id = s.province_id
join stop_times st
  on st.sid = s.sid
join trips t
  on t.tid = st.tid
join calendar c
  on c.service_id = t.service_id
join routes r
  on r.rid = t.rid
join agencies a
  on a.aid = r.aid
join transportation_types tt
  on tt.transportation_type_id = r.transportation_type_id
join time_zones tz
  on tz.time_zone_id = s.time_zone_id
where s.stop_name = :o
and p.code = :opc
and :epoc between c.start_date and c.end_date
and dayname(:date) in (if(c.monday = 1, 'monday', ''), if(c.tuesday = 1, 'tuesday', ''), if(c.wednesday = 1, 'wednesday', ''), if(c.thursday = 1, 'thursday', ''), if(c.friday = 1, 'friday', ''), if(c.saturday = 1, 'saturday', ''), if(c.sunday = 1, 'sunday', ''))
) as departure
on departure.rid = destination.rid
left join fare_rules fr
  on fr.origin_id = departure.departure_zone_id
  and fr.destination_id = destination.destination_zone_id
  and departure.departure_zone_id != 0
  and destination.destination_zone_id != 0
left join fare_attributes fa
  on fa.fare_id = fr.fare_id
left join fare_rules fr2
  on fr2.contains_id = destination.destination_zone_id
  and fr2.contains_id = departure.departure_zone_id
  and fr2.contains_id != 0
left join fare_attributes fa2
  on fa2.fare_id = fr2.fare_id
left join route_service_features rsf
  on rsf.rid = destination.rid
left join service_features sf
  on sf.service_feature_id = rsf.service_feature_id
left join agency_service_features asf
  on asf.aid = destination.destination_aid
left join service_features sf2
  on sf2.service_feature_id = asf.service_feature_id
left join stop_service_features ssf
  on ssf.sid = departure.departure_sid
left join service_features sf3
  on sf3.service_feature_id = ssf.service_feature_id
left join stop_service_features ssf2
  on ssf2.sid = destination.destination_sid
left join service_features sf4
  on sf4.service_feature_id = ssf2.service_feature_id
group by destination.destination_aid, destination.rid, destination.destination_sid, departure.departure_sid
having destination.destination_stop_sequence > departure.departure_stop_sequence
  order by time(departure_departure_time) asc, time(destination_arrival_time) asc
SQL;