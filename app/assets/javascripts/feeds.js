var current_post = undefined;
var posts = undefined;
var position = 0;
var posts_unread = 0;

var loadFlyOut = function () {
	$("#sharePostFlyout").css("visibility", "visible").css("display", "block");
	$("#shareContentOption").css("background-color", "#4ac36c");
	$("#footer").css("margin-bottom", "240px");

	setTimeout(function(){$("#summary").focus();}, 250);

	return false;
};

var hideFlyOut = function () {
	$("#sharePostFlyout").css("visibility", "hidden").css("display", "none");
	$("#shareContentOption").css("background-color", "inherit");
	$("#footer").css("margin-bottom", "45px");
	
	return false;
};

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
	
	return false;
};

var clearFilter = function() {
	currentFilter = "all";
	$("#currentTag").html("all tags");
	$("#popup_currentTag").html("all tags");
	updatePostsArray();
	$("#filterContent-modal-content").modal("hide");
	
	return false;
};

var loadFilterOverlay = function () {
	$("#filter-overlay").css("visibility", "visible");
};

var closeFilterOverlay = function () {
	$("#filter-overlay").css("visibility", "hidden");
};

var toggleContentOrder = function() {
	contentOrder = $("#toggleContentSelect").val();

	$.cookie("contentOrder", contentOrder);
	updatePostsArray();
};

var toggleContentLayout = function() {
	contentLayout = $("#toggleContentLayout").val();
	
	$.cookie("contentLayout", contentLayout);
	updatePostsArray();
};

var toggleContentSort = function() {
	contentSort = $("#toggleContentSort").val();
	
	$.cookie("contentSort", contentSort);
	updatePostsArray();
};

var markAllAsRead = function() {
	enableOverlay();
	
	$.ajax({
		url: "/feeds/clear-all",
		data: "filter="+currentFilter,
		success: function() {
			disableOverlay();
			clearContent();

			$('#confirm-delete-modal').modal('hide');		
		},
		error: function(xhr, text, error) {
			//TODO: Log this
			disableOverlay();
			$('#confirm-delete-modal').modal('hide');
		}
	});
};

