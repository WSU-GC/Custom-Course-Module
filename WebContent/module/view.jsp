<%@page import="edu.wsu.*"%>
<%@page import="blackboard.platform.plugin.PlugInUtil" %>
<%@page import="blackboard.data.course.*" %>
<%@page import="blackboard.data.user.*" %>
<%@page import="blackboard.persist.course.*" %>
<%@page import="java.util.HashMap" %>
<%@page import="java.util.*" %>
<%@page import="java.util.regex.*" %>
<%@page import="javax.xml.parsers.*"%>
<%@page import="java.util.Date.*"%>
<%@page import="java.text.DateFormat.*"%>
<%@page import="java.text.*"%>
<%@page import="java.lang.*"%>
<%@page import="java.util.Random.*"%>
<%@page import="java.lang.Thread.*"%>
<%@page import="java.util.Calendar.*"%>
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

<bbNG:includedPage ctxId="bbContext">


<%

User user = bbContext.getUser();
boolean isInstructor = false; 
int activeCourseCount = 0;
String courseBasePath = "/webapps/blackboard/execute/launcher?type=Course&url=&id=";
List<Course> activeSections = new ArrayList<Course>();
List<Course> disabledSections = new ArrayList<Course>();
List<Course> rosters = new ArrayList<Course>();
String saipRegex = "^\\d+-\\d+-\\d+-\\w+-\\w+-\\d+$";
String onlineRegex = "(?i).+-ONLIN-.+";
String jsonRoster = "";
String jsonActiveSections = "";
String jsonDisabledSections = "";

CourseCourseManager ccManager = CourseCourseManagerFactory.getInstance();
CourseManager cManager = CourseManagerFactory.getInstance();

CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
CourseMembershipDbLoader cmLoader = CourseMembershipDbLoader.Default.getInstance();
CourseCourseDbLoader ccLoader = CourseCourseDbLoader.Default.getInstance();

List<Course> courses = courseLoader.loadByUserId(user.getId());

Collections.sort(courses, new Comparator<Course>() {
	public int compare(Course o1, Course o2) {
		return o1.getCourseId().compareTo(o2.getCourseId());
	}
});
%>

<%
	List<CMWrapper> userMemberships = CMWrapper.loadCMWrappersByUser(user);
	CMWrapper.sort(userMemberships);
	List<CMWrapper> studentMemberships = CMWrapper.filterCMWrappersByRole(userMemberships, "INSTRUCTOR", false);
	List<CMWrapper> activeStudentMemberships = CMWrapper.filterCMWrappersByAvailability(studentMemberships, true);
	List<CMWrapper> instMemberships = CMWrapper.filterCMWrappersByRole(userMemberships, "INSTRUCTOR", true);
	List<CMWrapper> rosterWrapper = CMWrapper.filterIsolatedRosters(instMemberships);
%>

<% if(instMemberships.size() > 0) { %>
	<style> #manageCourses { display: block; } </style>
<% } %>

<div id="CCMPage1">
	<div id="manageCourses">
		<div class="CCMSpace">
		<strong>Courses to which you are assigned as the primary instructor:</strong>
		
		<!-- Instructor Courses -->
		<div class="CSSTableGenerator">
		<table class="four">
			
				<tr>
					<td>Enrl</td>
					<td>Course Title (Course ID)</td>
					<td id="availabilityTT">Availability <img height="20px" src='<%= moduleBasePath + "question_mark.png" %>' /></td>
					<td id="actionTT">Action <img height="20px" src='<%= moduleBasePath + "question_mark.png" %>' /></td>
				</tr>
				
				<%
				for (int i=0, l = instMemberships.size(); i < l; i++) {
					CMWrapper cm = instMemberships.get(i);
					int enrl = cm.course.loadMemberships().size();
					String cvUri = "http://cdpemoss.wsu.edu/_layouts/CDPE/CourseVerification/Version08/Summary.aspx?pk1=";
					String disableUri = moduleBasePath + "disable.jsp?course-id=" + cm.course.courseId;
					String enableUri = moduleBasePath + "enable.jsp?course-id=" + cm.course.courseId;
					String activateUri = moduleBasePath + "activate.jsp?course-id=" 
							+ cm.course.courseId + "&title=" + cm.course.title;
					String displayTitle = cm.course.title + " (" + cm.course.courseId + ")";
					if(!cm.course.isChild) {
				%>
				<tr>
					<td><%= enrl %></td>
					<td>
					<% if (!cm.course.isRoster) { %>
						<a href="<%= courseBasePath + cm.course.coursePkId %>"><%= displayTitle %></a>
					<% } else { %>
						<%= displayTitle %>
					<% } %>
					</td>
					<td>
					<% if (!cm.course.isRoster) { 
						if (cm.course.isAvailable) {
					%>
						<a class="showLoading" href="<%= disableUri %>">Disable</a>
					<% } else { %>
						<a class="showLoading" href="<%= enableUri %>">Enable</a>
					<% } 
					} %>
					</td>
					<td>
					<% if (cm.course.isOnline) {	%>
						<% if (!cm.course.isRoster) { %>
						<a target="_blank" href="<%= cvUri + cm.course.courseId %>">Course Verificaion</a>
						<% } else { %>
						*
						<% } %>
					<% } else if (cm.course.isRoster) { %>
						<a class="showLoading" href="<%= activateUri %>">Activate</a>
					<% } else { %>
						<a class="manageSection" href="#<%= cm.course.courseId %>">Manage</a>
					<% } %>
					</td>
				</tr>
					<% } 
					if (cm.course.isParent) { 
						List<CourseWrapper> childCourses = CourseWrapper
								.loadChildCourseWrappersByParentCourse(cm._course);
						CourseWrapper.sort(childCourses);
						for (int j=0, m = childCourses.size(); j < m; j++) {
							CourseWrapper child = childCourses.get(j);
							int childEnrl = child.loadMemberships().size();
							String unmergeUri = moduleBasePath + "remove.jsp?parent-course=" + cm.course.courseId 
									+ "&child-course=" + child.courseId;
							String childDisplayTitle = child.title + " (" + child.courseId +")";
					%>
						<tr>
							<td>
								<%= childEnrl %>
							</td>
							<td class="child">
								<%= childDisplayTitle %>
							</td>
							<td>
							</td>
							<td>
								<% if (!cm.course.isOnline) {	%>
									<a class="showLoading" href="<%= unmergeUri %>">Remove</a>
								<% } %>
							</td>
						</tr>
					<% }
					}
				} %>
			
		</table>
		</div>
		<strong>* Global Campus courses are managed through the Course Verification process and enabled by Global Campus before the official start date.</strong>
		</div>
	</div><!-- END Manage Course -->

	<!-- Active Student COURSE LIST -->
	<div class="CCMSpace">		
		<strong>Courses in which you are enrolled as a student:</strong>
		<ul class="portletList-img courseListing">
			<% if (activeStudentMemberships.size() == 0) { %>
			<li>Sorry, you are not enrolled in any active courses as a student.</li>
			<% } else { 
				for(int i=0, l = activeStudentMemberships.size(); i < l; i++) {
					CMWrapper cm = activeStudentMemberships.get(i);
			%>
				<li><a href="<%= courseBasePath + cm.course.coursePkId %>"><%= cm.course.courseId %></a></li>	
			<%	}
			} %>
		</ul>
	</div>
	
