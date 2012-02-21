$(document).ready(function() {
	updatePostContent(posts[position]);
});

var current_post = undefined;
var position = 0;
	
var setReadState = function(readState) {
	$.ajax({
		url: "/post_users/"+current_post.id+"/read_state/"+readState,
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
		updatePostContent(posts[position]);
	}
	
	return false;
};
	
var upPost = function() {
	if(position < posts.length) {
		position++;
		updatePostContent(posts[position]);
	}
	
	return false;
};

var share = function() {
	
};

var updatePostContent = function(postId) {		
	$.ajax({
		url: "/posts/"+postId,
		success: function(data, textStatus, jqXHR) {
			current_post = data.post;
			
			$("#contentTitle").html('<a href="'+current_post.url+'">'+current_post.title+'</a></p>');
			$("#contentPublishDate").html(dateFormat(current_post.published_at, "dddd, mmmm dS, yyyy, h:MM:ss TT"));
			$("#contentSummary").html(current_post.content);

			setReadState(0);
		},
		error: function(xhr, text, error) {
			alert(error);
			alert(text);
		}
	})
};
