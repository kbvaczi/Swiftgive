function balancedAddCardToProfileCallback(response) {
  var tag = (response.status < 300) ? 'pre' : 'code';
  debug(tag, JSON.stringify(response));
  switch (response.status) {
    case 201:
      //createPaymentCard(response.data.uri); // No Longer handling this via ajax
      $.mobile.activePage.find("#new_payment_card_form").popup("close");
      $.mobile.activePage.find("input[name='accounts_payment_card[balanced_uri]']").val(response.data.uri);
      $.mobile.activePage.find('form#new_accounts_payment_card').submit();
      break;
    case 400:
    case 403: // missing/malformed data - check response.error for details
      $.mobile.activePage.find("#new_payment_card_form").popup("close");
      var error_message = '<h3>Could not validate your card</h3>';
      $.each( response.error, function( key, value ) {
        error_message += ( key + ": " + "is not valid" + "<br/>");
      });
      error_message += "<p>Please try again...</p>";
      window.setTimeout ( function() {                  
        flashNow(error_message, 'error');
      }, 1000 );
      break;               
    case 402: // we couldn't authorize the buyer's credit card - check response.error for details
      $.mobile.activePage.find("#new_payment_card_form").popup("close");
      var error_message = '<h3>Could not validate your card</h3><p>The card entered was declined</p><p>Please try another card...</p>';
      window.setTimeout ( function() {                  
        flashNow(error_message, 'error');
      }, 1000 );
      break;
    case 404: // your marketplace URI is incorrect
      break;
    default: // we did something unexpected - check response.error for details
      break;
  }
}

var createPaymentCard = function( payment_card_uri ) {
  var path = "<%= accounts_payment_cards_path %>";
  var params = [{ name: 'format',            value: 'json' },
                { name: 'skip_mobile',       value: 'true' },
                { name: 'payment_card[uri]', value: payment_card_uri }];
  var url = path + '?' + $.param(params);  
  $.ajax({
    url: url,
    type: "POST",
    dataType: "JSON",
    beforeSend: function ( xhr ) {

    },
    error: function (xhr, ajaxOptions, thrownError) {
      flashNow('Oops! There was an error...');
    },
    success: function(data) {      
      window.setTimeout(function() {                  
        flashNow('Your card was successfully validated', 'notice');
      }, 1000 );
    }
  });
}

