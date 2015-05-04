;(function(win) {
	var selectedTerm = new Module({
		controller: function() {
			//this.terms = Object.keys(Terms.listAll()).sort(sortTerms); //.reverse();
			this.terms = [];
			this.userRoleId = m.prop('');
		},
		
		viewModel: function(ctrl) {
			this.userId = '';
			this.url = "";
			
			var ind = ctrl.terms.indexOf(ctrl.userRoleId().replace('-', ' '));
			ind = ind > 0 ? ind : 0;
			
			this.selectedTerm = m.prop(ctrl.terms[ind]);
			
			this.updateSelected = function() {
				$ = jQuery;
				var val = $('#selectedTerm option:selected').val();
				var roleId = val.replace(' ', '-');
				this.selectedTerm(val);
				console.log(this.userId);
				console.log(roleId);
				
				var jxhr;
				
				var url = this.url + "?role-id=" + roleId + "&user-id=" + this.userId;
				
				jxhr = $.ajax(url);
			
				jxhr.done(function(msg) {
					//console.log(msg);
					if(msg.result !== 'success') 
						console.error("Error updating default term to %s", roleId);
					else
						console.log('Successfully updated default term to %s', roleId);
				});
			
				jxhr.fail(function(xhr, statusText, error) {
					alert('Error: failed to set default term to ' + roleId + '. Error message: ' + error);
				});
			}
		},
		
		view: function() {
			var ctrl = this.ctrl;
			var vm = this.vm;
			return m('div', [
		   	  "Term ",
		   	  m('select#selectedTerm', {
		   		  //onchange: m.withAttr('value', vm.selectedTerm)
		   		  onchange: vm.updateSelected.bind(vm)
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