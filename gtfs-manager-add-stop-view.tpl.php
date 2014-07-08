<?php
/**
 * @file template for add stops
 *
 *
 */
?>

<?php
	//Links should be: "Back to trip"
	 print implode(' | ', $variables['links']); 
?>
<h3>Add Stop</h3>
<p>Would you like to choose an existing stop or create a new one?</p>
<p><?php print implode('<br />', $variables['stop_links']); ?><p>