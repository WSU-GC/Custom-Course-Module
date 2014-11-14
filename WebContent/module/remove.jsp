<%@ page import="edu.wsu.*" %>
<%@ taglib uri="/bbNG" prefix="bbNG"%>
<%@page isErrorPage="true" %>

<bbNG:learningSystemPage  ctxId="bbContext">

<bbNG:pageHeader> 
 <fmt:message var="pageTitleVar" key="bundle.key" bundle="Course Module"/> 
 <bbNG:pageTitleBar title="Course Module"/> 
</bbNG:pageHeader>

<%

String parentCourseId = request.getParameter("parent-course");
String childId = request.getParameter("child-course");

CourseManagement.unmerge(parentCourseId, childId);

response.sendRedirect("/");

%>

</bbNG:learningSystemPage>