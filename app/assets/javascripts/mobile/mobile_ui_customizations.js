//remove previous page when page is changed
$(document).delegate("div[data-role=page]", "pagehide", function(event){
  $(event.target).remove();
});

//Show loading spinner when clicking non-xhr links
$(document).delegate("a[rel='external']", 'click', function () {  
  $.mobile.loading('show');
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