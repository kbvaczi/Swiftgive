
$(document).bind("mobileinit", function(){
	// GLOBAL DEFAULTS
	$.extend(  $.mobile , {
		//ajaxEnabled: false,
    defaultPageTransition: 'flip',
    loadingMessageTextVisible: 'true'
  });


  $('.close_flash_button').click(function(){
		$('.flash_message').popup('close');
	});

});

//remove previous page when page is changed
$(document).on("pagehide", "div[data-role=page]", function(event){
  $(event.target).remove();
});

// HIDDEN SLIDER INPUT
$(document).delegate('.main_page', 'pageshow', function () {	
	$('input.hidden-field.ui-slider-input').siblings().addClass('hidden-field');
});

// Load the spinner if an ajaxStart occurs; stop when it is finished
$(document).on({
  ajaxStart: function() { 
    $.mobile.loading('show');
  },
  ajaxStop: function() {
    $.mobile.loading('hide');
  }    
});