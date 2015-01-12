<%@page import="com.google.gson.Gson"%>
<%@page import="com.google.gson.GsonBuilder" %>
<%@page import="edu.wsu.*"%>
<%@page import="blackboard.platform.plugin.PlugInUtil" %>
<%@page import="blackboard.data.user.*" %>
<%@page import="java.util.ArrayList" %>
<%@page import="java.util.List" %>

<%@ taglib uri="/bbNG" prefix="bbNG"%>

<%
String moduleBasePath = PlugInUtil.getUri("wsu", "wsu-custom-course-module", "") + "module/";
%>

<link rel="stylesheet" type="text/css" href='<%= moduleBasePath + "style.css" %>' />
<link rel="stylesheet" type="text/css" href='<%= moduleBasePath + "opentip.css" %>' />

<style>
	.CSSTableGenerator tr td.child {
		background-image: url('<%= moduleBasePath + "xchild.png" %>');
	}
	#CCMPage2, #loadingRequest {
		display: none;
	}
</style>

<bbNG:learningSystemPage  ctxId="bbContext">

<bbNG:pageHeader> 
 <bbNG:pageTitleBar title="Course Module"/> 
</bbNG:pageHeader>

<%-- <bbNG:includedPage ctxId="bbContext"> --%>


<%

User user = bbContext.getUser();
String courseBasePath = "/webapps/blackboard/execute/launcher?type=Course&url=&id=";
boolean isInstructor = false;

List<CMWrapper> userMemberships = CMWrapper.loadCMWrappersByUser(user);
CMWrapper.sort(userMemberships);

Gson gson = new GsonBuilder()
	.registerTypeAdapter(CMWrapper.class, new CMWrapperSerializer()).create();

List<CMWrapper> studentMemberships = CMWrapper.filterCMWrappersByRole(userMemberships, "STUDENT", true);
List<CMWrapper> activeStudentMemberships = CMWrapper.filterCMWrappersByAvailability(studentMemberships, true);

TermWrapper activeStudentTerms = new TermWrapper(activeStudentMemberships);

List<CMWrapper> instMemberships = CMWrapper.filterCMWrappersByRole(userMemberships, "STUDENT", false);

TermWrapper instTerms = new TermWrapper(instMemberships);

List<CMWrapper> rosterWrapper = CMWrapper.filterIsolatedRosters(instMemberships);

TermWrapper rosterTerms = new TermWrapper(rosterWrapper);

String jsonInstTerms = gson.toJson(instTerms);
//String jsonInstTerms = new Gson().toJson(instTerms.terms);
String jsonRosters = gson.toJson(rosterTerms);

%>


<% 
if(instMemberships.size() > 0) { 
	isInstructor = true;		
%>
	<style> #manageCourses { display: block; } </style>
<% } %>

<div id="CCMPage1">
	<div class="CCMSpace">
		<h6>Courses to which you are assigned as the primary instructor:</h6>
		
		<% if(instMemberships.size() == 0) { %>
			<!-- <p>You are not enrolled in any course as an instructor. If you believe this is a mistake please work with your 
				department to ensure you are assigned to instruct a course or contact <a href="mailto:online.registrar@wsu.edu">online.registrar@wsu.edu</a></p> -->
		<% } %>
	
		<div id="manageCourses">
	
		<p>New processes allow you to create and manage your Bb Learn course spaces in real time 
			- no waiting on support staff to respond to your request.  If you require assistance 
			just email <a href="mailto:online.registrar@wsu.edu">online.registrar@wsu.edu</a>.</p>
			
		<ol>
			<li>
				Select <strong>ACTIVATE</strong> next to the course ID to create your new course space, manage and 
				edit content. When the course ID is an active hyperlink, the course space has been activated.
			</li>
			<li>If needed, <strong>MERGE</strong> course spaces so that you can manage just one course space 
				for multiple sections.- <strong><a target="_blank" href="http://elearning.wsu.edu/pdf/bblearnmanagingcoursestutorial.pdf">Instructions</a></strong> 
			</li>
			<li>
				To <strong>COPY</strong> an existing Bb course into a newly activated one. 
				<strong><a target="_blank" href="http://elearning.wsu.edu/pdf/copyingcourseswithinblackboard.pdf">Instructions</a></strong>
			</li>
		</ol>
		
		<!-- Instructor Courses -->
		<div id="instCourses">
		</div>

		</div>
	</div><!-- END Manage Course -->

	<!-- Active Student COURSE LIST -->
	<div class="CCMSpace">		
		<h6>Courses in which you are enrolled as a student:</h6>
		
		<!-- Student module -->
		
	</div>
	
</div><!-- End Page1 -->

<div id="CCMPage2">
	<div class="CCMSpace">
		
		<!-- Merging section -->
		
	</div>
	<strong>* Global Campus courses are managed through the Course Verification process and enabled by Global Campus before the official start date.</strong>
</div><!-- End Page2 -->

<div id="loadingRequest">
	<div class="CCMSpace">
		<h6>Loading...</h6>
		<p></p>
	</div>
</div>

