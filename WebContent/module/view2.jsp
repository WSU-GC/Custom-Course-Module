<%@page import="helper.buildingblock.BuildingBlockHelper"%>
<%@page import="com.google.gson.Gson"%>
<%@page import="com.google.gson.GsonBuilder" %>
<%@page import="edu.wsu.*"%>
<%@page import="blackboard.platform.plugin.PlugInUtil" %>
<%@page import="blackboard.data.user.*" %>
<%@page import="java.util.ArrayList" %>
<%@page import="java.util.List" %>
<%@page import="java.util.Properties" %>

<%@ taglib uri="/bbNG" prefix="bbNG"%>

<%
String moduleBasePath = PlugInUtil.getUri("wsu", "wsu-custom-course-module", "") + "module/";
%>

<link rel="stylesheet" type="text/css" href='<%= BuildingBlockHelper.getBaseUrl("module/css/style.css") %>' />
<link rel="stylesheet" type="text/css" href='<%= BuildingBlockHelper.getBaseUrl("module/css/opentip.css") %>' />

<%
boolean isDev = false;
//Properties buildProps = BuildingBlockHelper.loadBuildProperties();
String version = "2.0.4";

if (isDev) { %>

<script type="text/javascript" src='<%= BuildingBlockHelper.getBaseUrl("module/js/polyfill.js") %>'></script>
<script type="text/javascript" src='<%= BuildingBlockHelper.getBaseUrl("module/js/mithril.js") %>'></script>
<script type="text/javascript" src='<%= BuildingBlockHelper.getBaseUrl("module/js/module.js") %>'></script>
<script type="text/javascript" src='<%= BuildingBlockHelper.getBaseUrl("module/js/jquery.js") %>'></script>
<script type="text/javascript" src='<%= BuildingBlockHelper.getBaseUrl("module/js/opentip.js") %>'></script>
<script type="text/javascript" src='<%= BuildingBlockHelper.getBaseUrl("module/js/term-model.js") %>'></script>

<% } else { %>

<script type="text/javascript" src='<%= BuildingBlockHelper.getBaseUrl() + "build/concat-" + version + ".js" %>'></script>

<% } %>



<script>

	/* 
	* Dynamic script loader. This entire page is loaded by Bb at page load, after the initial DOMLoaded event has fired.
	* Therefore you cannot depend on $(function() { ... }) or $(document).ready(...) for resource loading or executing on page load events.
	* The function defined below allows you to explicitly listen for when specific globals defined on window have finished loading
	* example: ready(function() {// stuff to execute when globals are ready}, "jQuery", "underscore", ...OTHER GLOBALS TO LISTEN FOR);
	* It will run for a few seconds before consoling an error and moving on. This must be defined in page as we cannot dynamically load the dynamic loader.
	*/
	function load(resource) {
		var script = document.createElement("script");
		script.setAttribute("type", "text/javascript");
		script.setAttribute("src", resource);
		document.head.appendChild(script);
	}
	
	
	function ready(cb) {
		//this.__count = 0;
		window.__COUNT_LOADING_ATTEMPTS = window.__COUNT_LOADING_ATTEMPTS || 0;
		var args = Array.prototype.slice.call(arguments, 1);
		
		// Polyfill for array.filter
		var filter = Array.prototype.filter || function(fn) {
			var array = this;
			var l = array.length;
			var res = [];
			
			for(var i = 0; i < l; i++) {
				if(fn.call(this, array[i], i, array))
					res = res.push(array[i]);
			}
			
			return res;
		}
		
		var loading = filter.call(args, function(el) {
			return typeof window[el] == 'undefined';
		});
		
		function run() {
			window.__COUNT_LOADING_ATTEMPTS++;
			if (window.__COUNT_LOADING_ATTEMPTS > 1000) {
				// Unable to load all resources. log error and move on.
				console.error("Error: page failed to load all resources: %s", loading.toString());
				window.__COUNT_LOADING_ATTEMPTS = 0;
				cb();
			} else { 
				ready.apply(this, [cb].concat(args));
			}
		}
		
		// polyfill for function binding.
		run._bind = Function.prototype.bind || function(bThis) {
			var args = Array.prototype.slice.call(arguments, 1);
			var fn = this;
			return function() {
				var _args = args.concat(Array.prototype.slice.call(arguments));
				return fn.apply(bThis, _args);
			}
		};
	
		/in/.test(document.readyState) || loading.length
			? setTimeout(run._bind(this), 9)
			: (function() {cb(); window.__COUNT_LOADING_ATTEMPTS = 0; }());
		
		/**
		* None of the polyfills in this function override native prototype chains/functionality
		* polyfill.js provides more robust polyfill functions that do extend native prototype chains.
		*/
	}

</script>

