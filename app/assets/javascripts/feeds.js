var current_post = undefined;
var posts = undefined;
var position = 0;
var posts_unread = 0;

var resetAppState = function () {
	current_post = undefined;
	position = 0;
};

var setNewFilter = function() {
	currentFilter = $("#newFilter").val();
	$("#currentTag").html("the "+currentFilter+" tag");
	$("#popup_currentTag").html("the "+currentFilter+" tag");
	updatePostsArray();
	$("#filterContent-modal-content").modal("hide");
};

var clearFilter = function() {
	currentFilter = "all";
	$("#currentTag").html("all tags");
	$("#popup_currentTag").html("all tags");
	updatePostsArray();
	$("#filterContent-modal-content").modal("hide");
}

var loadFilterOverlay = function () {
	$("#filter-overlay").css("visibility", "visible");
};

var closeFilterOverlay = function () {
	$("#filter-overlay").css("visibility", "hidden");
};

var toggleContentOrder = function() {
	if("newestFirst" == contentOrder) {
		contentOrder = "oldestFirst";
	} else {
		contentOrder = "newestFirst";
	}

	$.cookie("contentOrder", contentOrder);
	updatePostsArray();
};

var toggleContentLayout = function() {
	if("postView" == contentLayout) {
		contentLayout = "titleView";
	} else {
		contentLayout = "postView";
	}
	
	$.cookie("contentLayout", contentLayout);
	updatePostsArray();
};

var toggleContentSort = function() {
	if("unreadOnly" == contentSort) {
		contentSort = "allContent";
	} else {
		contentSort = "unreadOnly";
	}
	
	$.cookie("contentSort", contentSort);
	updatePostsArray();
};

var filterContent = function() {
	$("#filterContent-modal-content").modal("show");
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
	if(1 == readState) {
		posts[position]["read_state"] = 1;
		++posts_unread;
		$("#feedUnreadCount").html(posts_unread);
		document.title = "Amplifize | Great conversation goes best with great content ("+posts_unread+")"
	}

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
	} else {
		clearContent();
	}


	return false;
};

var updatePostsArray = function() {
	resetAppState();
	enableOverlay();
	
	$.ajax({
		url: "/post_users/",
		data: {
			"content_order" : contentOrder,
			"content_sort" : contentSort,
			"content_layout" : contentLayout,
			"filter" : currentFilter
		},
		success: function(data, textStatus, jqXHR) {
			posts = data;
			posts_unread = posts.length;
			document.title = "Amplifize | Great conversation goes best with great content ("+posts_unread+")";

			if(0 == posts_unread) {
				clearContent();
			} else {
				if("postView" == contentLayout) {
					updatePostContent(posts[position]);	
				} else {
					updateTitleContent();
				}
			}
		},
		error: function(xhr, text, error) {
				//log error here
				disableOverlay();
		},
		dataType: "json"
	});
};

var updateTitleContent = function() {
	$("#contentMetadata").css("visibility", "hidden").css("display", "none");
	$("#contentSourceSite").css("visibility", "hidden").css("display", "none");
	$("#contentStateOptions").css("visibility", "hidden");
	$("#contentOptions").css("visibility", "hidden");

	current_post = undefined;

	$("#contentBody").html("");
	$("#contentBody").append('<ul id="titleList"></ul>');
	for(var i = 0; i < posts.length; i++) {
		$("#titleList").append(
			'<li id="post_'+posts[i]["id"]+'"> ' +
			'<a href="#" onclick="openPost('+posts[i]["post_id"]+');return false;">'+posts[i]["post_title"]+'</a>'+
			'<span>From '+posts[i]["feed_title"]+' published on '+dateFormat(posts[i]["published_at"], "dddd, mmmm dS, yyyy, h:MM:ss TT")+'</span></li>'
		);
	}
	
	disableOverlay();
};

