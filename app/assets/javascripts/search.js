var current_share = undefined;

var resetAppState = function () {
	current_share = undefined;
};

var muteConversation = function() {
	enableOverlay();
	setReadState(2);
	$('#confirm-delete-modal').modal('hide');
	disableOverlay();	
};

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
};

var openNewWindow = function() {
	if(current_share) {
		window.open(current_share.url);
	}
};

var followUser = function(userId) {
	$.ajax({
		url: '/follows/'+userId+'/add',
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
	disableOverlay();
	
	$("#feedTitle").html('');
	$("#contentRow").html('');
	$("#shareInfo").css("visibility", "hidden").css("display", "none");
	$("#contentBody").html("<h3>Looks like you've got no more conversations to read</h3>");
	$("#content").animate({scrollTop: 0});
	$("#contentSourceSite").css("visibility", "hidden").css("display", "none");

	$("#shareUnreadCount").html("0");
	document.title = "Amplifize | Great conversation goes best with great content (0)";
};

var openPost = function(shareId) {
	$.ajax({
		url: "/shares/"+shareId,
		success: function(data, textStatus, jqXHR) {
			//empty out comment field on new post
			$('#comment_comment_text').val('');
			
			current_share = data;			

			var displayName = null == current_share.user.display_name ? current_share.user.email : current_share.user.display_name;
			$("#popup_sharedBy").html(displayName);
			$("#popup_sharedDate").html(dateFormat(current_share.created_at, "mmmm dS", false));
			$("#popup_conversationStarter").html(current_share.summary);	


			if(current_share.post.feed) {
				$("#popup_feedTitle").html('<a href="'+current_share.post.feed.site_url+'" target="_blank">'+current_share.post.feed.title+'</a>');
			}

			$("#popup_contentTitle").html('<p><a href="'+current_share.post.url+'" target="_blank">'+current_share.post.title+'</a></p>');
			if(current_share.post.author) {
				$("#popup_contentAuthor").html("by "+current_share.post.author+" ");
			} else {
				$("#popup_contentAuthor").html("");
			}

			$("#popup_contentPublishDate").html("Written on "+dateFormat(current_share.post.published_at, "dddd, mmmm dS, yyyy, h:MM:ss TT", false));
			$("#popup_contentBody").html(current_share.post.content);
			$("#comment_share_id").val(current_share.id);

			$("#popup_commentThread").find("tr:gt(0)").remove();
			
			var scrollNode = null;
			for(var i = 0; i < data.comments.length; i++) {
				var comment = data.comments[i];
				var followsText = '';
				if ($.inArray(comment.user.id, all_follows) == -1) {
					followsText = ' (<span class="followUser_'+comment.user.id+'"><a href="" onclick="followUser('+comment.user.id+');return false;">Follow</a></span>)';
				}
				var username = null == comment.user.display_name ? comment.user.email : comment.user.display_name;
				$('#popup_commentThread tr:last').after('<tr class="commentInstance"><td><p class="commentAuthor">'+username+followsText+' replied '+prettyDate(dateFormat(comment.created_at, "isoDateTime", false))+':</p></span><p class="commentText">'+comment.comment_text.split("\n").join("<br />")+'</p></td></tr>');
			}

			disableOverlay();
			$("#postPopup-modal-content").modal('show');
			if(scrollNode) {
				$("#postPopup-modal-content").animate({scrollTop: (scrollNode.offset().top - 50)}, "fast");
			} else {
				$("#postPopup-modal-content").animate({scrollTop: 0}, "fast");
			}
		},
		error: function(xhr, text, error) {
			//log error here
			disableOverlay();
		},
		dataType: "json"
	});
};

$(document).ready(function() {
	resetAppState();

	$('#addComment-modal-content').bind('show', function () {
	  setTimeout(function(){$("#comment_comment_text").focus();}, 250);
	});

	$("#postPopup-modal-content").bind('show', function() {
		$("#postPopup-modal-content .modal-body").animate({scrollTop: 0});
	});

	$('form#new_comment').bind("submit", function() {
		enableOverlay();
	});

	$('form#new_comment').bind("ajax:success", function(status, data, xhr) {
		$("#addComment-modal-content").modal("hide");
		$("#comment_comment_text").val('');

		var comment = data;
		var username = null == comment.user.display_name ? comment.user.email : comment.user.display_name;
		$('#commentThread tr:last').after('<tr class="commentInstance"><td><p class="commentAuthor">'+username+' replied '+prettyDate(dateFormat(new Date(), "isoDateTime",false))+':</p></span><p class="commentText">'+comment.comment_text+'</p></td></tr>');
		$('#popup_commentThread tr:last').after('<tr class="commentInstance"><td><p class="commentAuthor">'+username+' replied '+prettyDate(dateFormat(new Date(), "isoDateTime", false))+':</p></span><p class="commentText">'+comment.comment_text.split("\n").join("<br />")+'</p></td></tr>');

		disableOverlay();
	});

	$('form#new_comment').bind("ajax:failure", function(data, status, xhr) {
		//TODO: log error
		disableOverlay();
	});

	//need to do this to prevent firefox from auto searching on typing
	jQuery(document).bind('keydown', 'v', function(evt) {
		return false;
	});

	jQuery(document).bind('keydown', 'c', function(evt) {
		return false;
	});

	jQuery(document).bind('keyup', 'v', function(evt) {
		openNewWindow();
		return false;
	});

	jQuery(document).bind('keyup', 'c', function(evt) {
		if(!evt.ctrlKey) {
			$("#addComment-modal-content").modal("show");
			return false;
		}
	});
});
