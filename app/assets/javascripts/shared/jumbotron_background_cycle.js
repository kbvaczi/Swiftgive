$(document).ready(function(){
	cyclePageBackgroundImage();
});

function cyclePageBackgroundImage (){
	var numberOfBackgrounds = 3;
	var target = $('.page-background-image');
	var currentBackgroundNumber = parseInt(target.data('background-number')) || 1;
	window.setTimeout ( function() {
	    if (currentBackgroundNumber >= numberOfBackgrounds) {
	    	var nextBackgroundNumber = 1;
	    } else {
	    	var nextBackgroundNumber = (currentBackgroundNumber + 1);
		}		
		target.before("<div class='page-background-image background-image-" + nextBackgroundNumber + "' data-background-number='" + nextBackgroundNumber + "'></div>");							
		target.fadeOut(3000, function() { $(this).remove(); });
	    cyclePageBackgroundImage();
    }, 10000 );   
}

