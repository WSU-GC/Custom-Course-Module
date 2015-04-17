(function(win) {
	var uiFn = {
		link: function(obj) {
			var ctrl = this.ctrl;
			var vm = this.vm;
			
			return m("a", {
				href: obj.href
				//onclick: vm.showLoading
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
		
		var contents = [].concat(obj).map(function(el, i) {
			if(Object.isObj(el) && !Array.isArray(el)) {
				return uiFn[el.uiFn].call(self, el, course);
			} else if (typeof el == 'function') {
				return el.call(self, course);
			} else {
				return el;
			}
		});
		
		return m("td", attrs, contents);
		
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
				var lecReg = /-lec$/i;
				var labReg = /-lab$/i;
				var rosterReg = /./i;
				
				if (lecReg.test(parentCourse)) {
					rosterReg = lecReg;
				} else if (labReg.test(parentCourse)) {
					rosterReg = labReg;
				}
				
				var localRosters = (rosters || []).filter(function(el) {
					return rosterReg.test(el.courseId);
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