<script type="text/javascript" src='<%= moduleBasePath + "opentip.js" %>'></script>
<script type="text/javascript" src='<%= moduleBasePath + "mithril.js" %>'></script>
<script type="text/javascript">
	if (!Object.assign) {
	  Object.defineProperty(Object, "assign", {
	    enumerable: false,
	    configurable: true,
	    writable: true,
	    value: function(target, firstSource) {
	      "use strict";
	      if (target === undefined || target === null)
	        throw new TypeError("Cannot convert first argument to object");
	      var to = Object(target);
	      for (var i = 1; i < arguments.length; i++) {
	        var nextSource = arguments[i];
	        if (nextSource === undefined || nextSource === null) continue;
	        var keysArray = Object.keys(Object(nextSource));
	        for (var nextIndex = 0, len = keysArray.length; nextIndex < len; nextIndex++) {
	          var nextKey = keysArray[nextIndex];
	          var desc = Object.getOwnPropertyDescriptor(nextSource, nextKey);
	          if (desc !== undefined && desc.enumerable) to[nextKey] = nextSource[nextKey];
	        }
	      }
	      return to;
	    }
	  });
	}

	function ready(cb) {
		typeof Opentip == 'undefined' // in = loadINg
        ? setTimeout('ready('+cb+')', 9)
        : cb();
	}

	function  startOpenTip() {
		ready(function() {
			var availabilityMessage = "Enable/Disable your course for student viewing.";
			var actionMessage = "<strong style='text-decoration: underline;'>Activate</strong>: Creates a course space for the corresponding roster. <br/>"
				+ "<strong style='text-decoration: underline;'>Remove</strong>: Pull the roster enrollments out of the parent course space. <br/>"
				+ "<strong style='text-decoration: underline;'>Course Verification</strong>: Manage Global Campus courses.";
			
			Opentip.styles.extendedAlert = {
					extends: "alert",
					background: "#981e32",
					color: "#ffffff"
			}
			
			var options = {
				target: true,
				tipJoint: "bottom",
				style: "extendedAlert"
			};
			new Opentip("#availabilityTT", availabilityMessage, options);
			new Opentip("#actionTT", actionMessage, options);
		});
	}
