<%@page import="com.google.gson.Gson"%>
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

<bbNG:includedPage ctxId="bbContext">


<%

User user = bbContext.getUser();
String courseBasePath = "/webapps/blackboard/execute/launcher?type=Course&url=&id=";
boolean isInstructor = false;

List<CMWrapper> userMemberships = CMWrapper.loadCMWrappersByUser(user);
CMWrapper.sort(userMemberships);



List<CMWrapper> studentMemberships = CMWrapper.filterCMWrappersByRole(userMemberships, "STUDENT", true);
List<CMWrapper> activeStudentMemberships = CMWrapper.filterCMWrappersByAvailability(studentMemberships, true);

TermWrapper activeStudentTerms = new TermWrapper(activeStudentMemberships);

List<CMWrapper> instMemberships = CMWrapper.filterCMWrappersByRole(userMemberships, "STUDENT", false);

TermWrapper instTerms = new TermWrapper(instMemberships);

List<CMWrapper> rosterWrapper = CMWrapper.filterIsolatedRosters(instMemberships);

TermWrapper rosterTerms = new TermWrapper(rosterWrapper);

String jsonInstTerms = new Gson().toJson(instTerms);

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

		</div>
	</div><!-- END Manage Course -->

	<!-- Active Student COURSE LIST -->
	<div class="CCMSpace">		
		<h6>Courses in which you are enrolled as a student:</h6>
		
		
		
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
<script type="text/javascript">
	/* function ready(cb) {
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
	}); */
</script>
<script type="text/javascript">
	var moduleBasePath = "<%= moduleBasePath %>";
	var parentCourseId = '';
	var isInstructor = <%= isInstructor %>;
	
	
		
</script>

</bbNG:includedPage>