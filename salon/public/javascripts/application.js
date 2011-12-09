// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {
  $( "#feeds" ).tabs();

  $(".alert").click(function() {
    alert(this.getAttribute("data-confirm"));
    return false;
  });

  $('form#new_feed').live("ajax:success", function(data, status, xhr) {
    $("#feed_url").val();
    
    $("#feedTable tr:last").after("<tr><td>"+ data.feed.url +"</td><td>Delete</td></tr>")  
  });
  
  $('form#new_feed').live("ajax:failure", function(data, status, xhr) {
  	alert(status);
  });
  
  $("#notice").live("onload", function() { this.slideup(300).delay(5000) });
});
