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
});