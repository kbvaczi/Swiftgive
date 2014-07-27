// # Disables right click on all images
$(document).ready(function(){
  $("img").bind("contextmenu",function(e){
    return false;
  });
});
  