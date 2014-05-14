(function( $ ) {
	$( document ).ready(function(){
<<<<<<< HEAD
		//get search terms and convert cities to validation format
		var search = window.location.pathname.replace("/gtfs_search/", "").split("/");
		var depart = search[0] + ' (' + search[1] + ')';
		var dest = search[2] + ' (' + search[3] + ')';
		
		//Show a spinner to let the user know something is happening
		var spinner = '<div id="spinner"><h2>Loading Search Results</h2><img src="/sites/all/themes/atlantica/img/spinner.gif"></div>';
		$('.left-col').html(spinner);
		
		//validate both stop names before completing search, just in case the user ended up here from an invalid link
		$.when($.get('/stopname/validate/' + depart), $.get('/stopname/validate/' + dest)).done(function(o, d){
			if(o[0] != true || d[0] != true){ //if origin or destination are not valid
				$('.left-col').html('<div class="messages errors"><ul></ul></div>'); //set up left column for error messages
				if(o[0] == false){ //no suggestions
					$('.errors ul').append('<li><i class="icon-exclaimation-sign"></i> We couldn\'t find the departure city you searched for.</li>');
				}else if(o[0] != false && o[0] != true){
					$('.errors ul').append('<li><i class="icon-exclaimation-sign"></i> We couldn\'t find the departure city you searched for. Did you mean <span class="departure result-suggestion">' + d[0] + '</span>?</li>');
				}
				if(d[0] == false){ //no suggestions
					$('.errors ul').append('<li><i class="icon-exclaimation-sign"></i> We couldn\'t find the destination city you searched for.</li>');
				}else if(d[0] != false && d[0] != true){
					$('.errors ul').append('<li><i class="icon-exclaimation-sign"></i> We couldn\'t find the destination city you searched for. Did you mean <span class="destination result-suggestion">' + d[0] + '</span>?</li>');
				}	
			}else{
				loadResults();
			}
		}).fail(function(data){ //if the validation could not be completed
			$('.left-col').html('<p>Your search could not be completed. Please try again.</p>');
		});
		
		//fetch the results using ajax
		function loadResults(){
			url = window.location.pathname;
			url = url.replace('gtfs_search', 'gtfs_query');
			
			$.get(url).done(function(data){
				$('.left-col').html(data);
			}).fail(function(data){
				console.log(data);
				console.log("fail");
				$('.left-col').html('<p>Your search could not be completed. Please try again.</p>');
			});
		}
		
		//when a user clicks the "next day" or "prev day" buttons
		$(document).on('click', '.trip-date li a', function(e){
			e.preventDefault(); //stop page load
			$('.left-col').html(spinner); //show spinner
			url = $(this).attr('href'); //get the new url from the button
			url = url.replace('gtfs_search', 'gtfs_query'); //change search to query
			$.get(url).done(function(data){ //get the data and display on page
				$('.left-col').html(data);
			}).fail(function(data){ //if data could not be retrieved.
				$('.left-col').html('<p>Your search could not be completed. Please try again.</p>');
			});
			
		});
		
		//on suggestion clicked
		$(document).on('click', '.result-suggestion', function(event){
			urlArray = window.location.pathname.replace("/gtfs_search/", "").split("/");
			pattern = /^(.+) \((\w{2})\)$/;
			suggestion = $(event.target).text();
			suggestion = pattern.exec(suggestion); //returns array where [0] is city, [1] is province
			if($(event.target).hasClass('departure')){
				urlArray[0] = suggestion[1];
				urlArray[1] = suggestion[2];
			}else if($(event.target).hasClass('destination')){
				urlArray[2] = suggestion[1];
				urlArray[3] = suggestion[2];
			}
			newUrl = '/gtfs_search/' + urlArray.join('/');
			location.href = newUrl;
		});
=======
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
>>>>>>> e0fba5c24269722bb29dafd2c52af0193f74fb56
	});
})(jq1110);