<%@ page import="edu.wsu.*" %>
<%@page import="blackboard.data.course.*" %>
<%@page import="blackboard.persist.course.*" %>
<%@ taglib uri="/bbNG" prefix="bbNG"%>
<%@page isErrorPage="true" %>

<bbNG:learningSystemPage  ctxId="bbContext">

<bbNG:pageHeader> 
 <fmt:message var="pageTitleVar" key="bundle.key" bundle="Course Module"/> 
 <bbNG:pageTitleBar title="Course Module"/> 
</bbNG:pageHeader>

<%

User user = bbContext.getUser();

String courseID = request.getParameter("course-id");
String title = request.getParameter("title");

String[] ids = CourseManagement.getBatchAndCourseIdFromRoster(courseID);

CourseManagement.createCourseSpace(ids[0], ids[1], title);

CourseMembership instrMembership = new CourseMembership();
CourseMembershipDbPersister cmPersister = CourseMembershipDbPersister.Default.getInstance();


instrMembership.setRole(CourseMembership.Role.INSTRUCTOR);
instrMembership.setCourseId(parentCourse.getId());
instrMembership.setUserId(user.getId());
try { // POSSIBLY UPDATING PREVIOUSLY CREATED COURSE THE INSTR IS ALREADY ENROLLED IN
	CourseMembershipDbLoader.Default.getInstance()
		.loadByCourseAndUserId(parentCourse.getId(), user.getId());
} catch(Exception e) {
	cmPersister.persist(instrMembership);
}

CourseManagement.mergeCourses(ids[1], new String[] {courseID});

response.sendRedirect("/");

%>

</bbNG:learningSystemPage>