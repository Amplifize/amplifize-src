$(document).ready(function() {
	
	$('form#updateProfileForm').bind("submit", function() {
		clearMessages();
		$('#updateProfileStatusMessage').html("Please wait...");
	});
	
	$('form#updateProfileForm').bind("ajax:success", function(status, data, xhr) {
		if (data.errors) {
			$('#updateProfileStatusMessage').html("Oops, an error occurred!");
			$.each(data.errors, function(key,value) {
				$('#'+key+'_error').html(String(value));				
			});
		} else {
			$('#updateProfileStatusMessage').html("All saved!");
		}
	});

	$('form#updateProfileForm').bind("ajax:failure", function(xhr, status, error) {
		console.log("here");
		alert(error);
	});
});

function clearMessages()
{
	$('.updateProfileFieldError').html("");
	$('#updateProfileStatusMessage').html("");
}


