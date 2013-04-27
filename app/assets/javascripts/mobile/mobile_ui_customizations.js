

$(document).bind("mobileinit", function(){
	// GLOBAL DEFAULTS
	$.extend(  $.mobile , {
    defaultPageTransition: 'flip',
    loadingMessageTextVisible: 'true'
  });


  $('.close_flash_button').click(function(){
		$('.flash_message').popup('close');
	});

});


$(document).delegate('.main_page', 'pageshow', function () {

	// HIDDEN SLIDER INPUT
	$('input.hidden-field.ui-slider-input').siblings().addClass('hidden-field');

});