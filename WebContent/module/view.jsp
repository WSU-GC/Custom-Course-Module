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
		<strong>Courses you are an Instructor:</strong>
		
		<!-- Instructor Courses -->
		<div class="CSSTableGenerator">
		<table class="four">
			
				<tr>
					<td>Enrl</td>
					<td>Course ID</td>
					<td>Availability</td>
					<td>Action</td>
				</tr>
				
				<%
				for (int i=0, l = instMemberships.size(); i < l; i++) {
					CMWrapper cm = instMemberships.get(i);
					int enrl = cm.course.loadMemberships().size();
					String cvUri = "http://cdpemoss.wsu.edu/_layouts/CDPE/CourseVerification/Version08/Summary.aspx?pk1=";
					String disableUri = moduleBasePath + "disable.jsp?batch-uid=" + cm.course.courseId;
					String enableUri = moduleBasePath + "enable.jsp?batch-uid=" + cm.course.courseId;
					String activateUri = moduleBasePath + "activate.jsp?course-id=" 
							+ cm.course.courseId + "&title=" + cm.course.title;
					if(!cm.course.isChild) {
				%>
				<tr>
					<td><%= enrl %></td>
					<td>
					<% if (!cm.course.isRoster) { %>
						<a href="<%= courseBasePath + cm.course.coursePkId %>"><%= cm.course.courseId %></a>
					<% } else { %>
						<%= cm.course.courseId %>
					<% } %>
					</td>
					<td>
					<% if (!cm.course.isRoster) { 
						if (cm.course.isAvailable) {
					%>
						<a href="<%= disableUri %>">Disable</a>
					<% } else { %>
						<a href="<%= enableUri %>">Enable</a>
					<% }
					} %>
					</td>
					<td>
					<% if (cm.course.isOnline) {	%>
						<a target="_blank" href="<%= cvUri + cm.course.courseId %>">Course Verificaion</a>
					<% } else if (cm.course.isRoster) { %>
						<a href="<%= activateUri %>">Activate</a>
					<% } else { %>
						<a class="manageSection" href="#<%= cm.course.courseId %>">Manage</a>
					<% } %>
					</td>
				</tr>
					<% } 
					if (cm.course.isParent) { 
						List<CourseWrapper> childCourses = CourseWrapper
								.loadChildCourseWrappersByParentCourse(cm._course);
						for (int j=0, m = childCourses.size(); j < m; j++) {
							CourseWrapper child = childCourses.get(j);
							int childEnrl = child.loadMemberships().size();
							String unmergeUri = moduleBasePath + "remove.jsp?parent-course=" + cm.course.courseId 
									+ "&child-course=" + child.courseId;
					%>
						<tr>
							<td>
								<%= childEnrl %>
							</td>
							<td class="child">
								<%= child.courseId %>
							</td>
							<td>
							</td>
							<td>
								<% if (!cm.course.isOnline) {	%>
									<a href="<%= unmergeUri %>">Remove</a>
								<% } %>
							</td>
						</tr>
					<% }
					}
				} %>
			
		</table>
		</div>
		</div>
	</div><!-- END Manage Course -->

	<!-- Active Student COURSE LIST -->
	<div class="CCMSpace">		
		<strong>Courses you are a student:</strong>
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
		%>
		<li>
		<% if (!roster.course.isOnline) { %>
			<input type='checkbox' value='<%= roster.course.courseId %>' />
		<% } else { %>
			* 
		<% } %>
			<%= roster.course.courseId %>
		</li>
		<% } %>
		</ul>
		<bbNG:button id="createCourseSection" url="#" label="Save" />
		<!-- <button id="createCourseSection">Create Course Section</button>-->
	</div>
</div><!-- End Page2 -->

<div id="loadingRequest">
	<div class="CCMSpace">
		<strong>Loading...</strong>
		<p></p>
	</div>
</div>

<script type="text/javascript">
	<%-- var rosters = JSON.parse('<%= jsonRoster %>');
	var activeSections = JSON.parse('<%= jsonActiveSections %>');
	var disabledSections = JSON.parse('<%= jsonDisabledSections %>'); --%>
	var moduleBasePath = "<%= moduleBasePath %>";
	var parentCourseBatchUid = '';
	<%-- var isInstructor = <%= isInstructor %>; --%>
	var parentCourseId = '';
	
	//if(isInstructor) showPage2();
	
	document.getElementById('createCourseSection').addEventListener('click', function(evt){
		evt.stopPropagation();
		evt.preventDefault();
		
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
	
	/* onClassClick('.showCCMPage1', showPage1);
	onClassClick('.showCCMPage2', showPage2);
	onClassClick('.showCCMPage3', showPage3);
	
	onClassClick('.manageRosterLink', manage(rosters, true));
	onClassClick('.manageActiveSectionsLink', manage(activeSections, false));
	onClassClick('.manageDisabledSectionsLink', manage(disabledSections, false));
	
	onClassClick('.enableSection', function(evt) {
		evt.stopPropagation();
		evt.preventDefault();
		
		
		
	}); */
	
	function manage(sectionsToManage, skip) {
		return function(evt) {
			if (evt) {
				evt.stopPropagation();
				evt.preventDefault();
			}
			var ind = parseInt(this.getAttribute("href").substring(1));
			var rosterList = "";
			
			document.getElementById("parentCourse").innerHTML = sectionsToManage[ind][1];
			parentCourseBatchUid = sectionsToManage[ind][0];
			
			if(rosters.length) {
				for(var i=0, l = rosters.length; i<l; i++) {
					if(skip) {
						if(i != ind) {
							if(!/-ONLIN-/i.test(rosters[i][1])) {
								rosterList += "<li><input type='checkbox' value='"+ rosters[i][0] +"' />" + rosters[i][1] + "</li>";
							} else {
								rosterList += "<li>* " + rosters[i][1] +"</li>";
							}
						}
					} else {
						if(!/-ONLIN-/i.test(rosters[i][1])) {
							rosterList += "<li><input type='checkbox' value='"+ rosters[i][0] +"' />" + rosters[i][1] + "</li>";
						} else {
							rosterList += "<li>* " + rosters[i][1] +"</li>";
						}
					}
				}
			} else {
				rosterList += "<li>No available rosters to merge</li>";
			}
			
			document.getElementById("mergeList").innerHTML = rosterList;
			showPage3();
		}
	}
	
	
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
	
		
</script>

</bbNG:includedPage>