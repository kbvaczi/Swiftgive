$(document).ready(function() {

	$('a.popup').on("click",function(e){    
		window.open($(this).attr('href'), "yyyyy", "width=900,height=600,resizable=yes,toolbar=no,menubar=no,location=no,status=no,left=200,top=200");
		return false;
	});

	$('a.popup-small').on("click",function(e){    
		window.open($(this).attr('href'), "yyyyy", "width=700,height=600,resizable=yes,toolbar=no,menubar=no,location=no,status=no,left=200,top=200");
		return false;
	});
  
});
