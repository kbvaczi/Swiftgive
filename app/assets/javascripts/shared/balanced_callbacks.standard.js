function balancedAddCardToProfileCallback(response) {
  var tag = (response.status < 300) ? 'pre' : 'code';
  debug(tag, JSON.stringify(response));  
  switch (response.status) {
    case 201:
      //createPaymentCard(response.data.uri); // No Longer handling this via ajax
      //$("#add_payment_card_modal").modal("hide");
      $("input[name='accounts_payment_card[balanced_uri]']").val(response.data.uri);
      $('form#new_accounts_payment_card').submit();
      break;
    case 400:
    case 403: // missing/malformed data - check response.error for details      
        $('.modal.in').spin(false);
        $.each( response.error, function( key, value ) {
          $("input[name='"+key+"']").trigger('element:validate:fail', value).data('valid', false);        
        });
        break;
      case 402: // we couldn't authorize the buyer's credit card - check response.error for details
          $('.modal.in').spin(false);
          $("input[name='card_number']").trigger('element:validate:fail', 'Could not authorize card').data('valid', false);       
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

