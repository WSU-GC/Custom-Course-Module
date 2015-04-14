(function(win) {
	win.startOpenTip = function startOpenTip() {

		var availabilityMessage = "Enable/Disable your course for student viewing.";
		var actionMessage = "<strong style='text-decoration: underline;'>Activate</strong>: Creates a course space for the corresponding roster. <br/>"
			+ "<strong style='text-decoration: underline;'>Remove</strong>: Pull the roster enrollments out of the parent course space. <br/>"
			+ "<strong style='text-decoration: underline;'>Course Verification</strong>: Manage Global Campus courses.<br />"
			+ "<strong style='text-decoration: underline;'>Merge</strong>: Add roster sections to the selected course space.";
		
		Opentip.styles.extendedAlert = {
				extends: "alert",
				background: "#981e32",
				color: "#ffffff"
		}
		
		var options = {
			target: true,
			tipJoint: "bottom",
			style: "extendedAlert"
		};
		new Opentip("#availabilityTT", availabilityMessage, options);
		new Opentip("#actionTT", actionMessage, options);
	}
}(window));