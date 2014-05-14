<?php
/**
 * @file template for route stops
 *
 *
 */
?>
 <?php print implode(' | ', $variables['links']); ?>
<h3>Route: <?php print $variables['trips'][0]->route_long_name; ?></h3>
<table class="route-trips-view">
  <thead>
    <tr>
      <th>Calendar Begins</th>
      <th>Calendar Ends</th>
      <th>Days</th>
      <th>Start Time</th>
      <th>End Time</th>
      <th>Options</th>
    </tr>
  </thead>
  <tbody>

<?php foreach ($variables['trips'] as $trip) { ?>
  <tr class="trip-row <?php print $trip->tid; ?>">
     <td><?php print $trip->start_date; ?></td>
     <td><?php print $trip->end_date; ?></td>
     <td><?php print $trip->monday; ?></td>
     <td><?php print $trip->start_time; ?></td>
     <td><?php print $trip->end_time; ?></td>
     <td><?php print implode('<br />', $trip->links); ?></td>
  </tr>
<?php } ?>
 </tbody>
</table>
