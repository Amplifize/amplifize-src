/*
 * SimpleModal OSX Style Modal Dialog
 * http://www.ericmmartin.com/projects/simplemodal/
 * http://code.google.com/p/simplemodal/
 *
 * Copyright (c) 2010 Eric Martin - http://ericmmartin.com
 *
 * Licensed under the MIT license:
 *   http://www.opensource.org/licenses/mit-license.php
 *
 * Revision: $Id: osx.js 238 2010-03-11 05:56:57Z emartin24 $
 */

$(document).ready(function() {
	var FindPeopleOverlay = {
		container: null,
		init: function () {
			$("#findPeopleNavItem").click(function (e) {
				e.preventDefault();	

				$("#findPeople-modal-content").modal({
					overlayId: 'reader-overlay',
					containerId: 'reader-overlay-container',
					closeHTML: null,
					minHeight: 80,
					opacity: 65, 
					position: ['0',],
					overlayClose: true,
					onOpen: FindPeopleOverlay.open,
					onClose: FindPeopleOverlay.close
				});
			});
		},
		open: function (d) {
			var self = this;
			self.container = d.container[0];
			d.overlay.fadeIn('slow', function () {
				$("#findPeople-modal-content", self.container).show();
				var title = $("#findPeople-modal-title", self.container);
				title.show();
				d.container.slideDown('slow', function () {
					setTimeout(function () {
						var h = $("#findPeople-modal-data", self.container).height()
							+ title.height()
							+ 20; // padding
						d.container.animate(
							{height: h}, 
							200,
							function () {
								$("div.close", self.container).show();
								$("#findPeople-modal-data", self.container).show();
							}
						);
					}, 300);
				});
			})
		},
		close: function (d) {
			var self = this; // this = SimpleModal object
			d.container.animate(
				{top:"-" + (d.container.height() + 20)},
				500,
				function () {
					self.close(); // or $.modal.close();
				}
			);
		}
	};

	FindPeopleOverlay.init();
	
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
			alert("It worked. Click okay, and then click anywhere else");
		},
		error: function(xhr, text, error) {
			alert(error);
			alert(text);
		}
	});
};

