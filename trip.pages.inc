<?php
/**
 * Form builder for new trip, trip, and trip_time
 */
function gtfs_manager_trip_form($form, &$form_state, $trip = null, $route = null) {

  //collect the route id
  $route_id = isset($route) ? $route->rid : $trip->rid;

  $time = new DateTime();

  if (!isset($trip->start_date)) {
    $trip->start_date = $time->modify("first day of January 2014")->format("U");
  }

  if (!isset($trip->end_date)) {
    $trip->end_date = $time->modify("last day of December 2014")->format("U");
  }

  //TODO: need to populate days for edit
  if (!isset($trip->days)) {
    $trip->days = array();
  }


  //Set the id ot identify this as the trip edit form
  $form['#id'] = 'trip-form';

  //save the trip for later
  $form['#trip'] = $trip;
  $form_state['trip'] = $trip;

  //hidden field for route id
  $form['gtfs_manager_rid'] = array(
    '#type' => 'hidden',
    '#value' => $route_id,
  );

  //start date popup
  $form['gtfs_manager_schedule_start_date'] = array(
    '#type' => 'date_popup',
    '#date_format' => 'd-m-Y',
    '#default_value' => date('Y-m-d H:i:s', $trip->start_date),
    '#date_year_range' => '0:+2',
    '#date_label_position' => 'invisible',
    '#title' => t('Schedule start date'),
    '#required' => TRUE,
  );

  //end date popup
  $form['gtfs_manager_schedule_end_date'] = array(
    '#type' => 'date_popup',
    '#date_format' => 'd-m-Y',
    '#default_value' => date('Y-m-d H:i:s', $trip->end_date),
    '#date_year_range' => '0:+2',
    '#date_label_position' => 'invisible',
    '#title' => t('Schedule end date'),
    '#required' => TRUE,
  );


  //checkboxes for days of the week
  $form['gtfs_manager_schedule_days'] = array(
    '#type' => 'checkboxes',
    '#options' => drupal_map_assoc(array(
			t('Monday'),
			t('Tuesday'),
			t('Wednesday'),
			t('Thursday'),
			t('Friday'),
			t('Saturday'),
			t('Sunday')
					 )),
    '#default_value' => $trip->days,
    '#title' => t('Which days will this trip run?'),
  );


  //Add buttons
  $form['buttons'] = array();
  $form['buttons']['#weight'] = 100;
  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Save trip'),
    '#weight' => 5,
    '#submit' => array('gtfs_manager_trip_form_submit'),
  );

  // display delete button in edit form
  if (!empty($trip->tid)) {
    $form['buttons']['delete'] = array(
      '#type' => 'submit',
      '#value' => t('Delete'),
      '#weight' => 15,
      '#submit' => array('gtfs_manager_trip_form_delete_submit'),
    );
  }

  $form['#validate'][] = 'gtfs_manager_trip_form_validate';

  //allow other fields to be added
  field_attach_form('trip', $trip, $form, $form_state);

  return $form;
}

//TODO: Validates start and end date and at least one day a week
function gtfs_manager_trip_form_validate($form, &$form_state) {
  $trip = $form_state['trip'];

  //Start and end date are already required fileds
  //Start date must not be out of order
  $start = date($form_state['values']['gtfs_manager_schedule_start_date']);
  $end   = date($form_state['values']['gtfs_manager_schedule_end_date']);

  if ($start >= $end) {
    form_set_error('end_date', t("End date must be after start date"));
  }

  //Must choose at lease one day of the week to run
  $days = array(
    'monday',
		'tuesday',
		'wednesday',
		'thursday',
		'friday',
		'saturday',
		'sunday',
		);

  $selected_days = $form_state['values']['gtfs_manager_schedule_days'];
  $days_counted = 0;
  foreach ($days as $day) {
    if (!empty($form_state['values']['gtfs_manager_schedule_days'][$day])) {
      $days_counted++;
    } 
  }

  if ($days_counted == 0) {
    form_set_error('gtfs_manager_schedule_days', t("Please choose at least one day for the trip to run"));
  }

}

function gtfs_manager_trip_form_submit($form, &$form_state) {
  global $user;

  $trip = $form_state['trip'];

  $is_new = empty($trip->tid);

  $service_id = empty($trip->service_id) ? '' : $trip->service_id;

  //create trip and stop time objects
  $calendar = entity_get_controller('calendar')->create($service_id);

  // if it is a new record set created_by
  if (empty($stop->created_by)) {
    $trip->created_by = $user->name;
    $calendar->created_by = $user->name;
  }

  $trip->updated_by = $user->name;
  $calendar->updated_by = $user->name;

  //Calendar Save
  $calendar->monday =
    !empty($form_state['values']['gtfs_manager_schedule_days']['monday'])
    ? 1 : 0;
  $calendar->tuesday =
    !empty($form_state['values']['gtfs_manager_schedule_days']['tuesday'])
    ? 1 : 0;
  $calendar->wednesday =
    !empty($form_state['values']['gtfs_manager_schedule_days']['wednesday'])
    ? 1 : 0;
  $calendar->thursday =
    !empty($form_state['values']['gtfs_manager_schedule_days']['thursday'])
    ? 1 : 0;
  $calendar->friday =
    !empty($form_state['values']['gtfs_manager_schedule_days']['friday'])
    ? 1 : 0;
  $calendar->saturday =
    !empty($form_state['values']['gtfs_manager_schedule_days']['saturday'])
    ? 1 : 0;
  $calendar->sunday =
    !empty($form_state['values']['gtfs_manager_schedule_days']['sunday'])
    ? 1 : 0;

  $calendar->start_date =
    strtotime($form_state['values']['gtfs_manager_schedule_start_date']);
  $calendar->end_date =
    strtotime($form_state['values']['gtfs_manager_schedule_end_date']);

  calendar_save($calendar);


  // Trip Save
  $trip->rid = $form_state['values']['gtfs_manager_rid'];
  $trip->service_id = $calendar->service_id;

  field_attach_submit('trip', $trip, $form, $form_state);

  trip_save($trip);

  drupal_set_message(t('Your trip has been submitted'));

  $form_state['redirect'] = 'route/' . $trip->rid . '/trips';
}

function gtfs_manager_route_trips_view($route) {
  $variables['route'] = $route;

  $trips = trip_load_multiple(array(), array('rid', $route->rid, '='));
  
  if (sizeof($trips > 0)) {
    $variables['trips'] = $trips;
    return theme('gtfs_manager_route_trips_view', $variables);
  } else {
    drupal_set_message('No trips have been created for this route');
  }
}

function trip_page_edit($trip) {
  drupal_set_title(t('<em>Edit trip</em>'), PASS_THROUGH);
  return drupal_get_form('gtfs_manager_trip_form', $trip);
}
	  