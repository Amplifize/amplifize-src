$(document).ready(function() {
	updateShareContent(shares[position]); 
});

var current_share = undefined;
var position = 0;

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
		updateShareContent(posts[position]);
	}
	
	return false;
};
	
var upPost = function() {
	if(position < posts.length) {
		position++;
		updateShareContent(posts[position]);
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
			$("#shareSummary").html(data.share.summary);

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

