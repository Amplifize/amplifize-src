var current_post = undefined;
var position = 0;
var max_position = 0;

var loadFilterOverlay = function () {
	$("#filter-overlay").css("visibility", "visible");
};

var closeFilterOverlay = function () {
	$("#filter-overlay").css("visibility", "hidden");
};

var markAllAsRead = function() {
	enableOverlay();
	
	$.ajax({
		url: "/feeds/clear-all",
		success: function() {
			disableOverlay();
			clearContent();			
		},
		error: function(xhr, text, error) {
			//log this
			disableOverlay();
		}
	});

}

var setReadState = function(readState) {
	$.ajax({
		url: "/post_users/"+current_post.id+"/read_state/"+readState,
		success: function() {
			//log this
		},
		error: function(xhr, text, error) {
			//log this
		},
		dataType: "json"
	});
	
	return false;
};
	
var downPost = function() {
	if(position > 0) {
		position--;
		updatePostContent(posts[position]);
	} else {
		alert("At the first post");
	}
	
	return false;
};

var openNewWindow = function() {
	if(current_post) {
		window.open(current_post.url);
	}
};
	
var upPost = function() {
	if((position+1) < posts.length) {
		position++;
		updatePostContent(posts[position]);

		if(position > max_position) {
			max_position = position;
			var unread_count = posts.length - 1 - max_position;
			$("#feedUnreadCount").html(unread_count);
			document.title = "Amplifize | Great conversation goes best with great content ("+unread_count+")"
		}
	} else {
		clearContent();
	}


	return false;
};

var updatePostContent = function(postId) {		
	if (postId) {
		$.ajax({
			url: "/posts/"+postId,
			success: function(data, textStatus, jqXHR) {
				$("html, body").animate({ scrollTop: 0 }, "fast");
				
				current_post = data.post;

				setReadState(0);

				$("#feedTitle").html('<a href="'+current_post.feed.url+'" target="_blank">'+current_post.feed.title+'</a>');
				$("#contentTitle").html('<p><a href="'+current_post.url+'" target="_blank">'+current_post.title+'</a></p>');
				if(current_post.author) {
					$("#contentAuthor").html("written by "+current_post.author+" ");
				} else {
					$("#contentAuthor").html("");
				}
				$("#contentPublishDate").html("on "+dateFormat(current_post.published_at, "dddd, mmmm dS, yyyy, h:MM:ss TT"));
				$("#contentSummary").html(current_post.content);
				$("#sharePostId").val(current_post.id);
				
				mixpanel.track("Read another post");
			},
			error: function(xhr, text, error) {
				//log error here
			},
			dataType: "json"
		})
	} else {
		clearContent();
	}
};

var clearContent = function() {
	$("#feedTitle").html('');
	$("#contentRow").html('');
	$("#contentSummary").html('');
	$("#amplifizeContent").animate({scrollTop: 0});

	$("#feedUnreadCount").html("0");
	document.title = "Amplifize | Great conversation goes best with great content (0)";

	$("#contentSummary").html(
		"<h3>Looks like you've got no more posts to read</h3>" +
		"<p>It might be time to add a <a href=\"#addFeed-modal-content\" data-toggle=\"modal\">new feed</a> or <a href=\"/feeds/import\">import your feeds</a> from Google Reader</p>"
	);
};

$(document).ready(function() {
	if(posts.length > 0) {
		var unread_count = posts.length - 1; 
		$("#feedUnreadCount").html(unread_count);
		document.title = "Amplifize | Great conversation goes best with great content ("+unread_count+")";
	}

	$("#container").css("margin-top", "108px");

	$("#filterViewTab a").click(function (e) {
  		e.preventDefault();
  		$(this).tab('show');
	});

	updatePostContent(posts[position]);

	$('form#new_feed').bind("ajax:success", function(data, status, xhr) {
		$('#feed_url').val('');
		$('#feed_tags').val('');

		$('#addFeed-modal-content').modal('hide');
		mixpanel.track("Add a new feed");
	});

	$('form#new_feed').bind("ajax:failure", function(data, status, xhr) {
		alert(status);
	});

	$('form#addShareForm').bind("ajax:success", function(data, status, xhr) {
		$("#summary").val('');
		$('#addShare-modal-content').modal('hide');
		mixpanel.track("Share a post");
	});

	$('form#addShareForm').bind("ajax:failure", function(data, status, xhr) {
		alert(status);
	});

	$('#addShare-modal-content').bind('show', function () {
	  $('#summary').val('');
	  setTimeout(function(){$("#summary").focus();}, 250);
	});
});
