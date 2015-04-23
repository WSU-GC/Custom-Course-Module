;(function(win) {
	var selectedTerm = new Module({
		controller: function() {
			//this.terms = Object.keys(Terms.listAll()).sort(sortTerms); //.reverse();
			this.terms = [];
		},
		
		viewModel: function(ctrl) {
			this.selectedTerm = m.prop(ctrl.terms[0]);
		},
		
		view: function() {
			var ctrl = this.ctrl;
			var vm = this.vm;
			return m('div', [
		   	  "Term ",
		   	  m('select', {
		   		  onchange: m.withAttr('value', vm.selectedTerm)
		   	  }, [
		   	    ctrl.terms.map(function(item) {
		   	      return m('option', {
		   	    	  value: item,
		   	    	  selected: vm.selectedTerm() == item ? true : false
		   	      }, item)
		   	    })
		   	  ])
		   	]);
		}
	});
	
	win.selectedTerm = selectedTerm;
}(window))