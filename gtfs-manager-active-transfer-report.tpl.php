<?php
/*
 *
 */
?>

<?php if($variables['invalid']):?>
<h1>Potentially Invalid Transfers</h1>
<p>The following transfers have been automatically marked as invalid due to a change in routes or stop times. Transfers will not be included in searches while in this list.</p>
<table class="active-transfers-table">
	<thead>
		<tr>
			<th>Stop Name</th>
			<th>From Route</th>
			<th>Arrives</th>
			<th>To Route</th>
			<th>Departs</th>
			<th>Activated By</th>
			<th>Activated On</th>
			<th>Options</th>
		</tr>
	</thead>
	<tbody>
<?php foreach ($variables['invalid'] as $transfer) { ?>
<tr>
	<td><?php print $transfer->stop_name; ?></td>
	<td><b><?php print $transfer->from_agency_name; ?>: </b><?php print $transfer->from_route_name; ?></td>
	<td><?php print $transfer->arrival_time; ?></td>
	<td><b><?php print $transfer->to_agency_name; ?>: </b><?php print $transfer->to_route_name; ?></td>
	<td><?php print $transfer->departure_time; ?></td>
	<td><?php print $transfer->updated_by; ?></td>
	<td><?php print date('d-m-Y', $transfer->updated_at); ?></td>
	<td><?php print $transfer->force_link . '<br />' . $transfer->remove_link; ?></td>

</tr>
<?php } ?>

    </tbody>
</table>
<?php endif; ?>

<h1>Active Transfers</h1>
<p>These transfers will be included in searches</p>
<?php 
$form['buttons']['approve'] = array(
				'#type' => 'button',
				'#value' => t('Approve Selected'),
				'#submit' => array('gtfs_manager_transfer_form_submit'),
				'#attributes' => array(
					'class' => array('inline'),
				),
		);
		$form['buttons']['submit'] = array(
				'#type' => 'button',
				'#value' => t('Ignore Selected'),
				'#submit' => array('gtfs_manager_transfer_form_submit'),
				'#attributes' => array(
						'class' => array('inline'),
				),
		);
?>
<table class="active-transfers-table">
	<thead>
		<tr>
			<th>Stop Name</th>
			<th>From Route</th>
			<th>Arrives</th>
			<th>To Route</th>
			<th>Departs</th>
			<th>Activated By</th>
			<th>Activated On</th>
			<th>Options</th>
		</tr>
	</thead>
	<tbody>

<?php foreach ($variables['transfers'] as $transfer) { ?>
<tr>
	<td><?php print $transfer->stop_name; ?></td>
	<td><b><?php print $transfer->from_agency_name; ?>: </b><?php print $transfer->from_route_name; ?></td>
	<td><?php print $transfer->arrival_time; ?></td>
	<td><b><?php print $transfer->to_agency_name; ?>: </b><?php print $transfer->to_route_name; ?></td>
	<td><?php print $transfer->departure_time; ?></td>
	<td><?php print $transfer->updated_by; ?></td>
	<td><?php print date('d-m-Y', $transfer->updated_at); ?></td>
	<?php if($transfer->status == 1): ?>
		<td><?php print $transfer->ignore_link . '<br />' . $transfer->remove_link; ?></td>
	<?php else: ?>
		<td><?php print $transfer->remove_link; ?></td>
	<?php endif; ?>
</tr>
<?php } ?>

    </tbody>
</table>

