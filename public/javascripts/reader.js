var enableOverlay = function() {
	$("#overlay").css("visibility", "visible");
};

var disableOverlay = function() {
	$("#overlay").css("visibility", "hidden");
};

$(document).ready(function() {
	$("#contentSummary").on("click", "a", function(evt) {
		if($(this).attr("href").indexOf("http") != -1) {
			evt.preventDefault();
			window.open($(this).attr("href"));
		}
	});

	var top = $('#menuOptions').offset().top - parseFloat($('#menuOptions').css('marginTop').replace(/auto/, 0));

	$(window).scroll(function (event) {
    	// what the y position of the scroll is
    	var y = $(this).scrollTop();
  
    	// whether that's below the form
    	if (y >= top) {
      		// if so, ad the fixed class
      		$('#menuOptions').addClass('fixed');
    	} else {
      		// otherwise remove it
      		$('#menuOptions').removeClass('fixed');
    	}
  	});

});