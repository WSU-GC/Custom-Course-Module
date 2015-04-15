(function(win) {
	var rosterModule = new Module({
		controller: function() {
			this.rosters = m.prop([]);
			this.showRosters = m.prop(true);
			this.parentCourse = m.prop("");
			this.selectedTerm = m.prop("");
			this.loading = m.prop(false);
		},
		
		viewModel: function(ctrl) {
			this.showTable = function() {
				ctrl.showRosters(false);
			};
			
			this.save = function() {
				// provide a function;
			};
			
			this.showLoading = function() {
				ctrl.loading(true);
			};
			
			this.merge = function() {
				ctrl.loading(true);
				this.save(ctrl.parentCourse());
			};
		},
		
		view: function() {
			var ctrl = this.ctrl;
			var vm = this.vm;
			return m('div', [
			  m("br"),
			  m("a", {
				 href: "#",
				 onclick: vm.showTable 
			  }, "Go Back"),
			  m("br"),
		   	  m("h6", "Parent Course Space"),
		   	  m("br"),
		   	  m("#parentCourse", ctrl.parentCourse()),
		   	  m("br"),
		   	  m("h6", "Select rosters to include in merge"),
		   	  m("br"),
		   	  m('ul', {id: "mergeList"}, [
		   	    ctrl.rosters().map(function(item) {
		   	      return m('li', [(function() { 
		   	    	  if(item.isOnline) {
		   	    		  return "*";
		   	    	  } else {
		   	    		  return m('input', {
		   	    			  type: 'checkbox',
		   	    			  value: item.courseId
		   	    		  });
		   	    	  }
	   	    	  }()), " " + item.displayTitle])
		   	    })
		   	  ]),
		   	  m("br"),
		   	  m("button", { onclick: vm.merge.bind(vm) }, "Save"),
		   	  m("br"),
		   	  m("br")
		   	]);
		}
	});
	
	win.rosterModule = rosterModule;
}(window));
