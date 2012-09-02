var current_post = undefined;
var position = 0;
var max_position = 0;

var markAllAsRead = function() {
	enableOverlay();
	
	for(var i = 0; i < posts.length; i++) {
		$.ajax({
			url: "/post_users/"+posts[i]+"/read_state/0"
		});
	}

	disableOverlay();
	clearContent();
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
	
var upPost = function() {
	if((position+1) < posts.length) {
		position++;
		updatePostContent(posts[position]);

		if(position > max_position) {
			max_position = position;
			var unread_count = posts.length - 1 - max_position;
			$("#feedUnreadCount").html(unread_count);
			document.title = "Amplifize | Give good content a voice ("+unread_count+")"
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
				alert(error);
				alert(text);
			},
			dataType: "json"
		})
	} else {
		$("#feedUnreadCount").html(0);
		clearContent();
	}
};

var getFeedsByTag = function(tagName) {
	if("all" == tagName) {
		window.location.reload();		
	}

	$.ajax({
		url: "/reader/tag/"+tagName,
		success: function(data, textStatus, jqXHR) {
			posts = data;
			position = 0;

			var unread_count = posts.length - 1; 
			$("#feedUnreadCount").html(unread_count);
			document.title = "Amplifize | Give good content a voice ("+unread_count+")";

			updatePostContent(posts[position]);
		},
		error: function(xhr, text, error) {
			alert(error);
			alert(text);
		},
		dataType: "json"
	});
};

var clearContent = function() {
	$("#feedTitle").html('');
	$("#contentTitle").html('');
	$("#contentAuthor").html("");
	$("#contentPublishDate").html('');
	$("#contentSummary").html('');
	$("#amplifizeContent").animate({scrollTop: 0});

	$("#contentSummary").html(
		"<h3>Looks like you've got no more posts to read</h3>" +
		"<p>It might be time to</p>" +
		"<ul>" +
		"<li>Add a <a href=\"#addFeed-modal-content\" data-toggle=\"modal\">new feed</a></li>" +
		"<li>OR <a href=\"/feeds/import\">import your feeds</a> from Google Reader</li>" +
		"</ul>"
	);
};


$(document).ready(function() {
	if(posts.length > 0) {
		//need to do this to prevent firefox from auto searching on typing
		jQuery(document).bind('keydown', 'j', function(evt) {
			return false;
		});

		jQuery(document).bind('keydown', 'k', function(evt) {
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

		$("#selectTag select").change(function () {
			$("#selectTag select option:selected").each(function () {
				getFeedsByTag($(this).val());
			});
       	});

		var unread_count = posts.length - 1; 
		$("#feedUnreadCount").html(unread_count);
		document.title = "Amplifize | Give good content a voice ("+unread_count+")";
	}

	updatePostContent(posts[position]);

	$('form#new_feed').bind("ajax:success", function(data, status, xhr) {
		$('#addFeed-modal-content').modal('hide');
		mixpanel.track("Add a new feed");
	});

	$('form#new_feed').bind("ajax:failure", function(data, status, xhr) {
		alert(status);
	});

	$('form#addShareForm').bind("ajax:success", function(data, status, xhr) {
		$("#summary").val();
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

	//$('form#importForm').bind("ajax:success", function(data, status, xhr) {
	//	$('#importFeed-modal-content').modal('hide')
	//});

	//$('form#importForm').bind("ajax:failure", function(data, status, xhr) {
	//	alert(status);
	//});
});
