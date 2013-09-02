$(document).ready(function() {

  $('.currency_input').initAutoNumeric();
  
});

$.fn.initAutoNumeric = function(method){
  $(this).autoNumeric('init', {
    aSign: '', 
    vMin: '0.00', 
    vMax: '1000.00',
    mDec: '0',
    wEmpty: 'empty'	
  });
}