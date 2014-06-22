$(document).ready(function(){
	cyclePageBackgroundImage();
});

function cyclePageBackgroundImage (){
	var numberOfBackgrounds = 3;
	var target = $('.page-background-image');
	var currentBackgroundNumber = parseInt(target.data('background-number')) || 1;	
    if (currentBackgroundNumber >= numberOfBackgrounds) {
    	var nextBackgroundNumber = 1;
    } else {
    	var nextBackgroundNumber = (currentBackgroundNumber + 1);
	}
	//preload next background early so it is downloaded in time before visible	   
	target.before("<div class='page-background-image background-image-" + nextBackgroundNumber + "' data-background-number='" + nextBackgroundNumber + "'></div>");
	window.setTimeout ( function() {
		target.fadeOut(2000, function() { $(this).remove(); });	
		cyclePageBackgroundImage();
	}, 10000 );		    
}

