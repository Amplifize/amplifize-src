var current_post = undefined;
var position = 0;
var max_position = 0;

var loadManageFeeds = function() {
	$.ajax({
		url: "/feeds/manage",
		success: function (data, textStatus, jqXHR) {
			$("#amplifizeContent").html(data);
			
			$('form#new_tag').bind("ajax:success", function(status, data, xhr) {
				$("#tag_name").val();
				$.modal.close();
		
				var ul = $("#feed_"+data.feed_id+" .manageFeedRowTags");
				for(var i =0; i < data.tags.length; i++) {
					ul.append("<li>"+data.tags[i]+"</li>");
				}
			});

			$('form#new_tag').bind("ajax:failure", function(status, data, xhr) {
				alert(status);
			});
		},
		error: function(xhr, text, error) {
			alert(error);
		},
		dataType: "html"
	});
};

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
		alert("No more posts");
	}


	return false;
};

var addTags = function(feedId) {
	$("#tag_feed_id").val(feedId);
	AddTagsOverlay.init();
};

var deleteTags = function(feedId) {
	$.ajax({
		url: "/feeds/"+feedId+"/tags",
		success: function(data, textStatus, jqXHR) {
			var deleteDiv = $("#feedTagsToDelete");
			deleteDiv.html('');
			for(var i=0; i < data.tags.length; i++) {
				deleteDiv.append('<a href="#" id="delete_popup_tag_'+data.tags[i].tag.id+'" onclick=deleteTagFromFeed('+ data.tags[i].tag.id +'); return false;">'+data.tags[i].tag.name+'</p>');
			}

			DeleteTagsOverlay.init();	
		},
		error: function(xhr, text, error) {
			alert(error);
			alert(text);
		},
		dataType: "json"
	});
};

var deleteTagFromFeed = function(tagId) {
	$.ajax({
		url: "/tags/"+tagId,
		type: "DELETE",
		success: function(data, textStatus, jqXHR) {
			$("#delete_popup_tag_"+tagId).remove();
			$("#tag_"+tagId).remove();
		},
		error: function(xhr, text, error) {
			alert(error);
			alert(text);
		},
		dataType: "json"
	});
}

var closeDeleteTagsOverlay = function() {
	$.modal.close();
}

var updatePostContent = function(postId) {		
	if (postId) {
		$.ajax({
			url: "/posts/"+postId,
			success: function(data, textStatus, jqXHR) {
				$("html, body").animate({ scrollTop: 0 }, "slow");
				
				current_post = data.post;

				setReadState(0);

				$("#feedTitle").html('<a href="'+current_post.feed.url+'" target="_blank">'+current_post.feed.title+'</a>');
				$("#contentTitle").html('<p><a href="'+current_post.url+'" target="_blank">'+current_post.title+'</a></p>');
				if(current_post.author) {
					$("#contentAuthor").html("Written by: "+current_post.author+" on ");
				} else {
					$("#contentAuthor").html("");
				}
				$("#contentPublishDate").html(dateFormat(current_post.published_at, "dddd, mmmm dS, yyyy, h:MM:ss TT"));
				$("#contentSummary").html(current_post.content);
				$("#sharePostId").val(current_post.id);
				$("#amplifizeContent").animate({scrollTop: 0});
			},
			error: function(xhr, text, error) {
				alert(error);
				alert(text);
			},
			dataType: "json"
		})
	} else {
		$("#feedUnreadCount").html(0);
	}
};

$(document).ready(function() {
	$("li#feedsNav.drawer ul").css("display", "block").css("visibility", "visible");

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

		var unread_count = posts.length - 1; 
		$("#feedUnreadCount").html(unread_count);
		document.title = "Amplifize | Give good content a voice ("+unread_count+")";
	}

	updatePostContent(posts[position]);
});
