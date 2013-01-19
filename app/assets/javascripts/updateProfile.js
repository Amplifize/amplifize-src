$(document).ready(function() {
	$('form#updateProfileForm').bind("submit", function() {
		clearMessages();
		$('#updateProfileStatusMessage').html("Please wait...");
	});
	
	$('form#updateProfileForm').bind("ajax:success", function(status, data, xhr) {
		statusField = $('#updateProfileStatusMessage');
		if (data.errors) {
			statusField.html("Oops, an error occurred!");
			statusField.addClass("updateProfileFieldError");
			$.each(data.errors, function(key,value) {
				$('#'+key+'_error').html('Error: ' + String(value));				
			});
			
		} else {
			
			statusField.html("All saved!");
			statusField.addClass("updateProfileFieldSuccess");
		}
	});

	$('form#updateProfileForm').bind("ajax:failure", function(xhr, status, error) {
		console.log("here");
		alert(error);
	});
});

function clearMessages()
{
	$('#updateProfileStatusMessage').removeClass('updateProfileFieldSuccess updateProfileFieldError');
	$('.updateProfileFieldError').html("");
	$('#updateProfileStatusMessage').html("");
}


