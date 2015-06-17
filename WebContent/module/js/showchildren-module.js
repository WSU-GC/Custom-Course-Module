;(function(win) {
	var showChildren = new Module({
		controller: function() {
			
		},
		
		viewModel: function() {
			var showRosters = window.showRosters == "true" ? true : false;
			this.showChildren = m.prop(showRosters);
			this.userId = "";
			this.url = "";
			
			this.updateSelected = function() {
				$ = jQuery;
				var val = $('#showChildCourses').is(":checked") ? true : false;
				this.showChildren(val);
				
				var jxhr;
				
				var url = this.url + "?show-child-courses=" + val.toString() + "&user-id=" + this.userId;
				
				jxhr = $.ajax(url);
			
				jxhr.done(function(msg) {
					//console.log(msg);
					if(msg.result !== 'success') 
						console.error("Error updating Show Rosters to %s", val.toString());
					else
						console.log('Successfully updated Show Rosters to %s', val.toString());
				});
			
				jxhr.fail(function(xhr, statusText, error) {
					alert('Error: failed to set Show Rosters to ' + val.toString() + '. Error message: ' + error);
				});
			};
		},
		
		view: function() {
			var ctrl = this.ctrl;
			var vm = this.vm;
			return m('div', ['Show Rosters', m('input#showChildCourses', {
				type: 'checkbox',
			    //onclick: m.withAttr('checked', vm.showChildren),
				onclick: vm.updateSelected.bind(vm),
			    checked: vm.showChildren()
			})]);
		}
	});
	
	win.showChildren = showChildren;
}(window));