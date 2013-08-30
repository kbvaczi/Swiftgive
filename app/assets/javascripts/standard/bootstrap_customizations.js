$(document).ready(function (){

	// Enable client-side validations for forms inside modals
	$('.modal').on('shown', function () {
		$(this).find("form[data-validate='true']").each(function(index, value) { 
	    	$(this).find('input').enableClientSideValidations();
		});
	});

});