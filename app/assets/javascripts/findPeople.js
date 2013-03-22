$(document).ready(function() {
	$('form#userSearchForm').bind("ajax:success", function(status, data, xhr) {
		var formField = $("#search_email");
		if(null == data) {
			$("#emptyUserSearchResult").html("No amplifize user found with email address: "+formField.val() +".<br /><a href=\"#\" data-dismiss=\"modal\" onclick=\"openInviteModal('"+formField.val()+"')\">Why not invite them?</a>");
		}
		else {
			$('#userSearchResultsTable > tbody:last').append('<tr><td>'+data.email+'</td><td id="follow_'+data.id+'"><a href="#" onclick="followUser('+data.id+')">Follow</a></td></tr>');
		}

		formField.val("");
	});

	$('form#userSearchForm').bind("ajax:failure", function(xhr, status, error) {
		alert(error);
	});
});

var followUser = function(userId) {
	$.ajax({
		url: '/follows/'+userId+'/add/',
		success: function(data, textStatus, jqXHR) {
			$("#follow_"+userId).html("Successfully followed");
		},
		error: function(xhr, text, error) {
			alert(error);
			alert(text);
		}
	});
};

