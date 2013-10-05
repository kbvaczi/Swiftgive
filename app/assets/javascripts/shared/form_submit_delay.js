$(document).ready(function(){

	// Forms can only be submitted once every 2 seconds
	$('form:not(.noDelay)').submit(function(e){
		var target = $(this);
		if ( target.data('submit_status') != true ) {
	    	target.data('submit_status', true);
		    window.setTimeout ( function() {                  
		    	target.data('submit_status', false);
		    }, 2000 );
	    } else {
	    	e.preventDefault();
	    	return false;
	    }    	    	
	});

});