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

<script>
(function(win, doc){
	if(win.addEventListener)return;		//No need to polyfill

	function docHijack(p){var old = doc[p];doc[p] = function(v){return addListen(old(v))}}
	function addEvent(on, fn, self){
		return (self = this).attachEvent('on' + on, function(e){
			var e = e || win.event;
			e.preventDefault  = e.preventDefault  || function(){e.returnValue = false}
			e.stopPropagation = e.stopPropagation || function(){e.cancelBubble = true}
			fn.call(self, e);
		});
	}
	function addListen(obj, i){
		if(i = obj.length)while(i--)obj[i].addEventListener = addEvent;
		else obj.addEventListener = addEvent;
		return obj;
	}

	addListen([doc, win]);
	if('Element' in win)win.Element.prototype.addEventListener = addEvent;			//IE8
	else{																			//IE < 8
		doc.attachEvent('onreadystatechange', function(){addListen(doc.all)});		//Make sure we also init at domReady
		docHijack('getElementsByTagName');
		docHijack('getElementById');
		docHijack('createElement');
		addListen(doc.all);	
	}
})(window, document);
if (!Function.prototype.bind) {
	  Function.prototype.bind = function(oThis) {
	    if (typeof this !== 'function') {
	      // closest thing possible to the ECMAScript 5
	      // internal IsCallable function
	      throw new TypeError('Function.prototype.bind - what is trying to be bound is not callable');
	    }

	    var aArgs   = Array.prototype.slice.call(arguments, 1),
	        fToBind = this,
	        fNOP    = function() {},
	        fBound  = function() {
	          return fToBind.apply(this instanceof fNOP && oThis
	                 ? this
	                 : oThis,
	                 aArgs.concat(Array.prototype.slice.call(arguments)));
	        };

	    fNOP.prototype = this.prototype;
	    fBound.prototype = new fNOP();

	    return fBound;
	  };
	}
if (!Array.prototype.filter) {
	  Array.prototype.filter = function(fun/*, thisArg*/) {
	    'use strict';

	    if (this === void 0 || this === null) {
	      throw new TypeError();
	    }

	    var t = Object(this);
	    var len = t.length >>> 0;
	    if (typeof fun !== 'function') {
	      throw new TypeError();
	    }

	    var res = [];
	    var thisArg = arguments.length >= 2 ? arguments[1] : void 0;
	    for (var i = 0; i < len; i++) {
	      if (i in t) {
	        var val = t[i];

	        // NOTE: Technically this should Object.defineProperty at
	        //       the next index, as push can be affected by
	        //       properties on Object.prototype and Array.prototype.
	        //       But that method's new, and collisions should be
	        //       rare, so use the more-compatible alternative.
	        if (fun.call(thisArg, val, i, t)) {
	          res.push(val);
	        }
	      }
	    }

	    return res;
	  };
	}
</script>

<script type="text/javascript" src='<%= moduleBasePath + "jquery.js" %>'></script>
<script type="text/javascript" src='<%= moduleBasePath + "opentip.js" %>'></script>
<script type="text/javascript" src='<%= moduleBasePath + "mithril.js" %>'></script>

<style>
	.CSSTableGenerator tr td.child {
		background-image: url('<%= moduleBasePath + "xchild.png" %>');
	}
	#CCMPage2, #loadingRequest {
		display: none;
	}
</style>

<%--<bbNG:pageHeader> 
 <bbNG:pageTitleBar title="Course Module"/> 
</bbNG:pageHeader> --%>

<bbNG:includedPage ctxId="bbContext">

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
			<strong>* Global Campus courses are managed through the Course Verification process and enabled by Global Campus before the official start date.</strong>
		</div> <!-- END Manage Course -->
	</div><!-- End CCMSPace -->

	<!-- Active Student COURSE LIST -->
	<div class="CCMSpace">		
		<h6>Courses in which you are enrolled as a student:</h6>
		<ul class="portletList-img courseListing">
			<% if (activeStudentMemberships.size() == 0) { %>
			<li>Sorry, you are not enrolled in any active courses as a student.</li>
			<% } else { 
				for(int i=0, l = activeStudentMemberships.size(); i < l; i++) {
					CMWrapper cm = activeStudentMemberships.get(i);
			%>
				<li><a href="<%= courseBasePath + cm.course.coursePkId %>"><%= cm.course.title + " (" + cm.course.courseId + ")" %></a></li>	
			<%	}
			} %>
		</ul>
	</div><!-- End CCMSpace -->
	
