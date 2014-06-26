<?php

class TripController extends DrupalDefaultEntityController {

  /**
   * create empty route object
   *
   * @param $rid the route id, may be used if on update
   *
   * @return the empty Route object
   */
  public function create($tid = '') {
    return (object) array(
      'tid' => $tid,
      'rid' => '',
      'service_id' => '',
      'created_at' => '',
      'updated_at' => '',
      'created_by' => '',
      'updated_by' => '',
    );
  }

  public function save($trip) {
    $transaction = db_transaction();

    try {
      global $user;
      
      //determine if trip is new
      $trip->is_new = empty($trip->tid);

      //set timestamps
      if (empty($trip->created_at)) {
	$trip->created_at = REQUEST_TIME;
      }

      $trip->updated_at = REQUEST_TIME;

      // give other modules a chance to prepare field data
      field_attach_presave('trip', $trip);

      // if this is a new trip
      if ($trip->is_new) {
	// Save the trip
	drupal_write_record('trips', $trip);
	$op = 'insert';
      } else {
	// update the trip
	drupal_write_record('trips', $trip, 'tid');
	$op = 'update';
      }

      // Save fields
      $function = 'field_attach_' . $op;
      $function('trip', $trip);

      module_invoke_all('entity_' . $op, $trip, 'trip');

      // Clear internal properties
      unset($trip->is_new);

      // Ignore slave server temporarily to give time for insert/update
      db_ignore_slave();

      return $trip;

    } catch (Exception $e) {
      $transaction->rollback();
      watchdog_exception('trip', $e, NULL, WATCHDOG_ERROR);
      return FALSE;
    }
  }

  public function delete($tids) {
    if (!empty($tids)) {
      
      $transaction = db_transaction();

      try {
	db_delete('trips')
	  ->condition('tid', $tids, 'IN')
	  ->execute();

	db_ignore_slave();

      } catch (Exception $e) {
	$transaction->rollback();
	watchdog_exception('trip', $e, NULL, WATCHDOG_ERROR);
	return FALSE;
      }

      //Clear the page, block, and route caches
      cache_clear_all();
      $this->resetCache();
    }
    return TRUE;
  }


  public function getTrips($tids, $conditions = array()) {
    $trips = array();
    $where = '';
    $where_args = array();
    
    if (!empty($tids)) {
      if (sizeof($tids) > 1) {
        $where = 't.tid in :tids';
        $where_args = array(':tids' => '(' . join(',', $tids) . ')');
      } else {
      	$where = 't.tid = :tid';
      	$where_args = array(':tid' => $tids[0]);
      }
    } else {
      $where = 't.rid = :rid';
      $where_args = array(':rid' => $conditions[1]);
    }
    
    $query = "select t.tid
              , st.arrival_time as end_time
              , st.departure_time as start_time
              , t.rid
              , r.route_long_name
              , t.service_id
              , to_char(to_timestamp(CAST(c.start_date AS INTEGER)), 'DD-MM-YYYY') as start_date
              , to_char(to_timestamp(CAST(c.end_date AS INTEGER)), 'DD-MM-YYYY') as end_date
              , c.monday
              , c.tuesday
              , c.wednesday
              , c.thursday
              , c.friday
              , c.saturday
              , c.sunday
            from
              {trips} t
                join {routes} r on r.rid = t.rid
                left join {stop_times} st on st.tid = t.tid
                join {calendar} c on c.service_id = t.service_id
              where
                ". $where ." order by st.departure_time";
    
    $result = db_query($query, $where_args);
    
    if ($result) {
      while ($trip = $result->fetchObject()) {
    	$days = array();
    	if ($trip->monday == 1) { $days['monday'] = 'monday'; }
    	if ($trip->tuesday == 1) { $days['tuesday'] = 'tuesday'; }
    	if ($trip->wednesday == 1) { $days['wednesday'] = 'wednesday'; }
    	if ($trip->thursday == 1) { $days['thursday'] = 'thursday'; }
    	if ($trip->friday == 1) { $days['friday'] = 'friday'; }
    	if ($trip->saturday == 1) { $days['saturday'] = 'saturday'; }
    	if ($trip->sunday == 1) { $days['sunday'] = 'sunday'; }
    	$trip->days = $days;
	
	$trips[] = $trip;
      }
    }
    return $trips;
  }
 
}