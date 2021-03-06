var current_share = undefined;
var shares = undefined;
var position = 0;
var shares_unread = 0;

var loadFlyOut = function () {
	$("#commentPostFlyout").css("visibility", "visible").css("display", "block");
	$("#commentContentOption").css("background-color", "#4ac36c");
	$("#footer").css("margin-bottom", "240px");
	
	setTimeout(function(){$("#comment_comment_text").focus();}, 250);
	
	return false;
};

var hideFlyOut = function () {
	$("#commentPostFlyout").css("visibility", "hidden").css("display", "none");
	$("#commentContentOption").css("background-color", "inherit");
	$("#footer").css("margin-bottom", "45px");
	
	return false;
};

var resetAppState = function () {
	current_share = undefined;
	position = 0;
};

var toggleContentOrder = function() {
	contentOrder = $("#toggleContentSelect").val();

	$.cookie("contentOrder", contentOrder);
	updateSharesArray();
};

var toggleContentLayout = function() {
	contentLayout = $("#toggleContentLayout").val();

	$.cookie("contentLayout", contentLayout);
	updateSharesArray();
};

var toggleContentSort = function() {
	contentSort = $("#toggleContentSort").val();
	
	$.cookie("contentSort", contentSort);
	updateSharesArray();
};

var muteConversation = function() {
	enableOverlay();
	setReadState(2);
	
	shares.splice(position, 1);
	if("titleView" == contentLayout) {
		$("#share_"+current_share.id).remove();
	}
	upPost();
	
	
	$('#confirm-delete-modal').modal('hide');
	disableOverlay();	
};

