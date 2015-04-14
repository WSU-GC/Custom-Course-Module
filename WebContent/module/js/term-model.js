(function(win) {
	
	var Terms = function(_terms) {
		this.courses = mapTerms(_terms);
		this.terms = Object.keys(this.courses).sort(sortTerms);
	};
	
	function mapCourses(courses, role) {
		return courses.map(function(el, i) {
			var c = {};
			c.course = el.course || el;
			c.role = el.role || role;
			role = (role || el.role).toLowerCase();
			c.course.accessUri = "<%= courseBasePath %>" + c.course.coursePkId;
			c.course.isInstructor = role == "instructor" || role == "pcb" || role == "support" || role == "course_editor";
			c.course.isSecondaryInstructor = role == "si" || role == "scb";
			c.course.isInstructor = c.course.isInstructor || c.course.isSecondaryInstructor;
			c.course.children = mapCourses(c.course.children, c.role);
			return c;
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
	
	Terms.prototype.listAll = function() {
		//return convertFromJson(instCourses);
		return this.courses;
	};
/*	
	Terms.prototype.listRosters = function() {
		//return convertFromJson(rosters);
		return mapTerms(rosters.terms);
	};*/
	
	win.Terms = Terms;
}(window));