var openPost = function(postId) {
	$.ajax({
		url: "/posts/"+postId,
		success: function(data, textStatus, jqXHR) {
			current_post = data;
			setReadState(0);

			$("#feedUnreadCount").html(--posts_unread);
			document.title = "Amplifize | Great conversation goes best with great content ("+posts_unread+")"

			$("#popup_feedTitle").html('<a href="'+current_post.feed.url+'" target="_blank">'+current_post.feed.title+'</a>');
			$("#popup_contentTitle").html('<p><a href="'+current_post.url+'" target="_blank">'+current_post.title+'</a></p>');
			if(current_post.author) {
				$("#popup_contentAuthor").html("by "+current_post.author+" ");
			} else {
				$("#popup_contentAuthor").html("");
			}

			$("#popup_contentPublishDate").html("Written on "+dateFormat(current_post.published_at, "dddd, mmmm dS, yyyy, h:MM:ss TT"));
			$("#popup_contentBody").html(current_post.content);
			$("#sharePostId").val(current_post.id);

			disableOverlay();
			$("#postPopup-modal-content").modal('show');
			mixpanel.track("Read another post");
		},
		error: function(xhr, text, error) {
			//log error here
			disableOverlay();
		},
		dataType: "json"
	});
}

var updatePostContent = function(postId) {
	if (postId["post_id"]) {
		$("#contentBody").html('');
		
		$("#contentMetadata").css("visibility", "visible").css("display", "block");
		$("#contentSourceSite").css("visibility", "visible").css("display", "block");
		$("#contentStateOptions").css("visibility", "visible");
		$("#contentOptions").css("visibility", "visible");

		$.ajax({
			url: "/posts/"+postId["post_id"],
			success: function(data, textStatus, jqXHR) {
				$("html, body").animate({ scrollTop: 0 }, "fast");
				
				current_post = data;

				if(1 == posts[position]["read_state"]) {
					posts[position]["read_state"] = 0;
					setReadState(0);
					
					$("#feedUnreadCount").html(--posts_unread);
					document.title = "Amplifize | Great conversation goes best with great content ("+posts_unread+")"
				}

				$("#feedTitle").html('<a href="'+current_post.feed.url+'" target="_blank">'+current_post.feed.title+'</a>');
				$("#contentTitle").html('<p><a href="'+current_post.url+'" target="_blank">'+current_post.title+'</a></p>');
				if(current_post.author) {
					$("#contentAuthor").html("by "+current_post.author+" ");
				} else {
					$("#contentAuthor").html("");
				}
				$("#contentPublishDate").html("Written on "+dateFormat(current_post.published_at, "dddd, mmmm dS, yyyy, h:MM:ss TT"));
				$("#contentBody").html(current_post.content);
				$("#sharePostId").val(current_post.id);

				disableOverlay();
				mixpanel.track("Read another post");
			},
			error: function(xhr, text, error) {
				//log error here
				disableOverlay();
			},
			dataType: "json"
		})
	} else {
		clearContent();
	}
};

var clearContent = function() {
	disableOverlay();
	
	$("#feedTitle").html('');
	$("#contentRow").html('');
	$("#contentSummary").html('');
	$("#content").animate({scrollTop: 0});

	$("#feedUnreadCount").html("0");
	document.title = "Amplifize | Great conversation goes best with great content (0)";

	$("#contentBody").html(
		"<h3>Looks like you've got no more posts to read</h3>" +
		"<p>It might be time to add a <a href=\"#addFeed-modal-content\" data-toggle=\"modal\">new feed</a> or <a href=\"/feeds/import\">import your feeds</a> from Google Reader</p>"
	);
};

$(document).ready(function() {
	resetAppState();
	updatePostsArray();

	$('form#new_feed').bind("ajax:success", function(data, status, xhr) {
		$('#feed_url').val('');
		$('#feed_tags').val('');

		$('#addFeed-modal-content').modal('hide');
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

	$('#filterContent-modal-content').bind('show', function () {
	  $('#newFilter').val('');
	  setTimeout(function(){$("#newFilter").focus();}, 250);
	});

	$('#addShare-modal-content').bind('show', function () {
	  $('#summary').val('');
	  setTimeout(function(){$("#summary").focus();}, 250);
	});

	$("#toggleContentSelect").val(contentOrder);
	$("#toggleContentLayout").val(contentLayout);
	$("#toggleContentSort").val(contentSort);
});