var updateSharesArray = function() {
	resetAppState();
	enableOverlay();

	$.ajax({
		url: "/share_users/",
		data: {
			"content_order" : contentOrder,
			"content_sort" : contentSort,
			"content_layout" : contentLayout
		},
		success: function(data, textStatus, jqXHR) {
			shares = data;
			shares_unread = shares.length;
			document.title = "Amplifize | Great conversation goes best with great content ("+shares_unread+")";

			if(0 == shares_unread) {
				clearContent();
			} else {
				if("postView" == contentLayout) {
					updateShareContent(shares[position]);	
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

var setReadState = function(readState) {
	if(1 == readState) {
		shares[position]["read_state"] = 1;

		if("titleView" == contentLayout) {
			$("li#share_"+current_share.id).removeClass("read").addClass("unread");
		}
		
		++shares_unread;
		$("#shareUnreadCount").html(shares_unread);
		document.title = "Amplifize | Great conversation goes best with great content ("+shares_unread+")";
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
};

var downPost = function() {
	if(position > 0) {
		position--;
		if("titleView" == contentLayout) {
			openPost(shares[position]["share_id"]);
		} else {
			updateShareContent(shares[position]);
		}
	} else {
		alert("At the first share");
	}
	
	return false;
};
	
var upPost = function() {
	if((position+1) < shares.length) {
		position++;
		if("titleView" == contentLayout) {
			openPost(shares[position]["share_id"]);
		} else {
			updateShareContent(shares[position]);
		}		
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

var updateTitleContent = function() {
	$(".postViewOnly").css("visibility", "hidden");
	$("#contentMetadata").css("visibility", "hidden").css("display", "none");
	$("#shareInfo").css("visibility", "hidden").css("display", "none");
	$("#contentSourceSite").css("visibility", "hidden").css("display", "none");

	current_share = undefined;

	$("#shareUnreadCount").html(shares.length);
	document.title = "Amplifize | Great conversation goes best with great content ("+shares.length+")";

	$("#contentBody").html("");
	$("#contentBody").append('<ul id="titleList"></ul>');
	for(var i = 0; i < shares.length; i++) {
		var sharerName = shares[i]["display_name"] ? shares[i]["display_name"] : shares[i]["email"];
		var readStateClass = shares[i]["read_state"] == 0 ? "read" : "unread";
		
		$("#titleList").append(
			'<li id="share_'+shares[i]["share_id"]+'" class="'+readStateClass+'"> ' +
			'<a href="#" onclick="openPost('+shares[i]["share_id"]+');return false;">'+shares[i]["post_title"]+'</a>'+
			'<span>Shared by '+sharerName+'</span></li>'
		);
	}
	
	disableOverlay();
};

var openPost = function(shareId) {
	$.ajax({
		url: "/shares/"+shareId,
		success: function(data, textStatus, jqXHR) {
			//empty out comment field on new post
			$('#comment_comment_text').val('');
			
			current_share = data;			
			for(var i = 0; i < shares.length; i++) {
				if(shareId == shares[i]["share_id"]) {
					position = i;
					break;
				}
			}

			if(1 == shares[position]["read_state"]) {
				shares[position]["read_state"] = 0;
				setReadState(0);

				$("li#share_"+shareId).removeClass("unread").addClass("read");

				$("#shareUnreadCount").html(--shares_unread);
				document.title = "Amplifize | Great conversation goes best with great content ("+shares_unread+")";
			}

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
				if(null === scrollNode && comment.created_at > shares[position]["last_updated_at"]) {
					scrollNode = $("#popup_commentThread tr:last");
				}
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

var updateShareContent = function(shareId) {
	if(shareId["share_id"]) {
		$("#contentBody").html('');
		
		$(".postViewOnly").css("visibility", "visible");
		$("#contentMetadata").css("visibility", "visible").css("display", "block");
		$("#shareInfo").css("visibility", "visible").css("display", "block");
		$("#contentSourceSite").css("visibility", "visible").css("display", "block");
		
		//empty out comment field when I move to new content
		$('#comment_comment_text').val('');

		enableOverlay();
		$.ajax({
			url: "/shares/"+shareId["share_id"],
			success: function(data, textStatus, jqXHR) {
				var current_post = data.post;
				current_share = data;

				if(1 == shares[position]["read_state"]) {
					shares[position]["read_state"] = 0;
					setReadState(0);
					
					$("#shareUnreadCount").html(--shares_unread);
					document.title = "Amplifize | Great conversation goes best with great content ("+shares_unread+")";
				}

				$("#comment_share_id").val(current_share.id);

				var displayName = null == current_share.user.display_name ? current_share.user.email : current_share.user.display_name;
				$("#sharedBy").html(displayName);
				$("#sharedDate").html(dateFormat(current_share.created_at, "mmmm dS", false));
				$("#conversationStarter").html(current_share.summary);	

				if (typeof(current_post.feed) != "undefined") {
					$("#feedTitle").html('<a href="'+current_post.feed.site_url+'" target="_blank">'+current_post.feed.title+'</a>');
				}

				$("#contentTitle").html('<p><a href="'+current_post.url+'" target="_blank">'+current_post.title+'</a></p>');
				$("#contentPublishDate").html("Written on "+dateFormat(current_post.published_at, "dddd, mmmm dS, yyyy, h:MM:ss TT", false));
				
				if(current_post.author) {
					$("#contentAuthor").html(" by "+current_post.author+" ");
				} else {
					$("#contentAuthor").html("");
				}
				
				$("#contentBody").html(current_post.content);
				$("#commentThread").find("tr:gt(0)").remove();

				var scrollNode = null;
				for(var i = 0; i < data.comments.length; i++) {
					var comment = data.comments[i];
					var followsText = '';
					if ($.inArray(comment.user.id, all_follows) == -1) {
						followsText = ' (<span class="followUser_'+comment.user.id+'"><a href="" onclick="followUser('+comment.user.id+');return false;">Follow</a></span>)';
					}
					var username = null == comment.user.display_name ? comment.user.email : comment.user.display_name;
					$('#commentThread tr:last').after('<tr class="commentInstance"><td><p class="commentAuthor">'+username+followsText+' replied '+prettyDate(dateFormat(comment.created_at, "isoDateTime", false))+': </p></span><p class="commentText">'+comment.comment_text+'</p></td></tr>');

					if(null === scrollNode && comment.created_at > shares[position]["last_updated_at"]) {
						scrollNode = $("#commentThread tr:last");
					}
				}

				disableOverlay();

				if(scrollNode) {
					$("html, body").animate({scrollTop: (scrollNode.offset().top - 50)}, "fast");
				} else {
					$("html, body").animate({ scrollTop: 0 }, "fast");
				}
			},
			error: function(xhr, text, error) {
				disableOverlay();
				//TODO: Log error
			}
		});
	} else {
		$("#shareUnreadCount").html(0);
		clearContent();
	}
};

$(document).ready(function() {
	resetAppState();
	updateSharesArray();

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
		hideFlyOut();
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
	
	$("#toggleContentSelect").val(contentOrder).selectbox();
	$("#toggleContentLayout").val(contentLayout).selectbox();
	$("#toggleContentSort").val(contentSort).selectbox();
	
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

	jQuery(document).bind('keydown', 'c', function(evt) {
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

	jQuery(document).bind('keyup', 'c', function(evt) {
		if(!evt.ctrlKey) {
			$("#addComment-modal-content").modal("show");
			return false;
		}
	});
});
