$(document).ready(function() {
	$('form#userSearchForm').bind("ajax:success", function(status, data, xhr) {
		$("#search_email").val("");
		//TODO: if data is blank, then say so
		//else
		$('#reader-overlay-container').css('height', 'auto');
		$('#userSearchResultsTable > tbody:last').append('<tr><td>'+data.user.email+'</td><td><a href="#" onclick="followUser('+data.user.id+')">Follow</a></td></tr>');
	});

	$('form#userSearchForm').bind("ajax:failure", function(xhr, status, error) {
		alert(error);
	});
});

var followUser = function(userId) {
	$.ajax({
		url: '/follows/add/'+userId,
		success: function(data, textStatus, jqXHR) {
			alert("It worked. Click okay!");
		},
		error: function(xhr, text, error) {
			alert(error);
			alert(text);
		}
	});
};

