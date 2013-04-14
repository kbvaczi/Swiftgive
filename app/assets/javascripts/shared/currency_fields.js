$(document).ready(function() {

  $('.currency_input').initAutoNumeric();
  
});

$.fn.initAutoNumeric = function(method){
  $(this).autoNumeric('init', {
    aSign: 'Give $', 
    vMin: '0', 
    vMax: '1000',
    mDec: '0',
    wEmpty: 'empty'	
  });
}