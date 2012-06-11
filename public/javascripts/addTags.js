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

var AddTagsOverlay;

$(document).ready(function() {
	AddTagsOverlay = {
		container: null,
		init: function () {
			$("#addTags-modal-content").modal({
				overlayId: 'reader-overlay',
				containerId: 'reader-overlay-container',
				closeHTML: null,
				minHeight: 80,
				opacity: 65, 
				position: ['0',],
				overlayClose: true,
				onOpen: AddTagsOverlay.open,
				onClose: AddTagsOverlay.close
			});
		},
		open: function (d) {
			var self = this;
			self.container = d.container[0];
			d.overlay.fadeIn('slow', function () {
				$("#addTags-modal-content", self.container).show();
				var title = $("#addTags-modal-title", self.container);
				title.show();
				d.container.slideDown('slow', function () {
					setTimeout(function () {
						var h = $("#addTags-modal-data", self.container).height()
							+ title.height()
							+ 20; // padding
						d.container.animate(
							{height: h}, 
							200,
							function () {
								$("div.close", self.container).show();
								$("#addTags-modal-data", self.container).show();
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
});
