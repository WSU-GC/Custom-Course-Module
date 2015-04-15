(function(win) {
	var loadingModule = new Module({
		controller: function() {
					
		},
		
		viewModel: function() {

		},
		
		view: function() {
			var ctrl = this.ctrl;
			var vm = this.vm;
			return m('div', [
			     m("br"),
			     m("br"),
                 m("h6", "Loading..."),
                 m("br"),
                 m("br")
             ]);
		}
	});
	
	// Export
	win.loadingModule = loadingModule;
}(window));