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
		<div id="instCourses" class="CSSTableGenerator">
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
	
	var courses = {};
	
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
		course.isInstructor = role == "instructor" || role == "pcb";
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
	
	courses.Terms = function() {
		return convertFromJson(instCourses);
	}
	
	courses.Rosters = function() {
		return convertFromJson(rosters);
	}
	
	courses.vm = new function() {
		var vm = {};
		vm.init = function() {
			vm.terms = new courses.Terms();
			//vm.rosters = new courses.Rosters();
			vm.termKeys = Object.keys(vm.terms).sort(function(a,b) {
				return a.localeCompare(b);
			});
			
			vm.selectedTermKey = m.prop(vm.termKeys[0]);
			
			vm.selectedTerm = m.prop(vm.terms[vm.selectedTermKey()]);
			
			vm.changeTerm = function(newTermKey) {
				vm.selectedTermKey(newTermKey);
				vm.selectedTerm(vm.terms[vm.selectedTermKey()]);
			};
		}
		return vm;
	}
	
	courses.controller = function() {
		courses.vm.init();
	}
	
	courses.view = function() {
		return m("div", [
			courses.vm.termKeys.map(function(termKey) {
				return m("a", {onclick: courses.vm.changeTerm.bind(courses.vm, termKey), 
					href: "#",
					class: termKey == courses.vm.selectedTermKey()
					? "active termTab"
					: "termTab"}, termKey);
			}),
			
			m("table", [m("tr", [
		        m("td", "Enrl"),
		        m("td", "Course Title (Course ID)"),
		        m("td", {id: "availabilityTT"}, ["Availability", m("img", {height: 20, src: moduleBasePath + "question_mark.png"})]),
		        m("td", {id: "actionTT"}, ["Action", m("img", {height: 20, src: moduleBasePath + "question_mark.png"})])
	        ]),
	      	courses.vm.selectedTerm().map(function(cm) {
		   	   if (cm.course.isChild) return;
		   	   var co = cm.course;
		   	   var cc = co.children.length
		   	   		? [co].concat(co.children)
		   	   		: [co];
		   	   return cc.map(function(c) {
		    	   return m("tr", [
	                   m("td", c.enrl),
	                   m("td", {class: c.isChild ? "child": ""}, (function() {
                	   		return c.isRoster
		                	   	? c.displayTitle
	              	   			: [m("a", {href: c.accessUri}, c.displayTitle)];
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
	      ])
        ]);
		
	};

	document.addEventListener("DOMContentLoaded", function() {
		m.module(document.getElementById("instCourses"), courses);
		startOpenTip();
	});
		
</script>

<%-- </bbNG:includedPage> --%>

</bbNG:learningSystemPage>