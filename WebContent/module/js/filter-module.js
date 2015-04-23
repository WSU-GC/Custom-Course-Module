;(function(win) {
	var filter = new Module({
		controller: function() {
					
		},
		
		viewModel: function() {
			this.searchTerm = m.prop("");
		},
		
		view: function() {
			var ctrl = this.ctrl;
			var vm = this.vm;
			return m('div', {id: 'filter'}, [m('input', {
			    oninput: m.withAttr('value', vm.searchTerm),
			    placeholder: 'search',
			    value: vm.searchTerm()
			  })
			]);
		}
	});
	
	// Export
	win.filter = filter;
}(window));