</div><!-- End Page1 -->

<div id="CCMPage2">
	<div id="rosterContainer" class="CCMSpace">
	<!-- Container where the available rosters will display for merges -->
		
	</div>
	<strong>* Global Campus courses are managed through the Course Verification process and enabled by Global Campus before the official start date.</strong>
</div><!-- End Page2 -->

<div id="loadingRequest">
	<div class="CCMSpace">
		<h6>Loading...</h6>
		<p></p>
	</div>
</div>

<div id="rosterTemplate" style="display: none;">
		<a id="back" href="#">back</a>
		<h6>Parent Course Space</h6>
		<br/>
		<div id="parentCourse">{{:parentCourse}}</div>
		<br/>
		<h6>Select rosters to include</h6>
		<ul id="mergeList" class="portletList-img courseListing">
		{{for rosters}}
			<li>
			{{for course}}
				{{if !isOnline}}
					<input type='checkbox' value='{{:courseId}}' />
				{{else}}
					*
				{{/if}}
				{{:displayTitle}}
			{{/for}}
			</li>
		{{/for}}
		</ul>
		<bbNG:button id="createCourseSection" url="#" label="Save" />
</div>

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
		var args = Array.prototype.slice.call(arguments, 1);
		var loading = args.filter(function(el) {
			return typeof window[el] == 'undefined';
		});
		function run() {
			ready.apply(this, [cb].concat(args));
		}

		/in/.test(document.readyState) || loading.length
		? setTimeout(run.bind(this), 9)
		: cb();
	}
	
  	/* function ready(cb) {
  		/in/.test(document.readyState) || typeof Opentip == 'undefined' || typeof m == 'undefined' || typeof jQuery == 'undefined' // in = loadINg
        ? setTimeout('ready('+cb+')', 9)
        : cb();
	} */

	function  startOpenTip() {
		var availabilityMessage = "Enable/Disable your course for student viewing.";
		var actionMessage = "<strong style='text-decoration: underline;'>Activate</strong>: Creates a course space for the corresponding roster. <br/>"
			+ "<strong style='text-decoration: underline;'>Remove</strong>: Pull the roster enrollments out of the parent course space. <br/>"
			+ "<strong style='text-decoration: underline;'>Course Verification</strong>: Manage Global Campus courses.<br />"
			+ "<strong style='text-decoration: underline;'>Merge</strong>: Add roster sections to the selected course space.";
		
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
	}
