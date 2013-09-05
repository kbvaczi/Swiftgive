$(document).ready(function() {

  $('.currency_input').initAutoNumeric();
  
});

$.fn.initAutoNumeric = function(method){
	if ($(this).hasClass('no_sign')){
		$(this).autoNumeric('init', {
		    aSign: '', 
		    vMin: '0.00', 
		    vMax: '1000.00',
		    mDec: '0',
		    wEmpty: 'empty'	
		});		
	} else {
		$(this).autoNumeric('init', {
		    aSign: '$ ', 
		    vMin: '0.00', 
		    vMax: '1000.00',
		    mDec: '0',
		    wEmpty: 'empty'	
		});		
	}
  
}