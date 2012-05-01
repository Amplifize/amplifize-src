var loadManagePeople = function() {
	alert("Coming soon!");

	// $.ajax({
		// url: "/follows/manage",
		// success: function (data, textStatus, jqXHR) {
			// $("#amplifizeContent").html(data);
		// },
		// error: function(xhr, text, error) {
			// alert(error);
		// },
		// dataType: "html"
	// });
};

var customValidate = function(input) {
	if(input.validity.typeMismatch){ 
		input.setCustomValidity("Email not valid. Maybe there's an extra space?"); 
	} else { 
		input.setCustomValidity(""); 
	}
}

$(document).ready(function() {
	$("li#peopleNav.drawer ul").css("display", "block").css("visibility", "visible");
});
