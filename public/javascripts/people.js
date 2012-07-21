var customValidate = function(input) {
	if (input.validity.typeMismatch) {
		input.setCustomValidity("Email not valid. Maybe there's an extra space?");
	} else {
		input.setCustomValidity("");
	}
}

$(document).ready(function() {

	$("#inviteFriends-modal-content").bind("show", function() {
		$("#inviteFriends-modal-body").show();
		$("#inviteFriends-response-modal-body").hide();
	});

	$('form#inviteFriendsForm').bind("ajax:success", function(status, data, xhr) {
		$("#inviteFriends-modal-body").hide();
		$("#inviteFriends-response-modal-body").show();
	});

});