var setReadState = function(readState) {
	if(1 == readState) {
		posts[position]["read_state"] = 1;
		
		if("titleView" == contentLayout) {
			$("li#post_"+current_post.id).removeClass("read").addClass("unread");
		}
		
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
		if("titleView" == contentLayout) {
			openPost(posts[position]["post_id"]);
		} else {
			updatePostContent(posts[position]);
		}
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
		if("titleView" == contentLayout) {
			openPost(posts[position]["post_id"]);
		} else {
			updatePostContent(posts[position]);
		}
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
	$(".postViewOnly").css("visibility", "hidden");
	$("#contentSourceSite").css("visibility", "visible").css("display", "block");
	$("#contentMetadata").css("visibility", "hidden").css("display", "none");

	current_post = undefined;
	
	$("#feedUnreadCount").html(posts.length);
	document.title = "Amplifize | Great conversation goes best with great content ("+posts.length+")";

	$("#contentBody").html("");
	$("#contentBody").append('<ul id="titleList"></ul>');
	for(var i = 0; i < posts.length; i++) {
		var readStateClass = posts[i]["read_state"] == 0 ? "read" : "unread";
		
		$("#titleList").append(
			'<li id="post_'+posts[i]["post_id"]+'" class="'+readStateClass+'"> ' +
			'<a href="#" onclick="openPost('+posts[i]["post_id"]+');return false;">'+posts[i]["post_title"]+'</a>'+
			'<span>From '+posts[i]["feed_title"]+' published on '+dateFormat(posts[i]["published_at"], "dddd, mmmm dS, yyyy, h:MM:ss TT", false)+'</span></li>'
		);
	}
	
	disableOverlay();
};

var openPost = function(postId) {
	$.ajax({
		url: "/posts/"+postId,
		success: function(data, textStatus, jqXHR) {
			//Empty out the comment box when new content is loaded
			$('#summary').val('');

			current_post = data;
			
			for(var i = 0; i < posts.length; i++) {
				if(postId == posts[i]["post_id"]) {
					position = i;
					break;
				}
			}

			if(1 == posts[position]["read_state"]) {
				posts[position]["read_state"] = 0;
				setReadState(0);

				$("li#post_"+postId).removeClass("unread").addClass("read");

				$("#feedUnreadCount").html(--posts_unread);
				document.title = "Amplifize | Great conversation goes best with great content ("+posts_unread+")"
			}

			$("#popup_feedTitle").html('<a href="'+current_post.feed.site_url+'" target="_blank">'+current_post.feed.title+'</a>');
			$("#popup_contentTitle").html('<p><a href="'+current_post.url+'" target="_blank">'+current_post.title+'</a></p>');
			if(current_post.author) {
				$("#popup_contentAuthor").html("by "+current_post.author+" ");
			} else {
				$("#popup_contentAuthor").html("");
			}

			$("#popup_contentPublishDate").html("Written on "+dateFormat(current_post.published_at, "dddd, mmmm dS, yyyy, h:MM:ss TT", false));
			$("#popup_contentBody").html(current_post.content);
			$("#sharePostId").val(current_post.id);

			disableOverlay();
			$("#postPopup-modal-content").modal('show');
			$("#postPopup-modal-content").animate({scrollTop: 0}, "slow");

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
		
		$(".postViewOnly").css("visibility", "visible");
		$("#contentSourceSite").css("visibility", "visible").css("display", "block");
		$("#contentMetadata").css("visibility", "visible").css("display", "block");

		//empty share comment on new post
		$('#summary').val('');

		$.ajax({
			url: "/posts/"+postId["post_id"],
			success: function(data, textStatus, jqXHR) {				
				$("html, body").animate({ scrollTop: 0 }, "fast");
				$("#contentMetadata").css("visibility", "visible").css("display", "block");
				
				current_post = data;

				if(1 == posts[position]["read_state"]) {
					posts[position]["read_state"] = 0;
					setReadState(0);
					
					$("#feedUnreadCount").html(--posts_unread);
					document.title = "Amplifize | Great conversation goes best with great content ("+posts_unread+")";
				}

				$("#feedTitle").html('<a href="'+current_post.feed.site_url+'" target="_blank">'+current_post.feed.title+'</a>');
				$("#contentTitle").html('<p><a href="'+current_post.url+'" target="_blank">'+current_post.title+'</a></p>');
				if(current_post.author) {
					$("#contentAuthor").html("by "+current_post.author+" ");
				} else {
					$("#contentAuthor").html("");
				}
				$("#contentPublishDate").html("Written on "+dateFormat(current_post.published_at, "dddd, mmmm dS, yyyy, h:MM:ss TT", false));
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
		});
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
	$("#contentMetadata").css("visibility", "hidden").css("display", "none");

	$("#feedUnreadCount").html("0");
	document.title = "Amplifize | Great conversation goes best with great content (0)";

	$("#contentBody").html(
		"<h3>Looks like you've got no more posts to read</h3>" +
		"<p>It might be time to <a href=\"/onboarding/feeds\">find feeds</a> other amplifizers are subscribed to.</p>"
	);
	
	$("#postPopup-modal-content").modal("hide");
};

$(document).ready(function() {
	resetAppState();
	updatePostsArray();

	$("#postPopup-modal-content").bind('show', function() {
		$("#postPopup-modal-content .modal-body").animate({scrollTop: 0});
	});

	$('#addShare-modal-content').bind('show', function () {
	  setTimeout(function(){$("#summary").focus();}, 250);
	});

	$('form#new_feed').bind("ajax:failure", function(data, status, xhr) {
		alert(status);
	});

	$('form#addShareForm').bind("ajax:success", function(data, status, xhr) {
		$("#summary").val('');
		$('#addShare-modal-content').modal('hide');
		hideFlyOut();
	});

	$('form#addShareForm').bind("ajax:failure", function(data, status, xhr) {
		alert(status);
	});

	$('#filterContent-modal-content').bind('show', function () {
	  $('#newFilter').val('');
	  setTimeout(function(){$("#newFilter").focus();}, 250);
	});


	$("#toggleContentSelect").val(contentOrder).selectbox();
	$("#toggleContentLayout").val(contentLayout).selectbox();
	$("#toggleContentSort").val(contentSort).selectbox();
	$("#newFilter").selectbox();
	
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
