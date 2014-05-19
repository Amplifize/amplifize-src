var enableOverlay = function() {
	$("#overlay").css("visibility", "visible");
};

var disableOverlay = function() {
	$("#overlay").css("visibility", "hidden");
};

var linksInNewWindow = function(evt) {
	if($(this).attr("href").indexOf("http") != -1) {
		evt.preventDefault();
		window.open($(this).attr("href"));
	}	
};

$(document).ready(function() {
	$("#contentBody").on("click", "a", linksInNewWindow);
	$("#commentThread").on("click", "a", linksInNewWindow);
	$("#popup_contentBody").on("click", "a", linksInNewWindow);
	$("#popup_commentThread").on("click", "a", linksInNewWindow);

	$(".htmlEditor").markItUp(markItUpSettings);
	
	$('.confirm-delete').on('click', function(e) {
    	e.preventDefault();
    	$('#confirm-delete-modal').modal('show');
	});
	
	$("#footer").css("margin-bottom", "45px");
});
