// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {
  $( "#feeds" ).tabs();

  $(".alert").click(function() {
    alert(this.getAttribute("data-confirm"));
    return false;
  });

  // $('form#new_feed').bind("ajax:success", function(data, status, xhr) {
    // alert("it worked");
  // });
//   
  // $('form#new_feed').bind("ajax:failure", function(data, status, xhr) {
  	// alert(status);
  // });
  
  //$("#notice").slideUp(2500);
});
