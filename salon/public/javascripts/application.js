// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {
  $( "#tabs" ).tabs();

  $(".alert").click(function() {
    alert(this.getAttribute("data-confirm"));
    return false;
  });
});

$('a[data-remote=true]').livequery('click', function() {
    $.ajax({ 
      url: this.href, 
      dataType: "script"
    }); 
    return false; 
});
 

$('form[data-remote=true]').livequery('submit', function() {
  return request({ url : this.action, type : this.method, data : $(this).serialize() });
});
