
;function appLoader() {
	ready(function() {
		console.log('dom loaded');
		main();
		m.module(document.getElementById('instCourses'), app.init());
		startOpenTip();
	}, "isPolyFilled", "Opentip", "startOpenTip", "m", "Module", "jQuery", "Terms", "filter", "selectedTerm", "showChildren");
}
