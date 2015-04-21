(function(win) {
	
	var Terms = function(_terms) {
		this.courses = mapTerms(_terms);
		this.terms = Object.keys(this.courses).sort(sortTerms);
	};
	
	function mapCourses(courses) {
		return courses.map(function(el, i) {
			
			var accessUri = el.accessUri
				, activateUri = el.activateUri
				, cvUri = el.cvUri
				, disableUri = el.disableUri
				, enableUri = el.enableUri
				, unmergeUri = el.unmergeUri;
			
			el.accessUri = {uiFn: 'link', elAttrs: {href: accessUri}, text: el.displayTitle};
			el.activateUri = {uiFn: 'link', elAttrs: {href: activateUri}, text: "Activate", showLoading: true};
			el.cvUri = {uiFn: 'link', elAttrs: {href: cvUri, target: "_blank" }, text: "Course Verification"};
			el.disableUri = {uiFn: 'link', elAttrs: {href: disableUri}, text: "Disable", showLoading: true};
			el.enableUri = {uiFn: 'link', elAttrs: {href: enableUri}, text: "Enable", showLoading: true};
			el.unmergeUri = {uiFn: 'link', elAttrs: {href: unmergeUri}, text: "Remove", showLoading: true};
					//prompt: "This will remove " + el.courseId + " from " + el.parent + ". This action may delete student work and grades. "
					//+ "Do you wish to continue?"};
			
			el.availableAction = !el.isRoster && el.isInstructor && !el.isChild
				? el.isAvailable 
					? el.disableUri
					: el.enableUri
				: "";
			
			if (el.isRoster || el.isChild) 
				el.accessUri = {uiFn: "text", tdAttrs: {class: el.isChild ? "child" : ""}, text: el.displayTitle};
			
			if (el.isOnline && (el.isInstructor || el.isSecondaryInstructor) && !el.isChild) {
       		   if(!el.isRoster) {
       			   el.action = el.cvUri;
       		   } else {
       			   el.action = "*";
       		   }
		   } else if (el.isInstructor && el.isChild) {
			   if (!/onlin-/i.test(el.parent)) {
		  		   el.action = el.unmergeUri;
			   } else {
				   el.action = "*";
			   }
		   } else if (el.isInstructor) {
			   if (el.isRoster) {
				   el.action = el.activateUri;
			   } else {
				   el.action = [function(course) {
					   var ctrl = this.ctrl;
					   var vm = this.vm;
					   
					   return m("a", {
         				    href: "#" + course.courseId,
         					onclick: vm.showRosters.bind(vm, course.courseId)
         			   }, "Merge");
				   }];
			   }
		   } else {
			   el.action = "";
		   }
			
			el.children = el.children && el.children.length
				? mapCourses(el.children)
				: [];
			
			return el;
		});
	};
	
	function mapTerms(_terms) {
		var keys = Object.keys(_terms).sort(sortTerms);
		var terms = {};
		terms['All'] = [];
		var courses;
		
		for(var i = 0, l = keys.length; i < l; i++) {
			courses = mapCourses(_terms[keys[i]]);
			terms[keys[i]] = courses;
			terms['All'] = terms['All'].concat(courses);
		}
		
		return terms;
	};
	
	function sortTerms(a, b) {
		a = a.split(' ');
		b = b.split(' ');
		if(!isNaN(a[0]) && isNaN(b[0])) {
			return -1;
		} else if (isNaN(a[0]) && !isNaN(b[0])) {
			return 1;
		} else if(a[0].localeCompare(b[0]) == 0 && a.length > 1 && b.length > 1) {
			return sortSeason(a[1], b[1]);
		} else {
			switch (a[0].localeCompare(b[0])) {
			case -1:
				return 1;
				break;
			case 1:
				return -1;
				break;
			default:
				return 0;
			} 
		}
	};
	
	function sortSeason(a, b) {
		if (a.toLowerCase() == 'fall') {
			return -1;
		} else if (b.toLowerCase() == 'fall') {
			return 1;
		} else {
			switch (a.localeCompare(b)) {
			case -1:
				return 1;
				break;
			case 1:
				return -1;
				break;
			default:
				return 0;
			}
		}
	};
	
	win.Terms = Terms;
}(window));
