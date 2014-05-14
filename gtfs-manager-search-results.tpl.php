<?php
/**
 * @file search results page template
 */
?>
	<div class="trip-holder departing">
				<!--<p><small><em>Fare prices are subject to chage.</em></small></p>
   <a href="#" class="change-date prev">Previous day</a> |
  <a href="#" class="change-date next">Next day</a>-->
				<div class="trip-title">
					<ul class="trip-text">
						<li><h5>Your Departing Trip</h5></li>
						<li><h1>
								<i class="icon-map-marker"></i>
								<?php print $from; ?>
								to
								<?php print $to; ?>
							</h1></li>
					</ul>
					<ul class="trip-date">
						<li><i class="icon-calendar-empty"></i> <?php print $date; ?></li>
						<?php if(strtotime('-1 day', $timestamp) >= strtotime('today midnight')){?>
						<li><a class="btn" href="<?php echo "/gtfs_search/$fromcity/$fromprov/$tocity/$toprov/" . strtotime('-1 day', $timestamp) . "/$return_timestamp"; ?>">Prev day</a></li>
						<?php } else {?>
						<li><span class="btn disabled">Prev Day</span></li>
						<?php } ?>
						<?php if(isset($return_timestamp) && strtotime('+1 day', $timestamp) > $return_timestamp){?>
						<li><span class="btn disabled">Next Day</span></li>
						<?php } else { ?>
						<li><a class="btn" href="<?php echo "/gtfs_search/$fromcity/$fromprov/$tocity/$toprov/" . strtotime('+1 day', $timestamp) . "/$return_timestamp"; ?>">Next day</a></li>
						<?php } ?>
					</ul>
				</div>
				<div class="table-holder">
					<img src="/sites/all/themes/atlantica/img/gesture.png" alt="Swipe Left" class="table-gesture">
					<table class="trip-table departing">
						<thead>
							<tr>
								<th>Depart</th>
								<th>Arrive</th>
								<th>Duration</th>
								<th>Cost*</th>
								<th class="center">Transfers</th>
								<th>Features</th>
								<th>Type</th>
								<th>Transporter</th>
								<th class="center">Info</th>
							</tr>
						</thead>
						<tbody>
							<?php $i = 1; ?>
							<?php foreach ($results as $result) { ?>
							<?php $fromaddr = str_replace($from . '- ', '', str_replace($from . ' - ', '', $result->departure_description));
	      	$toaddr = str_replace($to . '- ', '', str_replace($to . ' - ', '', $result->destination_description)); ?>
							<tr>
								<td><?php print date("g:i a", strtotime($result->departure_departure_time)); ?></td>
								<td><?php print date("g:i a", strtotime($result->destination_arrival_time)); ?></td>
								<td><?php print $result->duration . $result->days; ?></td>
								<td><?php print $result->price; ?></td>
								<td class="center"><?php print $result->transfer;?></td>
								<td><?php print $result->features;?></td>
								<td><?php print $result->transportation_type; ?></td>
								<td><?php print stripslashes($result->provider); ?></td>
								<td class="center"><a
									data-expander="#trip-<?php print $i; ?>-details" href="#"><i
										class="icon-chevron-down"></i> </a>
								</td>
							</tr>
							<tr id="trip-<?php print $i; ?>-details" class="expandable">
								<td colspan="9">
									<ul class="trip-breakdown-title departure">
										<li><h1>
												<span>A</span>
											</h1>
										
										<li>
											<h1>
												<?php print $from; ?>
											</h1>
										</li>
									</ul>
									<ul class="trip-breakdown">
										<li>
											<ul>
												<li class="time"><h2>
<<<<<<< HEAD
														<?php print date("g:i a", strtotime($result->departure_departure_time)); ?>
=======
														<?php print $result->departure_departure_time; ?>
>>>>>>> e0fba5c24269722bb29dafd2c52af0193f74fb56
													</h2></li>
												<li class="location"><h6>
														Depart from
														<?php print $from; ?>
													</h6>
													<p>
														<?php print $fromaddr; ?>
												
												</li>
												<li class="cost"><h6>
														<?php (isset($result->num_transfers) ? print '$' . $result->first_leg_price : print $result->price); ?>
													</h6></li>
												<li class="transporter"><a target="_blank"
													href="<?php print $result->departure_agency_url; ?>"><?php print stripslashes($result->departure_agency_name); ?>
														<i class="icon-external-link"></i> </a>
													<p>
														<?php print $result->agency_phone; ?>
												
												</li>
											</ul>
										</li>
										<?php if($result->num_transfers){?>
											<li class="transfer">
												<h4><i class="icon-random"></i> Transfer</h4>
												<ul>
													<li class="time"><h2><?php print date("g:i a", strtotime($result->departure_transfer_departure_time)); ?></h2></li>
													<li class="location">
														<h6>Arrive at <?php print $result->from_stop_name; ?></h6>
													</li>
													<li class="transporter">
														<p><small><i class="icon-time"></i> Layover: <?php print $result->layover_duration; ?></small></p>
													</li>
												</ul>
											</li>
											<li>
												<ul>
													<li class="time"><h2><?php print date("g:i a", strtotime($result->destination_transfer_arrival_time)); ?></h2></li>
													<li class="location"><h6>Depart from <?php print $result->to_stop_name; ?></h6></li>
													<li class="cost"><h6><?php print '$' . $result->second_leg_price; ?></h6></li>
													<li class="transporter">
														<a href="<?php print $result->destination_agency_url; ?>"><?php print stripslashes($result->destination_agency_name); ?> <i class="icon-external-link"></i></a>
														<p><?php print $result->destination_agency_phone; ?>
													</li>
												</ul>
											</li>
										<?php } ?>
										<li>
											<ul>
												<li class="time"><h2>
														<?php print date("g:i a", strtotime($result->destination_arrival_time)); ?>
													</h2></li>
												<li class="location"><h6>
														Arrive at
														<?php print $to; ?>
													</h6>
													<p>
														<?php print $toaddr; ?>
												
												</li>
											</ul>
										</li>
									</ul>
									<ul class="trip-breakdown-title arrival">
										<li><h1>
												<span>B</span>
											</h1></li>
										<li>
											<h1>
												<?php print $to; ?>
											</h1>
										</li>
									</ul>
								</td>
							</tr>
							<?php $i++; ?>
							<?php } ?>
						</tbody>
					</table>
				</div>
			</div>
				<?php if (!empty($return_results)) { ?>
			<div class="trip-holder return">
				<div class="trip-title">
					<ul class="trip-text">
						<li><h5>Your Return Trip</h5></li>
						<li><h1>
								<i class="icon-map-marker"></i>
								<?php print $to; ?>
								to
								<?php print $from; ?>
							</h1></li>
					</ul>
					<ul class="trip-date">
						<li><i class="icon-calendar-empty"></i> <?php print $return_date; ?></li>
						<?php if(strtotime('-1 day', $return_timestamp) >= $timestamp){?>
							<li><a class="btn" href="<?php echo "/gtfs_search/$fromcity/$fromprov/$tocity/$toprov/$timestamp/" . strtotime('-1 day', $return_timestamp); ?>">Prev day</a></li>
						<?php } else { ?>
							<li><span class="btn disabled">Prev Day</span></li>
						<?php } ?>
						<li><a class="btn" href="<?php echo "/gtfs_search/$fromcity/$fromprov/$tocity/$toprov/$timestamp/" . strtotime('+1 day', $return_timestamp); ?>">Next day</a></li>
					</ul>
				</div>
				<div class="table-holder">
					<img src="/sites/all/themes/atlantica/img/gesture.png" alt="Swipe Left" class="table-gesture">
					<div class="trip-table return">
						<table>
							<thead>
								<tr>
									<th>Depart</th>
									<th>Arrive</th>
									<th>Duration</th>
									<th>Cost*</th>
									<th class="center">Transfers</th>
									<th>Features</th>
									<th>Type</th>
									<th>Transporter</th>
									<th class="center">Info</th>
								</tr>
							</thead>
							<tbody>
								<?php $i = 1; ?>
								<?php foreach ($return_results as $result) { ?>
								<tr>
									<td><?php print date("g:i a", strtotime($result->departure_departure_time)); ?></td>
									<td><?php print date("g:i a", strtotime($result->destination_arrival_time)); ?></td>
									<td><?php print $result->duration; ?></td>
									<td><?php print $result->price; ?></td>
									<td class="center"><?php print $result->transfer;?></td>
									<td><?php print $result->features;?></td>
									<td><?php print $result->transportation_type; ?></td>
									<td><?php print stripslashes($result->provider); ?></td>
									<td class="center"><a
										data-expander="#trip-return-<?php print $i; ?>-details" href="#"><i
											class="icon-chevron-down"></i></a>
									
									</td>
								</tr>
								<tr id="trip-return-<?php print $i; ?>-details" class="expandable">
								<td colspan="9">
									<ul class="trip-breakdown-title return">
										<li><h1>
												<span>A</span>
											</h1>
										
										<li>
											<h1>
												<?php print $to; ?>
											</h1>
										</li>
									</ul>
									<ul class="trip-breakdown">
										<li>
											<ul>
												<li class="time"><h2>
														<?php print date("g:i a", strtotime($result->departure_arrival_time)); ?>
													</h2></li>
												<li class="location"><h6>
														Depart from
														<?php print $to; ?>
													</h6>
													<p>
														<?php print $toaddr; ?>
												
												</li>
												<li class="cost"><h6>
														<?php print $result->price; ?>
													</h6></li>
												<li class="transporter"><a target="_blank"
													href="<?php print $result->departure_agency_url; ?>"><?php print stripslashes($result->departure_agency_name); ?>
														<i class="icon-external-link"></i> </a>
													<p>
														<?php print $result->agency_phone; ?>
												
												</li>
											</ul>
										</li>
										<?php if($result->num_transfers){?>
											<li class="transfer">
												<h4><i class="icon-random"></i> Transfer</h4>
												<ul>
													<li class="time"><h2><?php print date("g:i a", strtotime($result->departure_transfer_departure_time)); ?></h2></li>
													<li class="location">
														<h6>Arrive at <?php print $result->from_stop_name; ?></h6>
													</li>
													<li class="transporter">
														<p><small><i class="icon-time"></i> Layover: <?php print $result->layover_duration; ?></small></p>
													</li>
												</ul>
											</li>
											<li>
												<ul>
													<li class="time"><h2><?php print date("g:i a", strtotime($result->destination_transfer_arrival_time)); ?></h2></li>
													<li class="location"><h6>Depart from <?php print $result->to_stop_name; ?></h6></li>
													<li class="cost"><h6><?php print '$' . $result->second_leg_price; ?></h6></li>
													<li class="transporter">
														<a href="<?php print $result->destination_agency_url; ?>"><?php print stripslashes($result->destination_agency_name); ?> <i class="icon-external-link"></i></a>
														<p><?php print $result->destination_agency_phone; ?>
													</li>
												</ul>
											</li>
										<?php } ?>
										<li>
											<ul>
												<li class="time"><h2>
														<?php print date("g:i a", strtotime($result->destination_arrival_time)); ?>
													</h2></li>
												<li class="location"><h6>
														Arrive at
														<?php print $from; ?>
													</h6>
													<p>
														<?php print $fromaddr; ?>
												
												</li>
											</ul>
										</li>
									</ul>
									<ul class="trip-breakdown-title arrival">
										<li><h1>
												<span>B</span>
											</h1></li>
										<li>
											<h1>
												<?php print $from; ?>
											</h1>
										</li>
									</ul>
								</td>
							</tr>
								<?php $i++; ?>
								<?php } ?>
							</tbody>
						</table>
					</div>
				</div>
			</div>
			<?php } ?>
