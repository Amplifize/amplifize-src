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
	if((position+1) < posts.length) {
		position++;
		updateShareContent(shares[position]);
		
		if(position > max_position) {
			max_position = position;
			var unread_count = posts.length - 1 - max_position;
			$("#shareUnreadCount").html(unread_count);
			document.title = "Amplifize | Give good content a voice ("+unread_count+")"
		}
	} else {
		alert("No more posts");
	}
	
	return false;
};

var updateShareContent = function(shareId) {		
	$.ajax({
		url: "/shares/"+shareId,
		success: function(data, textStatus, jqXHR) {
			var current_post = data.share.post;
			current_share = data.share;
			
			$("#comment_share_id").val(data.share.id);
			
			$("#contentTitle").html('<a href="'+current_post.url+'" target="_blank">'+current_post.title+'</a></p>');
			$("#contentPublishDate").html(dateFormat(current_post.published_at, "dddd, mmmm dS, yyyy, h:MM:ss TT"));
			$("#contentSummary").html(data.share.summary);

			for(var i = 0; i < data.share.comments.length; i++) {
				var comment = data.share.comments[i];
				var html = '<div class="commentInstanceDiv"><p class="commentText">'+comment.comment_text+'</p><p class="commentAuthor">'+comment.user.email+'</p></div>';
				$("#commentThread").append(html);
			}

			setReadState(0);
		},
		error: function(xhr, text, error) {
			alert(error);
			alert(text);
		}
	})
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

		var unread_count = shares.length - 1; 
		$("#shareUnreadCount").html(unread_count);
		document.title = "Amplifize | Give good content a voice ("+unread_count+")";
	}

	updateShareContent(shares[position]); 
});
