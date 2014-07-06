select sum(
	CASE
		WHEN COALESCE(CAST(st.arrival_time AS TIME), CAST('00:00' AS TIME)) > CAST(st2.departure_time as TIME) 
			THEN 1
		ELSE 0
	END
	)
from stop_times AS st
join trips AS t ON t.tid = st.tid
join trips AS t2 ON t2.rid = t.rid
join stop_times st2 on st2.tid = t2.tid and st2.stop_sequence = st.stop_sequence + 1
where t.rid = CAST(:rid AS INTEGER)
	and st2.sid in (
		select st.sid
		from stop_times AS st
			join trips AS t on t.tid = st.tid
		where stop_sequence between :depart and :dest and t.rid = :rid
	)
group by t.rid