</script>
<script type="text/javascript">
	var moduleBasePath = "<%= moduleBasePath %>";
	var parentCourseId = '';
	var isInstructor = <%= isInstructor %>;
	var instCourses = <%= jsonInstTerms %>;	
	var rosters = <%= jsonRosters %>;
	
	function showLoading(evt) {
        document.getElementById("CCMPage1").style.display = "none";
        document.getElementById("CCMPage2").style.display = "none";
        document.getElementById("loadingRequest").style.display = "block";
	}
	
	jQuery(document).on('click', '#back', function() {
        document.getElementById("CCMPage2").style.display = "none";
		document.getElementById("CCMPage1").style.display = "block";
	});
	
	jQuery(document).on('click', '#createCourseSection', function(evt){
		evt.stopPropagation();
		evt.preventDefault();
		
		showLoading();
		
		var uri = moduleBasePath + 'merge.jsp?parent-course=' + parentCourseId + "&child-courses=";
		var childCourses = document.querySelectorAll('#mergeList input:checked');
		[].forEach.call(childCourses, function(el, i) {
			var prefix = i > 0 ? ',' : '';
			uri += prefix + el.getAttribute("value");
		});
		window.location.replace(uri);
	});
	
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
	}
	
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
	}
	
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
	}
	
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
	}
	
	var Terms = {};
	
	Terms.listAll = function() {
		//return convertFromJson(instCourses);
		return mapTerms(instCourses.terms);
	}
	
	Terms.listRosters = function() {
		//return convertFromJson(rosters);
		return mapTerms(rosters.terms);
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
			return m('div', {id: 'filter'}, [m('input', {
			    oninput: m.withAttr('value', vm.searchTerm),
			    placeholder: 'search',
			    value: vm.searchTerm()
			  })
			]);
		}
	});

	var selectedTerm = new Module({
		controller: function() {
			this.terms = Object.keys(Terms.listAll()).sort(sortTerms); //.reverse();
			//if (this.terms[0] == "Continuous" || this.terms[0] == 'All Courses') {
			//	this.terms.push(this.terms.shift());
			//} 
			//if (this.terms[0] == "Continuous" || this.terms[0] == 'All Courses') {
			//	this.terms.push(this.terms.shift());
			//} 
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
			this.showChildren = m.prop(true);
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
			var $ = jQuery;
			this.selectedTerm = m.prop("2015 Spring");
			this.itemsPerPage = m.prop(Infinity);
			this.selectedPage = m.prop(1);
			this.showChildren = m.prop(false);
			
			this.showRosters = function(parentCourse) {
				var data = {};
				var rosters = Terms.listRosters();
				var template = $.templates('#rosterTemplate');
				var lecReg = /-lec$/ig;
				var labReg = /-lab$/ig;
				var rosterReg;
				
				if (lecReg.test(parentCourse)) {
					rosterReg = lecReg.test.bind(lecReg);
				} else if (labReg.test(parentCourse)) {
					rosterReg = labReg.test.bind(labReg);
				} else {
					rosterReg = function() { return true; }	
				}				
				
				rosters = (rosters[this.selectedTerm()] || []).filter(function(el) {
					return rosterReg(el.course.courseId);
				});
				
				data.parentCourse = parentCourse;
				parentCourseId = parentCourse;
				data.rosters = rosters;
				var html = template.render(data);
				$('#rosterContainer').html(html);
				$('#CCMPage1').css('display', 'none');
				$('#CCMPage2').css('display', 'block');
			};
		},
		
		view: function() {
			var ctrl = this.ctrl;
			var vm = this.vm;
			return m("table", {class: 'four'}, [m("tr", [
		        m("td", "Enrl"),
		        m("td", "Course Title (Course ID)"),
		        m("td", {id: "availabilityTT"}, [
		             "Availability ",
		             m("img", {
		            	 height: 20,
		            	 src: moduleBasePath + 'question_mark.png'
		             })
		        ]),
		        m("td", {id: "actionTT"}, [
		             "Action ",
		             m('img', {
		            	 height: 20,
		            	 src: moduleBasePath + 'question_mark.png'
		             })
		        ])
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
		          			   return m("a", {href: c.disableUri, onclick: showLoading}, "Disable");
		          		   } else {
		          			   return m("a", {href: c.enableUri, onclick: showLoading}, "Enable");
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
		          		   if (!/onlin-/ig.test(c.parent)) {
			          		   return m("a", {href: c.unmergeUri}, "Remove");
		          		   } else {
		          			   return "*";
		          		   }
		          	   } else if (c.isInstructor) {
		          		   if (c.isRoster) {
		          			   return m("a", {href: c.activateUri, onclick: showLoading}, "Activate");
		          		   } else {
		          			   return m("a", {
		          				    href: "#" + c.courseId,
		          					onclick: vm.showRosters.bind(vm, c.courseId)
		          			   }, "Merge");
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

  	ready(function() {
  		console.log('dom loaded');
	  	m.module(document.getElementById('instCourses'), app.init());
		startOpenTip();
  	}, "Opentip", "m", "jQuery");

  	//typeof Opentip == 'undefined' || typeof m == 'undefined' || typeof jQuery == 'undefined' // in = loadINg
</script>

</bbNG:includedPage>