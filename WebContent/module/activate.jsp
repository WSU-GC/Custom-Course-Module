<%@ page import="edu.wsu.*" %>
<%@ taglib uri="/bbNG" prefix="bbNG"%>
<%@page isErrorPage="true" %>

<bbNG:learningSystemPage  ctxId="bbContext">

<bbNG:pageHeader> 
 <fmt:message var="pageTitleVar" key="bundle.key" bundle="Course Module"/> 
 <bbNG:pageTitleBar title="Course Module"/> 
</bbNG:pageHeader>

<%

String courseID = request.getParameter("course-id");
String title = request.getParameter("title");

String[] ids = CourseManagement.getBatchAndCourseIdFromRoster(courseID);

CourseManagement.createCourseSpace(ids[0], ids[1], title);

CourseManagement.mergeCourses(ids[1], new String[] {courseID});

response.sendRedirect("/");

%>

</bbNG:learningSystemPage>