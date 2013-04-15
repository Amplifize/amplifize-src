var customValidate = function(input) {
	if (input.validity.typeMismatch) {
		input.setCustomValidity("Email not valid. Maybe there's an extra space?");
	} else {
		input.setCustomValidity("");
	}
}

var inviteFriendFromSearch = function(email) {
	$("#invite_email").val(email);

	$("#findFriends-form").show();
	$("#findFriends-response").hide();
}

var followUser = function(userId) {
	$.ajax({
		url: '/follows/'+userId+'/add/',
		success: function(data, textStatus, jqXHR) {
			$("#follow_"+userId).html("<p>Successfully followed</p>");
			
			setTimeout(function(){
				$("#findFriends-form").show();
				$("#findFriends-response").hide();
			}, 2000);
		},
		error: function(xhr, text, error) {
			//TODO: Log errors
			$("#follow_"+userId).html("<p>There was an error. Please try again.");
			
			setTimeout(function(){
				$("#findFriends-form").show();
				$("#findFriends-response").hide();
			}, 2000);
		}
	});
};

$(document).ready(function() {
	$('form#inviteFriendsForm').on("ajax:success", function(status, data, xhr) {
		$("#inviteFriends-form").hide();
		$("#inviteFriends-response").show();
		setTimeout(function(){
			$("#invite_email").val();
			$("#inviteFriends-form").show();
			$("#inviteFriends-response").hide();	
		}, 2000);
	});

	$('form#userSearchForm').bind("ajax:success", function(status, data, xhr) {
		var formField = $("#search_email");

		if(null == data) {
			$("#userSearchResult").html("");
			$("#emptyUserSearchResult").html("<p>No amplifize user found with email address:<br/><br/> "+formField.val() +".<br /><br/><a href=\"#\" onclick=\"inviteFriendFromSearch('"+formField.val()+"');return false;\">Why not invite them?</a></p>");
		}
		else {
			$("#emptyUserSearchResult").html('');
			$('#userSearchResult').html('<p><a href="#" onclick="followUser('+data.id+');return false;">Follow</a> '+data.email+' on amplifize</p>');
		}

		$("#findFriends-form").hide();
		$("#findFriends-response").show();

		formField.val("");
	});

	$('form#userSearchForm').bind("ajax:failure", function(xhr, status, error) {
		alert(error);
	});
});