<style>
	.CSSTableGenerator tr td.child {
		background-image: url('<%= BuildingBlockHelper.getBaseUrl("module/images/xchild.png") %>');
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
			
			<!-- ***************************************************************
				 * Instructor Courses
				 * div where CCM instructor table is loaded  
			******************************************************************** -->
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


<script type="text/javascript">
	var isDev = <%= isDev %>
		, moduleBasePath = "<%= moduleBasePath %>"
		, courseBasePath = "<%= courseBasePath %>"
		, parentCourseId = ''
		, isInstructor = <%= isInstructor %>
		, instCourses = <%= jsonInstTerms %>
		, rosters = <%= jsonRosters %>;
	

	function main() {
		
		window.courseClone = Object.assign({}, instCourses);
		
		function merge(parentCourseId) {
			var uri = "<%= BuildingBlockHelper.getBaseUrl() %>" + "Merge?parent-course=" + parentCourseId + "&child-courses=";
			var childCourses = document.querySelectorAll('#mergeList input:checked');
			[].forEach.call(childCourses, function(el, i) {
				var prefix = i > 0 ? ',' : '';
				uri += prefix + el.getAttribute("value");
			});
			
			window.location.replace(uri);
		}
		
		var app = new Module({
			controller: function() {
				var self = this;
				// Model
				var courses = new Terms(instCourses.terms);
				var localRosterList = new Terms(window.rosters.terms);
				
				var filterCourses = function filterCourses(el, ind) {
					if (el.isChild) return false;
					
					function filterFn(item, ind) {
						var course = item;
						var searchVal = filter.vm.searchTerm().toLowerCase();
						var page = tableModule.vm.selectedPage() - 1;
						var pageSize = tableModule.vm.itemsPerPage();
						
						if (searchVal == "")
							if (ind < page || ind >= page + pageSize) return false;
						
						var name = course.title.toLowerCase();
						var id = course.courseId.toLowerCase();
						var children = course.children.filter(filterFn);
						return name.indexOf(searchVal) > -1 || id.indexOf(searchVal) > -1 || children.length;
					}
					
					return filterFn(el, ind);
				};
				
				this.loading = m.prop(false);
				this.loadingModule = loadingModule.init();
				this.showRosters = m.prop(false);
				
				this.filter = filter.init();
				
				this.selectedTerm = selectedTerm.init({
					terms: courses.terms
				});
				
				this.rosterList = m.prop(localRosterList.courses);
				this.currentRosters = m.prop(localRosterList.courses[selectedTerm.vm.selectedTerm()]);
				this.showChildren = showChildren.init();
				this.parentCourseId = m.prop("");
				
				this.table = tableModule.init({
					filter: filterCourses,
					terms: courses.courses,
					allRosters: self.rosterList,
					rosters: self.currentRosters,
					parentCourseId: self.parentCourseId,
					loading: self.loading
				}, {
					showChildren: showChildren.vm.showChildren,
					selectedTerm: selectedTerm.vm.selectedTerm,
					showRosterList: self.showRosters
				});
				
				this.rosterModule = rosterModule.init({
					rosters: self.currentRosters,
					showRosters: self.showRosters,
					parentCourse: self.parentCourseId,
					selectedTerm: selectedTerm.vm.selectedTerm,
					loading: self.loading
				}, {
					save: merge
				});
				
			},
			
			viewModel: function() {
				
			},
			
			view: function() {
				var ctrl = this.ctrl;
				return m("div", (function() {
					if (ctrl.showRosters()) {
						return ctrl.rosterModule.view();
					} else if (ctrl.loading()) {
						return ctrl.loadingModule.view();
					} else {
				  		return [m('#appHeader', [
							ctrl.selectedTerm.view(),
						  	ctrl.showChildren.view(),
						  	ctrl.filter.view(),
						  	m('br', {class: 'clear'})
					  	]), m('.CSSTableGenerator', [
						 	ctrl.table.view()
					  	])];
					}
				}()));
			}
		}); // END APP
		
		window.app = app;
	} // END MAIN
	

	ready(function() {
		if (isDev) {
			load('<%= BuildingBlockHelper.getBaseUrl("module/js/init-opentip.js") %>');
			load('<%= BuildingBlockHelper.getBaseUrl("module/js/filter-module.js") %>');
			load('<%= BuildingBlockHelper.getBaseUrl("module/js/roster-module.js") %>');
			load('<%= BuildingBlockHelper.getBaseUrl("module/js/loading-module.js") %>');
			load('<%= BuildingBlockHelper.getBaseUrl("module/js/ccm-table-module.js") %>');
			load('<%= BuildingBlockHelper.getBaseUrl("module/js/selectedterm-module.js") %>');
			load('<%= BuildingBlockHelper.getBaseUrl("module/js/showchildren-module.js") %>');
			load('<%= BuildingBlockHelper.getBaseUrl("module/js/app.js") %>');
		}
		
		ready(function() {
			console.log('dom loaded');
			main();
			m.module(document.getElementById('instCourses'), app.init());
			//startOpenTip();
		}, "filter", "selectedTerm", "showChildren", "rosterModule", "loadingModule", "tableModule", "startOpenTip");
		
	}, "isPolyFilled", "m", "Module", "Opentip", "jQuery", "Terms");

</script>

</bbNG:includedPage>