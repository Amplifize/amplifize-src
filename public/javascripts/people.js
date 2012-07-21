var customValidate = function(input) {
	if (input.validity.typeMismatch) {
		input.setCustomValidity("Email not valid. Maybe there's an extra space?");
	} else {
		input.setCustomValidity("");
	}
}

var inviteEmail = "";
var openInviteModal = function(email) {
	inviteEmail = email
	$('#inviteFriends-modal-content').modal('show');
}

$(document).ready(function() {

	$("#inviteFriends-modal-content").bind("show", function() {
		$("#invite_email").val(inviteEmail);
		$("#inviteFriends-modal-body").show();
		$("#inviteFriends-response-modal-body").hide();
		inviteEmail = "";
	});

	$('form#inviteFriendsForm').bind("ajax:success", function(status, data, xhr) {
		$("#inviteFriends-modal-body").hide();
		$("#inviteFriends-response-modal-body").show();
	});

});
