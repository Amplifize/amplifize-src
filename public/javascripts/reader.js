var enableOverlay = function() {
	$("#overlay").css("visibility", "visible");
};

var disableOverlay = function() {
	$("#overlay").css("visibility", "hidden");
};

var loadReaderSourceOverlay = function() {
	$("#readerSource-overlay").removeClass("hide");
	
	return false;
};

var closeReaderSourceOverlay = function() {
	$("#readerSource-overlay").addClass("hide");
	
	return false;
};

var loadSource = function(contentType, contentId) {
	if("feed" == contentType) {
		$("#readerSourceForm-feed_id").val(contentId);
		$("#readerSourceForm").submit();
	}	
};

$(document).ready(function() {
	$("#contentSummary").on("click", "a", function(evt) {
		if($(this).attr("href").indexOf("http") != -1) {
			evt.preventDefault();
			window.open($(this).attr("href"));
		}
	});
	
	$(".htmlEditor").markItUp(markItUpSettings);
	
	$("#sourceList").quickPagination({pagerLocation:"bottom", pageSize: 13})
});