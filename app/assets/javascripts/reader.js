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
}

$(document).ready(function() {
	$("#contentBody").on("click", "a", linksInNewWindow);
	$("#commentThread").on("click", "a", linksInNewWindow);
	$("#popup_contentBody").on("click", "a", linksInNewWindow);
	
	$(".htmlEditor").markItUp(markItUpSettings);
	
	//need to do this to prevent firefox from auto searching on typing
	jQuery(document).bind('keydown', 'j', function(evt) {
		return false;
	});

	jQuery(document).bind('keydown', 'k', function(evt) {
		return false;
	});

	jQuery(document).bind('keydown', 'v', function(evt) {
		return false;
	});

	
	jQuery(document).bind('keyup', 'j', function(evt) {
		 upPost();
		 return false;
	});

	jQuery(document).bind('keyup', 'k', function(evt) {
		downPost();
		return false;
	});

	jQuery(document).bind('keyup', 'v', function(evt) {
		openNewWindow();
		return false;
	});
});
