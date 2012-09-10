var customValidate = function(input) {
	if (input.validity.typeMismatch) {
		input.setCustomValidity("Email not valid. Maybe there's an extra space?");
	} else {
		input.setCustomValidity("");
	}
}

// Opens the invite modal with the given email address
// pre-populated in the email box
var inviteEmail = "";
var openInviteModal = function(email) {
	inviteEmail = email;
	$('#inviteFriends-modal-content').modal();
}

$(document).ready(function() {

	// "Shown" Listener for findPeople modal
	$("#findPeople-modal-content").on("shown", function() {
		$("#search_email").focus();
	});

	// "Show" listener for inviteFriends modal
	$("#inviteFriends-modal-content").on("show", function() {
		$("#invite_email").val(inviteEmail);
		$("#inviteFriends-modal-body").show();
		$("#inviteFriends-response-modal-body").hide();
		inviteEmail = "";
	});

	// "Shown" listener for inviteFriends modal
	$("#inviteFriends-modal-content").on("shown", function() {
		$("#invite_email").focus();
	});

	// Response listener for inviteFriends form
	$('form#inviteFriendsForm').on("ajax:success", function(status, data, xhr) {
		$("#inviteFriends-modal-body").hide();
		$("#inviteFriends-response-modal-body").show();
	});

	$("#container").css("margin-top", "45px");
});