</div><!-- End Page1 -->

<div id="CCMPage2">
	<div class="CCMSpace">
		<strong>Parent Course Space</strong>
		<br/>
		<div id="parentCourse"></div>
		<br/>
		<strong>Select other rosters to include</strong>
		<ul id="mergeList" class="portletList-img courseListing">
		<% 
			for (int i = 0, l = rosterWrapper.size(); i < l; i++) {
				CMWrapper roster = rosterWrapper.get(i);
				String displayTitle = roster.course.title + " (" + roster.course.courseId + ")";
		%>
		<li>
		<% if (!roster.course.isOnline) { %>
			<input type='checkbox' value='<%= roster.course.courseId %>' />
		<% } else { %>
			* 
		<% } %>
			<%= displayTitle %>
		</li>
		<% } %>
		</ul>
		<bbNG:button id="createCourseSection" url="#" label="Save" />
		<!-- <button id="createCourseSection">Create Course Section</button>-->
	</div>
	<strong>* Global Campus courses are managed through the Course Verification process and enabled by Global Campus before the official start date.</strong>
</div><!-- End Page2 -->

<div id="loadingRequest">
	<div class="CCMSpace">
		<strong>Loading...</strong>
		<p></p>
	</div>
</div>

<script type="text/javascript" src='<%= moduleBasePath + "opentip.js" %>'></script>
<script type="text/javascript">
	function ready(cb) {
		typeof Opentip == 'undefined' // in = loadINg
        ? setTimeout('ready('+cb+')', 9)
        : cb();
	}

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
</script>
<script type="text/javascript">
	var moduleBasePath = "<%= moduleBasePath %>";
	var parentCourseId = '';
	
	document.getElementById('createCourseSection').addEventListener('click', function(evt){
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
	}, false);
	
	onClassClick(".manageSection", function(evt) {
		evt.stopPropagation();
		evt.preventDefault();
		
		parentCourseId = this.getAttribute("href").substring(1);
		document.getElementById("parentCourse").innerHTML = parentCourseId;
		
		showPage2();
	});
	
	onClassClick(".showLoading", showLoading);
	
	function onClassClick(cls, fn) {
		[].forEach.call(document.querySelectorAll(cls), function(el) {
			el.addEventListener("click", fn.bind(el), false);
		});
	}
	
	function showPage1(evt) {
		if(evt) {
			evt.stopPropagation();
	        evt.preventDefault();
		}
        document.getElementById("CCMPage2").style.display = "none";
        document.getElementById("CCMPage1").style.display = "block";
	}
	
	function showPage2(evt) {
		if(evt) {
			evt.stopPropagation();
	        evt.preventDefault();
		}
        document.getElementById("CCMPage1").style.display = "none";
        document.getElementById("CCMPage2").style.display = "block";
	}
	
	function showLoading(evt) {
        document.getElementById("CCMPage1").style.display = "none";
        document.getElementById("CCMPage2").style.display = "none";
        document.getElementById("loadingRequest").style.display = "block";
	}
	
		
</script>

</bbNG:includedPage>