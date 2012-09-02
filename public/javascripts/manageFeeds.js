var addTags = function(feedId) {
	$("#tag_feed_id").val(feedId);
	$("#addTags-modal-content").modal();
	$('#tag_name').val('');
	setTimeout(function(){$("#tag_name").focus();}, 250);
};

var populateDeleteTags = function(feedId) {
	$.ajax({
		url: "/feeds/"+feedId+"/tags",
		success: function(data, textStatus, jqXHR) {
			var deleteDiv = $("#feedTagsToDelete");
			deleteDiv.html('');
			for(var i=0; i < data.tags.length; i++) {
				deleteDiv.append('<a href="#" id="delete_popup_tag_'+data.tags[i].tag.id+'" onclick=deleteTagFromFeed('+ data.tags[i].tag.id +'); return false;">'+data.tags[i].tag.name+'</p>');
			}
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

$(document).ready(function() {
	$("#shareUnreadCount").html("<%= @shares_unread_count %>");
	$("#feedUnreadCount").html("<%= @posts_unread_count %>");

	$('form#new_tag').bind("ajax:success", function(status, data, xhr) {
		$("#tag_name").val();
		$("#addTags-modal-content").modal("hide");

		var ul = $("#feed_"+data.feed_id+" .manageFeedRowTags");
		for(var i =0; i < data.tags.length; i++) {
			ul.append("<li>"+data.tags[i]+"</li>");
		}
	});

	$('form#new_tag').bind("ajax:failure", function(status, data, xhr) {
		alert(status);
	});
});