</script>
<script type="text/javascript">
	var moduleBasePath = "<%= moduleBasePath %>";
	var parentCourseId = '';
	var isInstructor = <%= isInstructor %>;
	var instCourses = <%= jsonInstTerms %>;	
	var rosters = <%= jsonRosters %>;
	
	function convertFromJson(obj) {
		var terms = obj.terms;
		var termKeys = Object.keys(terms);
		
		termKeys.forEach(function(t) {
			terms[t] = terms[t].map(function(courses) {
				var role = courses.role.toLowerCase();
				courses.course = JSON.parse(courses.course);
				courses.course = courseInfo(role, courses.course);
				return courses;
			});
		});
		
		return terms;
	}
	
	function courseInfo(role, course, parent) {
		course.children = JSON.parse(course.children);
		course.children = course.children.map(function(c) {
			return courseInfo(role, c, course);
		});
		course.isInstructor = role == "instructor" || role == "pcb" || "support";
		course.isSecondaryInstructor = role == "si" || role == "scb";
		course.displayTitle = course.title + " (" + course.courseId + ")";
		course.cvUri = "http://cdpemoss.wsu.edu/_layouts/CDPE/CourseVerification/Version08/Summary.aspx?pk1=" + course.courseId;
		course.enableUri = moduleBasePath + "enable.jsp?course-id=" + course.courseId;
		course.disableUri = moduleBasePath + "disable.jsp?course-id=" + course.courseId;
		course.activateUri = moduleBasePath + "activate.jsp?course-id=" 
			+ course.courseId + "&title=" + course.title;
		course.accessUri = "/webapps/blackboard/execute/launcher?type=Course&url=&id=" + course.coursePkId;
		course.unmergeUri = parent 
			? moduleBasePath + "remove.jsp?parent-course=" + parent.courseId + "&child-course=" + course.courseId
			: "";
		return course;
	}
	
	var Terms = {};
	
	Terms.listAll = function() {
		//return convertFromJson(instCourses);
		return instCourses.terms;
	}
	
	Terms.listRosters = function() {
		//return convertFromJson(rosters);
	}
	
	var Module = function(m) {
		this._m = m;
		this.vm = {};
		this.ctrl = {};
		this.controller = controller.bind(this);
		this.view = this._m.view.bind(this);
		
		function controller () {
			this._m.controller.call(this.ctrl);
			var ctrl = this.ctrl;
			this.controller = function () {
				return ctrl;
			};
		};
	};

	Module.prototype.controllerInit = function(options) {
		var merge = function merge(opts) {
			if (opts) this.ctrl = Object.assign(this.ctrl, opts);
		}.bind(this);
		
		this.controller();
		merge(options);

		this.controllerInit = merge;
		return this;
	};

	Module.prototype.vmInit = function(options) {
		var merge = function merge(opts) {
			if (opts) this.vm = Object.assign(this.vm, opts);
		}.bind(this);
		
		this._m.viewModel.call(this.vm, this.ctrl);
		merge(options);

		this.vmInit = merge;
		return this;
	};

	Module.prototype.init = function(ctrlOptions, vmOptions) {
		this.controllerInit.call(this, ctrlOptions);
		this.vmInit.call(this, vmOptions);
		return this;
	};

	var filter = new Module({
		controller: function() {
					
		},
		
		viewModel: function() {
			this.searchTerm = m.prop("");
		},
		
		view: function() {
			var ctrl = this.ctrl;
			var vm = this.vm;
			return m('input', {
			    oninput: m.withAttr('value', vm.searchTerm),
			    placeholder: 'search',
			    value: vm.searchTerm()
			  });
		}
	});

	var selectedTerm = new Module({
		controller: function() {
			this.terms = Object.keys(Terms.listAll()).sort().reverse();
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

	var showChildren = new Module({
		controller: function() {
			
		},
		
		viewModel: function() {
			this.showChildren = m.prop(false);
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

	var table = new Module({
		controller: function() {
			this.terms = new Terms.listAll();
			this.filter = function(item) {
				return true;
			};
		},
		
		viewModel: function() {
			this.selectedTerm = m.prop("2015 Spring");
			this.itemsPerPage = m.prop(Infinity);
			this.selectedPage = m.prop(1);
			this.showChildren = m.prop(false);
		},
		
		view: function() {
			var ctrl = this.ctrl;
			var vm = this.vm;
			return m("table", [m("tr", [
		        m("td", "Enrl"),
		        m("td", "Course Title (Course ID)"),
		        m("td", {id: "availabilityTT"}, "Availability"),
		        m("td", {id: "actionTT"}, "Action")
		    ]),
		  	ctrl.terms[vm.selectedTerm()].filter(ctrl.filter).map(function(cm) {
		  		var co = cm.course;
		  		var cc = co.children.length && vm.showChildren()
			   		? [co].concat(co.children.map(function(child) {return child.course; }))
			   		: [co];
		   	   return cc.map(function(c) {
		    	   return m('tr', [
		             m('td', c.enrl),
		             m('td', {class: c.isChild ? "child" : ""}, (function() {
		            	 return c.isRoster 
		            	 ? c.displayTitle
		            	 : [m('a', {href: c.accessUri}, c.displayTitle)];
		             }())),
		             m("td", (function() {
		          	   if (!c.isRoster && c.isInstructor) {
		          		   if (c.isAvailable) {
		          			   return m("a", {href: c.disableUri}, "Disable");
		          		   } else {
		          			   return m("a", {href: c.enableUri}, "Enable");
		          		   }
		          	   }
		          	   return "";
		             }())),
		             m("td", (function() {
		          	   if (c.isOnline && (c.isInstructor || c.isSecondaryInstructor) && !c.isChild) {
		          		   if(!c.isRoster) {
		          			   return m("a", {target: "_blank", href: c.cvUri}, "Course Verification");
		          		   } else {
		          			   return "*";
		          		   }
		          	   } else if (c.isInstructor && c.isChild) {
		          		   return m("a", {href: c.unmergeUri}, "Remove");
		          	   } else if (c.isInstructor) {
		          		   if (c.isRoster) {
		          			   return m("a", {href: c.activateUri}, "Activate");
		          		   } else {
		          			   return m("a", {href: "#" + c.courseId}, "Merge");
		          		   }
		          	   }
		             }()))
		           ]);
		   		});
		      })
		  ]);
		}
	});

	var app = new Module({
		controller: function() {
			var filterCourses = function filterCourses(item, ind) {
				if (item.course.isChild) return false;
				var course = item.course;
				var searchVal = filter.vm.searchTerm().toLowerCase();
				var page = table.vm.selectedPage() - 1;
				var pageSize = table.vm.itemsPerPage();
				
				if (searchVal == "")
					if (ind < page || ind >= page + pageSize) return false;
				
				var name = course.title.toLowerCase();
				var id = course.courseId.toLowerCase();
				var children = course.children.filter(filterCourses);
				return name.indexOf(searchVal) > -1 || id.indexOf(searchVal) > -1 || children.length;
			};
			
			this.filter = filter.init();
			
			this.selectedTerm = selectedTerm.init();
			
			this.showChildren = showChildren.init();
			
			this.table = table.init({
				filter: filterCourses
			}, {
				showChildren: showChildren.vm.showChildren,
				selectedTerm: selectedTerm.vm.selectedTerm
			});
			
		},
		
		viewModel: function() {
			
		},
		
		view: function() {
			var ctrl = this.ctrl;
			return m("div", [
			  m('#appHeader', [
				ctrl.selectedTerm.view(),
			  	ctrl.showChildren.view(),
			  	ctrl.filter.view(),
			  	m('br', {class: 'clear'})
			  ]), m('.CSSTableGenerator', [
				  ctrl.table.view()
			  ])
		    ]);
		}
	});

	document.addEventListener('DOMContentLoaded', function() {
	  	//console.log('dom loaded');
	  	m.module(document.getElementById('instCourses'), app.init());
		startOpenTip();
	});
		
</script>

<%-- </bbNG:includedPage> --%>

</bbNG:learningSystemPage>