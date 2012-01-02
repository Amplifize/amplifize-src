// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$.ajaxSettings.dataType = "json";

$(document).ready(function() {
	$(".alert").click(function() {
		alert(this.getAttribute("data-confirm"));
		return false;
	});

	$("ul.subnav").parent().append("<span></span>");
	//Only shows drop down trigger when js is enabled (Adds empty span tag after ul.subnav*)

	$("ul.topnav li span").hover(function() {//When trigger is clicked...

		//Following events are applied to the subnav itself (moving subnav up and down)
		$(this).parent().find("ul.subnav").slideDown('fast').show();
		//Drop down the subnav on click

		$(this).parent().hover(function() {
		}, function() {
			$(this).parent().find("ul.subnav").slideUp('slow');
			//When the mouse hovers out of the subnav, move it back up
		});
		//Following events are applied to the trigger (Hover events for the trigger)
	});

	setTimeout(function() {
		$("#notice").html("")
	}, 5000);
});
