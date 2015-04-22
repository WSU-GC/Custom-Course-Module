;(function(win) {
	var showChildren = new Module({
		controller: function() {
			
		},
		
		viewModel: function() {
			this.showChildren = m.prop(true);
		},
		
		view: function() {
			var ctrl = this.ctrl;
			var vm = this.vm;
			return m('div', ['Show Rosters', m('input', {
				type: 'checkbox',
			    onclick: m.withAttr('checked', vm.showChildren),
			    checked: vm.showChildren()
			})]);
		}
	});
	
	win.showChildren = showChildren;
}(window));