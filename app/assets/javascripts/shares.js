var current_share = undefined;
var position = 0;

var setReadState = function(readState) {
	if(1 == readState) {
		shares[position][1] = 1;
		++shares_unread;
		$("#shareUnreadCount").html(shares_unread);
		document.title = "Amplifize | Great conversation goes best with great content ("+shares_unread+")"
	}


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
	} else {
		alert("No more shares");
	}
	
	return false;
};

var openNewWindow = function() {
	if(current_share) {
		window.open(current_share.url);
	}
};

var followUser = function(userId) {
	$.ajax({
		url: '/follows/add/'+userId,
		success: function(data, textStatus, jqXHR) {
			$('.followUser_'+userId).html('Followed!');
		},
		error: function(xhr, text, error) {
			alert(error);
			alert(text);
		}
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
	if(shareId[0]) {
		enableOverlay();
		$.ajax({
			url: "/shares/"+shareId[0],
			success: function(data, textStatus, jqXHR) {
				$("html, body").animate({ scrollTop: 0 }, "fast");
				var current_post = data.share.post;
				current_share = data.share;

				if(1 == shares[position][1]) {
					shares[position][1] = 0;
					setReadState(0);
					
					$("#shareUnreadCount").html(--shares_unread);
					document.title = "Amplifize | Great conversation goes best with great content ("+shares_unread+")"
				}

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
				$("#commentThread").find("tr:gt(0)").remove();
				
				var displayName = null == current_share.user.display_name ? current_share.user.email : current_share.user.display_name;
				$("#sharedBy").html(displayName);
	
				for(var i = 0; i < data.share.comments.length; i++) {
					var comment = data.share.comments[i];
					var followsText = '';
					if ($.inArray(comment.user.id, all_follows) == -1) {
						followsText = ' (<span class="followUser_'+comment.user.id+'"><a href="" onclick="followUser('+comment.user.id+');return false;">Follow</a></span>)';
					}
					var username = null == comment.user.display_name ? comment.user.email : comment.user.display_name;
					$('#commentThread tr:last').after('<tr class="commentInstance"><td><p class="commentAuthor">'+username+followsText+' replied:</p></span><p class="commentText">'+comment.comment_text+'</p></td></tr>')
				}
				disableOverlay();
				mixpanel.track("Read another post");
			},
			error: function(xhr, text, error) {
				disableOverlay();
				//TODO: Log error
			}
		})
	} else {
		$("#shareUnreadCount").html(0);
		clearContent();
	}
};

$(document).ready(function() {
	document.title = "Amplifize | Great conversation goes best with great content ("+shares_unread+")";
	$("#container").css("margin-top", "108px");
	if(shares[position]) {
		updateShareContent(shares[position]);
	} else {
		clearContent();
	}

	$('#addComment-modal-content').bind('show', function () {
	  $('#comment_comment_text').val('');
	  setTimeout(function(){$("#comment_comment_text").focus();}, 250);
	});

	$('form#new_comment').bind("submit", function() {
		enableOverlay();
	});

	$('form#new_comment').bind("ajax:success", function(status, data, xhr) {
		$("#addComment-modal-content").modal("hide");
		$("#comment_text").val('');

		var comment = data.comment;
		var username = null == comment.user.display_name ? comment.user.email : comment.user.display_name;
		$('#commentThread tr:last').after('<tr class="commentInstance"><td><p class="commentAuthor">'+username+' replied:</p></span><p class="commentText">'+comment.comment_text+'</p></td></tr>')		

		disableOverlay();

		mixpanel.track("Comment in a conversation");
	});

	$('form#new_comment').bind("ajax:failure", function(data, status, xhr) {
		//TODO: log error
		disableOverlay();
	});
});
