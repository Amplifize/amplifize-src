var current_share = undefined;
var position = 0;
var max_position = 0;

var setReadState = function(readState) {
	$.ajax({
		url: "/share_users/"+current_share.id+"/read_state/"+readState,
		success: function() {
			//log this
		},
		error: function(xhr, text, error) {
			//log this
		}
	});
	
	return false;
}

var downPost = function() {
	if(position > 0) {
		position--;
		updateShareContent(shares[position]);
	} else {
		alert("At the first share");
	}
	
	return false;
};
	
var upPost = function() {
	if((position+1) < shares.length) {
		position++;
		updateShareContent(shares[position]);
		
		if(position > max_position) {
			max_position = position;
			var unread_count = shares.length - 1 - max_position;
			$("#shareUnreadCount").html(unread_count);
			document.title = "Amplifize | Give good content a voice ("+unread_count+")";
		}
	} else {
		alert("No more shares");
	}
	
	return false;
};

var getSharesByFollows = function(followsId) {
	if("all" == followsId) {
		window.location.reload();		
	}

	$.ajax({
		url: "/shares/follows/"+followsId,
		success: function(data, textStatus, jqXHR) {
			shares = data;
			position = 0;

			var unread_count = shares.length - 1; 
			$("#shareUnreadCount").html(unread_count);
			document.title = "Amplifize | Give good content a voice ("+unread_count+")";

			updateShareContent(shares[position]);
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
		"<h3>Looks like you've got no shares to read</h3><p>"
	);
};

var updateShareContent = function(shareId) {		
	if(shareId) {
		$.ajax({
			url: "/shares/"+shareId,
			success: function(data, textStatus, jqXHR) {
				$("html, body").animate({ scrollTop: 0 }, "fast");
				var current_post = data.share.post;
				current_share = data.share;

				setReadState(0);

				$("#comment_share_id").val(current_share.id);
				
				if (typeof(current_post.feed) != "undefined") {
					$("#feedTitle").html('<a href="'+current_post.feed.url+'" target="_blank">'+current_post.feed.title+'</a>');
				} else {
					$("#feedTitle").html('');
				}
				$("#contentTitle").html('<p><a href="'+current_post.url+'" target="_blank">'+current_post.title+'</a></p>');
				$("#contentPublishDate").html(" on "+dateFormat(current_post.published_at, "dddd, mmmm dS, yyyy, h:MM:ss TT"));
				$("#conversationStarter").html(current_share.summary);
				if(current_post.author) {
					$("#contentAuthor").html("written by "+current_post.author+" ");
				} else {
					$("#contentAuthor").html("");
				}
				$("#contentSummary").html(current_post.content);
				$("#commentThread").html("");
				
				$("#sharedBy").html(current_share.user.email);
	
				for(var i = 0; i < data.share.comments.length; i++) {
					var comment = data.share.comments[i];
					var username = null == comment.user.display_name ? comment.user.email : comment.user.display_name;
					var html = '<div class="commentInstanceDiv"><p class="commentText">'+comment.comment_text+'</p><p class="commentAuthor">'+username+'</p></div>';
					$("#commentThread").append(html);
				}
			},
			error: function(xhr, text, error) {
				alert(error);
				alert(text);
			}
		})
	} else {
		$("#shareUnreadCount").html(0);
		clearContent();
	}
};

$(document).ready(function() {
	if(shares.length > 0) {
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

		$("#selectFollows select").change(function () {
			$("#selectFollows select option:selected").each(function () {
				getSharesByFollows($(this).val());
			});
       	});

		var unread_count = shares.length - 1; 
		$("#shareUnreadCount").html(unread_count);
		document.title = "Amplifize | Give good content a voice ("+unread_count+")";
	}

	$("#container").css("margin-top", "32px");

	updateShareContent(shares[position]);

	$('#addComment-modal-content').bind('show', function () {
	  $('#comment_comment_text').val('');
	  setTimeout(function(){$("#comment_comment_text").focus();}, 250);
	});

	$('form#new_comment').bind("ajax:success", function(status, data, xhr) {
		$("#addComment-modal-content").modal("hide");
		$("#comment_text").val('');

		var comment = data.comment;
		var username = null == comment.user.display_name ? comment.user.email : comment.user.display_name;
		var html = '<div class="commentInstanceDiv"><p class="commentText">'+comment.comment_text+'</p><p class="commentAuthor">'+username+'</p></div>';
		$("#commentThread").append(html);
		
		mixpanel.track("Comment in a conversation");
	});

	$('form#new_comment').bind("ajax:failure", function(data, status, xhr) {
		alert(status);
	});

});
