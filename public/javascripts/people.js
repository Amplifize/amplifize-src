var customValidate = function(input) {
	if(input.validity.typeMismatch){ 
		input.setCustomValidity("Email not valid. Maybe there's an extra space?"); 
	} else { 
		input.setCustomValidity(""); 
	}
}

$(document).ready(function() { });
