(function(win) {
	var rosterModule = new Module({
		controller: function() {
			this.rosters = m.prop([]);
			this.showRosters = m.prop(true);
			this.parentCourse = m.prop("");
			this.selectedTerm = m.prop("");
		},
		
		viewModel: function(ctrl) {
			this.showTable = function() {
				ctrl.showRosters(false);
			};
			
			this.save = function() {
				// provide a function;
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
		   	    	  if(item.course.isOnline) {
		   	    		  return "*";
		   	    	  } else {
		   	    		  return m('input', {
		   	    			  type: 'checkbox',
		   	    			  value: item.course.courseId
		   	    		  });
		   	    	  }
	   	    	  }()), " " + item.course.displayTitle])
		   	    })
		   	  ]),
		   	  m("br"),
		   	  m("button", {onclick: vm.svae}, "Save")
		   	]);
		}
	});
	
	win.rosterModule = rosterModule;
}(window));
