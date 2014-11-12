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

<style>
	#manageCourses {
		display: none;
		margin: 10px 0;
		font-size: 1.2rem;
	}
	#CCMPage2, #CCMPage3 {
		display: none;
	}
	.CCMSpace {
		margin-top: 8px;
	}
	.CCMSpace strong {
		font-size: 1.3rem;
	}
	.CSSTableGenerator {
		margin:10px 0px;padding:0px;
		width:100%;
		box-shadow: 1px 1px 5px #888888;
		border:1px solid #dddddd;
	}.CSSTableGenerator table{
	    border-collapse: collapse;
	        border-spacing: 0;
		width:100%;
		height:100%;
		margin:0px;padding:0px;
	}
	
	.CSSTableGenerator tr:nth-child(odd){ background-color:#d8d8d8; }
	.CSSTableGenerator tr:nth-child(even)    { background-color:#ffffff; }.CSSTableGenerator td{
		vertical-align:middle;
		border:1px solid #ffffff;
		border-width:0px 1px 1px 0px;
		text-align:left;
		padding:7px;
	}.CSSTableGenerator tr:last-child td{
		border-width:0px 1px 0px 0px;
	}.CSSTableGenerator tr td:last-child{
		border-width:0px 0px 1px 0px;
	}.CSSTableGenerator tr:last-child td:last-child{
		border-width:0px 0px 0px 0px;
	}
	.CSSTableGenerator tr:first-child td{
			background:-o-linear-gradient(bottom, #981e32 5%, #981e32 100%);	background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #981e32), color-stop(1, #981e32) );
		background:-moz-linear-gradient( center top, #981e32 5%, #981e32 100% );
		filter:progid:DXImageTransform.Microsoft.gradient(startColorstr="#981e32", endColorstr="#981e32");	background: -o-linear-gradient(top,#981e32,981e32);
	
		background-color:#981e32;
		border:0px solid #ffffff;
		text-align:center;
		border-width:0px 0px 1px 1px;
		color: #ffffff;
	}
	.CSSTableGenerator tr:first-child td:first-child{
		border-width:0px 0px 1px 0px;
	}
	.CSSTableGenerator tr:first-child td:last-child{
		border-width:0px 0px 1px 1px;
	}
	.CSSTableGenerator tr td.child {
		padding-left: 30px;
		background-image: url('<%= moduleBasePath + "xchild.png" %>');
		background-repeat: no-repeat;
		background-position: 15px center;
	}
	 
	.CSSTableGenerator table.four td:last-child,
	.CSSTableGenerator table.four td:nth-child(3) {
		width: 15%;
	}
	
	.CSSTableGenerator table.four td:first-child {
		width: 10%;
	}
	.CSSTableGenerator table.three td:first-child {
		width: 10%;
	}
	.CSSTableGenerator table.three td:last-child {
		width: 15%;
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

<div id="CCMPage1">
	<div id="manageCourses">
		<strong><a class="showCCMPage2" href="#">Course Control Panel</a></strong> 
	</div>

	<!-- COURSE LIST -->	
	<ul class="portletList-img courseListing">
		<%
		for(int i = 0; i < courses.size(); i++) {
			boolean isInstructorForCurrentCourse = false;
			Course course = ((Course)(courses.get(i)));
			String coursePkId = course.getId().toExternalString();
			String courseId = course.getCourseId();
			CourseMembership membership = CourseMembershipDbLoader.Default.getInstance()
					.loadByCourseAndUserId(course.getId(), user.getId());
			
			if (membership.getRoleAsString() == "INSTRUCTOR") {
				isInstructor = true;
				isInstructorForCurrentCourse = true;
			}
			if (course.getIsAvailable()) {
				if (!course.isChild()) {
					activeCourseCount++;
				}
				if (isInstructorForCurrentCourse) { 
					activeSections.add(course); 
				}
		%>
		<li><a href="<%= courseBasePath + coursePkId %>"><%= courseId %></a></li>
		<%
			} else if (course.getBatchUid().matches(saipRegex) 
					&& isInstructorForCurrentCourse
					&& !course.isChild()) {
				rosters.add(course);
			} else if (isInstructorForCurrentCourse
					&& !course.isChild()) {
				disabledSections.add(course);
			}
		} // End For loop

		if (activeCourseCount == 0) {
		%>
		<li>Sorry, you are not enrolled in any active courses at this time.</li>
		<% } %>
	</ul>
</div><!-- End Page1 -->

<% if(isInstructor) { %>
	<style> #manageCourses { display: block; } </style>
<% } %>

<div id="CCMPage2">
	<a class="showCCMPage1" href="#">back</a>
	<div class="CCMSpace">
		<strong>Enabled Course Spaces:</strong>
		
		<!-- Active Courses -->
		<div class="CSSTableGenerator">
		<table class="four">
			
				<tr>
					<td>Enrl</td>
					<td>Course ID</td>
					<td>Availability</td>
					<td>Action</td>
				</tr>
			
			
				<%
				jsonActiveSections = "[";
				for(int i=0; i<activeSections.size(); i++) { 
					Course course = ((Course)(activeSections.get(i)));
					String coursePkId = course.getId().toExternalString();
					String courseId = course.getCourseId();
					String batchUid = course.getBatchUid();
					List<CourseMembership> courseMemberships = cmLoader.loadByCourseId(course.getId());
					String cvUri = "http://cdpemoss.wsu.edu/_layouts/CDPE/CourseVerification/Version08/Summary.aspx?pk1=";
					String uri = moduleBasePath + "disable.jsp?batch-uid=" + batchUid;
					String prefix = i == 0 ? "" : ",";
					jsonActiveSections += prefix + "[\"" + batchUid + "\", \"" + courseId + "\"]";
				%>
				<tr>
					<td>
						<%= courseMemberships.size() %>
					</td>
					<td>
						<a href="<%= courseBasePath + coursePkId %>"><%= courseId %></a>
					</td>
					<td>
						<a href="<%= uri %>">Disable</a>
					</td>
					<td>
					<% if (courseId.matches(onlineRegex)) {	%>
						<a target="_blank" href="<%= cvUri + courseId %>">Course Verificaion</a>
					<% } else { %>
						<a class="manageActiveSectionsLink" href="#<%= i %>">Manage</a>
					<% } %>
					</td>
				</tr>
				<% 
				//check for child course
					if (course.isParent()) {
						List<CourseCourse> ccMappings = ccLoader.loadByParentId(course.getId());
						for (int j = 0, l=ccMappings.size(); j<l; j++) {
							CourseCourse ccMap = (CourseCourse)(ccMappings.get(j));
							Course child = courseLoader.loadById(ccMap.getChildCourseId());
							String childId = child.getCourseId();
							String childBUid = child.getBatchUid();
							List<CourseMembership> ccMemberships = cmLoader.loadByCourseId(child.getId());
							String unmergeUri = moduleBasePath + "unmerge.jsp?parent-batchuid=" + batchUid 
									+ "&child-batchuid=" + childBUid;
							%>
							<tr>
								<td>
									<%= ccMemberships.size() %>
								</td>
								<td class="child"> 
									<%= childId %>
								</td>
								<td>
									
								</td>
								<td>
								<% if (!courseId.matches(onlineRegex)) {	%>
									<a href="<%= unmergeUri %>">Remove</a>
								<% } %>
								</td>
							</tr>
							<%
						}
					}
				} 
				jsonActiveSections += "]";
				%>
			
		</table>
		</div>
		
		<% if (activeSections.isEmpty()) { %>
			Currently there are no active course sections.
		<% } %>
		
	</div>
	
	<div class="CCMSpace">
		<strong>Disabled Course Spaces:</strong>
		
		<!-- Disable Sections -->
		<div class="CSSTableGenerator">
		<table class="four">
			
				<tr>
					<td>Enrl</td>
					<td>Course ID</td>
					<td>Availability</td>
					<td>Action</td>
				</tr>
			
			
				<%
				jsonDisabledSections = "[";
				for(int i=0; i<disabledSections.size(); i++) { 
					Course course = ((Course)(disabledSections.get(i)));
					String coursePkId = course.getId().toExternalString();
					String courseId = course.getCourseId();
					String batchUid = course.getBatchUid();
					List<CourseMembership> courseMemberships = cmLoader.loadByCourseId(course.getId());
					String cvUri = "http://cdpemoss.wsu.edu/_layouts/CDPE/CourseVerification/Version08/Summary.aspx?pk1=";
					String uri = moduleBasePath + "enable.jsp?batch-uid=" + batchUid;
					String prefix = i == 0 ? "" : ",";
					jsonDisabledSections += prefix + "[\"" + batchUid + "\", \"" + courseId + "\"]";
				%>
				<tr>
					<td>
						<%= courseMemberships.size() %>
					</td>
					<td>
						<a href="<%= courseBasePath + coursePkId %>"><%= courseId %></a>
					</td>
					<td>
						<a href="<%= uri %>">Enable</a>
					</td>
					<td>
					<% if (courseId.matches(onlineRegex)) {	%>
						<a target="_blank" href="<%= cvUri + courseId %>">Course Verificaion</a>
					<% } else { %>
						<a class="manageDisabledSectionsLink" href="#<%= i %>">Manage</a>
					<% } %>
					</td>
				</tr>
				<% 
				//check for child course
					if (course.isParent()) {
						List<CourseCourse> ccMappings = ccLoader.loadByParentId(course.getId());
						for (int j = 0, l=ccMappings.size(); j<l; j++) {
							CourseCourse ccMap = (CourseCourse)(ccMappings.get(j));
							Course child = courseLoader.loadById(ccMap.getChildCourseId());
							String childId = child.getCourseId();
							String childBUid = child.getBatchUid();
							List<CourseMembership> ccMemberships = cmLoader.loadByCourseId(child.getId());
							String unmergeUri = moduleBasePath + "unmerge.jsp?parent-batchuid=" + batchUid 
									+ "&child-batchuid=" + childBUid;
							%>
							<tr>
								<td>
									<%= ccMemberships.size() %>
								</td>
								<td class="child"> 
									<%= childId %>
								</td>
								<td>
									
								</td>
								<td>
								<% if (!courseId.matches(onlineRegex)) {	%>
									<a href="<%= unmergeUri %>">Remove</a>
								<% } %>
								</td>
							</tr>
							<%
						}
					}
				} 
				jsonDisabledSections += "]";
				%>
			
		</table>
		</div>
		
		<% if (disabledSections.isEmpty()) { %>
			Currently there  Disabled sections to show at this time.
		<% } %>
	</div>
	
	<div class="CCMSpace">
		<strong>Course Rosters:</strong>
		
		<!-- Rosters -->
		<div class="CSSTableGenerator">
		<table class="three">
			
				<tr>
					<td>Enrl</td>
					<td>Course ID</td>
					<td>Action</td>
				</tr>
			
				<%
				jsonRoster = "[";
				for(int i=0; i<rosters.size(); i++) { 
					Course course = ((Course)(rosters.get(i)));
					String coursePkId = course.getId().toExternalString();
					String courseId = course.getCourseId();
					String batchUid = course.getBatchUid();
					List<CourseMembership> courseMemberships = cmLoader.loadByCourseId(course.getId());
					String prefix = i == 0 ? "" : ",";
					jsonRoster += prefix + "[\"" + batchUid + "\", \"" + courseId + "\"]";
				%>
				<tr>
					<td>
						<%= courseMemberships.size() %>
					</td>
					<td>
						<%= courseId %>
					</td>
					<td>
					<% if (courseId.matches(onlineRegex)) {	%>
						*
					<% } else { %>
						<a class="manageRosterLink" href="#<%= i %>">Manage</a>
					<% } %>
					</td>
				</tr>
				<% } 
				jsonRoster += "]";
				%>
			
		</table>
		</div>
		
		<% if (rosters.isEmpty()) { %>
			Roster list is empty.
		<% } %>
	</div>
</div><!-- End Page2 -->

<div id="CCMPage3">
	<a class="showCCMPage2" href="#">back</a>
	<div class="CCMSpace">
		<strong>Parent Course Space</strong>
		<br/>
		<div id="parentCourse"></div>
		<br/>
		<strong>Select other rosters to include</strong>
		<ul id="mergeList" class="portletList-img courseListing">
			
		</ul>
		<bbNG:button id="createCourseSection" url="#" label="Save" />
		<!-- <button id="createCourseSection">Create Course Section</button>-->
	</div>
</div><!-- End Page3 -->

<script type="text/javascript">
	var rosters = JSON.parse('<%= jsonRoster %>');
	var activeSections = JSON.parse('<%= jsonActiveSections %>');
	var disabledSections = JSON.parse('<%= jsonDisabledSections %>');
	var moduleBasePath = "<%= moduleBasePath %>";
	var parentCourseBatchUid = '';
	var isInstructor = <%= isInstructor %>;
	
	//if(isInstructor) showPage2();
	
	document.getElementById('createCourseSection').addEventListener('click', function(evt){
		evt.stopPropagation();
		evt.preventDefault();
		
		var uri = moduleBasePath + 'create-merge-course.jsp?parent-course=' + parentCourseBatchUid + "&child-courses=";
		var childCourses = document.querySelectorAll('#mergeList input:checked');
		[].forEach.call(childCourses, function(el, i) {
			var prefix = i > 0 ? ',' : '';
			uri += prefix + el.getAttribute("value");
		});
		window.location.replace(uri);
	}, false);
	
	onClassClick('.showCCMPage1', showPage1);
	onClassClick('.showCCMPage2', showPage2);
	onClassClick('.showCCMPage3', showPage3);
	
	onClassClick('.manageRosterLink', manage(rosters, true));
	onClassClick('.manageActiveSectionsLink', manage(activeSections, false));
	onClassClick('.manageDisabledSectionsLink', manage(disabledSections, false));
	
	onClassClick('.enableSection', function(evt) {
		evt.stopPropagation();
		evt.preventDefault();
		
	});
	
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
        document.getElementById("CCMPage3").style.display = "none";
        document.getElementById("CCMPage1").style.display = "block";
	}
	
	function showPage2(evt) {
		if(evt) {
			evt.stopPropagation();
	        evt.preventDefault();
		}
        document.getElementById("CCMPage1").style.display = "none";
        document.getElementById("CCMPage3").style.display = "none";
        document.getElementById("CCMPage2").style.display = "block";
	}
	
	function showPage3(evt) {
		if(evt) {
			evt.stopPropagation();
	        evt.preventDefault();
		}
        document.getElementById("CCMPage1").style.display = "none";
        document.getElementById("CCMPage2").style.display = "none";
        document.getElementById("CCMPage3").style.display = "block";
	}
		
</script>

</bbNG:includedPage>