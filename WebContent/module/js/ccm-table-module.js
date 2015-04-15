(function(win) {
	var uiFn = {
		link: function(obj) {
			var ctrl = this.ctrl;
			var vm = this.vm;
			
			return m("a", {
				href: obj.href,
				onclick: vm.showLoading
			}, obj.text);
		},
		
		text: function(obj) {
			var ctrl = this.ctrl;
			var vm = this.vm;
			
			return obj.text;
		}
	};
	
	function tdContent(obj, course) {
		var ctrl = this.ctrl;
		var vm = this.vm;
		var self = this;
		var attrs = obj.attrs || {};
		
		if(Object.isObj(obj) && !Array.isArray(obj)) {
			return m("td", attrs, uiFn[obj.uiFn].call(self, obj, course));
		} else if (typeof obj == 'function') {
			return m("td", attrs, obj.call(self, course));
		} else {
			return m("td", attrs, obj);
		}
		
	}
	
	
	var table = new Module({
		controller: function() {
			//this.terms = new Terms.listAll();
			this.terms = [];
			this.loading = m.prop(false);
			this.rosters = m.prop([]);
			this.allRosters = m.prop();
			this.headers = [["enrl", "Enrl"], ["accessUri", "Course Title (Course ID)"], ["availableAction", "Availability"], ["action", "Action"]];
			this.parentCourseId = m.prop("");
			this.filter = function(item) {
				return true;
			};
		},
		
		viewModel: function(ctrl) {
			this.selectedTerm = m.prop("2015 Spring");
			this.itemsPerPage = m.prop(Infinity);
			this.selectedPage = m.prop(1);
			this.showChildren = m.prop(false);
			this.showRosterList = m.prop(false);
			
			this.showRosters = function(parentCourse) {
				var rosters = ctrl.allRosters()[this.selectedTerm()];
				var lecReg = /-lec$/ig;
				var labReg = /-lab$/ig;
				var rosterReg = function() { return true; };
				
				if (lecReg.test(parentCourse)) {
					rosterReg = lecReg.test.bind(lecReg);
				} else if (labReg.test(parentCourse)) {
					rosterReg = labReg.test.bind(labReg);
				}
				
				var localRosters = (rosters || []).filter(function(el) {
					return rosterReg(el.courseId);
				});
				
				ctrl.parentCourseId(parentCourse);
				ctrl.rosters(localRosters);
				this.showRosterList(true);
			};
			
			this.showLoading = function() {
				ctrl.loading(true);
			};
		},
		
		view: function() {
			var ctrl = this.ctrl;
			var vm = this.vm;
			var self = this;
			
			return m("table", {class: 'four'}, [m("tr", ctrl.headers.map(function(el, i) {
					return m("td", el[1]);
				})),
	 		  	ctrl.terms[vm.selectedTerm()].filter(ctrl.filter).map(function(co) {
	 		  		var cc = co.children.length && vm.showChildren()
	 			   		? [co].concat(co.children)
	 			   		: [co];
	 		   	   return cc.map(function(c) {
	 		    	   return m("tr", ctrl.headers.map(function(head, i) {
	 		    		   return tdContent.call(self, c[head[0]], c);
	 		    	   }));
	 		   		});
	 		      })
	 		  ]);
		}
	});
	
	/**
	 * Export
	 */
	win.tableModule = table;
}(window));