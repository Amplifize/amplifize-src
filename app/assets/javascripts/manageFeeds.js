var deleteTag = function(tagId) {
	enableOverlay();

	$.ajax({
		url: "/tags/"+tagId,
		type: "DELETE",
		success: function(data, textStatus, jqXHR) {
			$("#tag_"+tagId).remove();
			disableOverlay();
		},
		error: function(xhr, text, error) {
			//TODO: Log the error
			disableOverlay();
		},
		dataType: "json"
	});
};

$(document).ready(function() {
	$('form#new_feed').bind("ajax:success", function(data, status, xhr) {
		$('#feed_url').val('');
		$('#feed_tags').val('');

		$('#addFeed-modal-content').modal('hide');
	});

	$('.addTagsLink').on("click", function() {
		 $("#tag_feed_id").val($(this).data('id'));
		 
		 $('#tag_name').val('');
		setTimeout(function(){$("#tag_name").focus();}, 250);
	});
	
	$('form#new_tag').bind("ajax:success", function(status, data, xhr) {
		$("#tag_name").val();
		$("#addTags-modal-content").modal("hide");

		var ul = $("#feed_"+data.feed_id+" .manageFeedRowTags");
		for(var new_tag in data.tags) {
			var tag = data.tags[new_tag];
			ul.prepend("<li id='tag_"+tag['id']+"' onclick='deleteTag("+tag['id']+")'><div class='manageFeedTagName'>"+tag['name']+"</div><div class='icon deleteTag' style='background-position:-207px;'></div></li>");
		}
	});

	$('form#new_tag').bind("ajax:failure", function(status, data, xhr) {
		alert(status);
	});
});