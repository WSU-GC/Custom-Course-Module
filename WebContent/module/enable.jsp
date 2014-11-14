<%@ page import="edu.wsu.*" %>
<%@ taglib uri="/bbNG" prefix="bbNG"%>
<%@page isErrorPage="true" %>

<bbNG:learningSystemPage  ctxId="bbContext">

<%

String courseId = request.getParameter("course-id");

CourseManagement.enableOrDisableCourse(courseId, true);

response.sendRedirect("/");

%>

</bbNG:learningSystemPage>