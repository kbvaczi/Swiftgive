function cyclePageBackgroundImage (){
	var numberOfBackgrounds = 4;
	var target = $('.page-background-image').first();
	var currentBackgroundNumber = parseInt(target.data('background-number')) || 1;
	
    if (currentBackgroundNumber >= numberOfBackgrounds) {
    	var nextBackgroundNumber = 1;
    } else {
    	var nextBackgroundNumber = (currentBackgroundNumber + 1);
	}

	// load the next image early so that it has time to download before transition
	target.before("<div class='page-background-image background-image-" + nextBackgroundNumber + " hidden' data-background-number='" + nextBackgroundNumber + "'></div>");							
		
	// wait to cycle images
	window.setTimeout ( function() {
		target.prev().removeClass("hidden");
		target.fadeOut(4000, function() { 			
			$(this).remove();
			cyclePageBackgroundImage();
		});	    
    }, 10000 );
}

