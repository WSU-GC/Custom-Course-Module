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
<%@page isErrorPage="true" %>


<bbNG:learningSystemPage  ctxId="bbContext">

<bbNG:pageHeader> 
 <fmt:message var="pageTitleVar" key="bundle.key" bundle="Course Module"/> 
 <bbNG:pageTitleBar title="Course Module"/> 
</bbNG:pageHeader>

<%

User user = bbContext.getUser();
CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
CourseDbPersister coursePersister = CourseDbPersister.Default.getInstance();

Course course = courseLoader.loadByBatchUid(request.getParameter("batch-uid"));
course.setHonorTermAvailability(false);
course.setIsAvailable(false);
coursePersister.persist(course);
response.sendRedirect("/");

%>

</bbNG:learningSystemPage>