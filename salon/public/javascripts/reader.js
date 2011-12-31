$(document).ready(function(){
	$(".trigger").click(function(){
		$(".panel").toggle("fast");
		$(this).toggleClass("active");
		return false;
	});

	$("#previous_button").bind("ajax:success", function(xhr, data, status) {
		updatePostContent(data.post);
		
		var nextButton = $("#next_button");
		var previousButton = $("#previous_button");

		var postCount = previousButton.attr("href").substring(17);
		//reduce the button values
		//if(previousButton.attr("href")) {
			var newPreviousString = "/users/next_post/" + (parseInt(postCount) - 1);
			previousButton.attr("href", newPreviousString);
		//} else {
		//}

		var newNextString = "/users/next_post/" + (parseInt(postCount) + 1);
		nextButton.attr("href", newNextString);
		
	});
	
	$("#next_button").bind("ajax:success", function(xhr, data, status) {
		updatePostContent(data.post);
		
		var nextButton = $("#next_button");
		var previousButton = $("#previous_button");

		var postCount = nextButton.attr("href").substring(17);
		//increase the button values
		//if(previousButton.attr("href")) {
			var newPreviousString = "/users/next_post/" + (parseInt(postCount) - 1);
			previousButton.attr("href", newPreviousString);
		//} else {
		//}

		var newNextString = "/users/next_post/" + (parseInt(postCount) + 1);
		nextButton.attr("href", newNextString);
	});

	$("#next_button").bind("ajax:error", function(xhr, data, status) {
		//log an error
	});

	var updatePostContent = function(post) {		
		$("#contentTitle").html('<a href="'+post.url+'">'+post.title+'</a></p>');
		$("#contentPublishDate").html(post.published_at);
		$("#contentSummary").html(post.content);
	}
});
