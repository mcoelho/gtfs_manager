(function( $ ) {
	$( document ).ready(function(){
		var spinner = '<div id="spinner"><h2>Loading Search Results</h2><img src="/sites/all/themes/atlantica/img/spinner.gif"></div>';
		$('.left-col').html(spinner);
		
		url = window.location.pathname;
		url = url.replace('gtfs_search', 'gtfs_query');
		
		$.get(url).done(function(data){
			$('.left-col').html(data);
		});
		
		$('body').on('click', '.trip-date li a', function(e){
			e.preventDefault();
			$('.left-col').html(spinner);
			url = $(this).attr('href');
			url = url.replace('gtfs_search', 'gtfs_query');
			$.get(url).done(function(data){
				$('.left-col').html(data);
			});
			
		})
	});
})(jq1110);