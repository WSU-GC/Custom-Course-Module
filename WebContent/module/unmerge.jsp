<%@page import="blackboard.platform.plugin.PlugInUtil" %>
<%@page import="blackboard.platform.*" %>
<%@page import="blackboard.base.*" %>
<%@page import="blackboard.data.course.*" %>
<%@page import="blackboard.data.user.*" %>
<%@page import="blackboard.persist.*" %>
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
CourseCourseManager ccManager = CourseCourseManagerFactory.getInstance();
GroupDbLoader groupLoader = GroupDbLoader.Default.getInstance();
CourseMembershipDbLoader cmLoader = CourseMembershipDbLoader.Default.getInstance();
GroupMembershipDbLoader gmLoader = GroupMembershipDbLoader.Default.getInstance();

CourseDbPersister coursePersister = CourseDbPersister.Default.getInstance();
CourseCourseDbPersister ccPersister = CourseCourseDbPersister.Default.getInstance();
GroupDbPersister groupPersister = GroupDbPersister.Default.getInstance();
GroupMembershipDbPersister gmPersister = GroupMembershipDbPersister.Default.getInstance();


Course parentCourse = courseLoader.loadByBatchUid(request.getParameter("parent-batchuid"));
Course childCourse = courseLoader.loadByBatchUid(request.getParameter("child-batchuid"));

List<Group> groups = groupLoader.loadByCourseId(parentCourse.getId());

boolean needToRemoveGroup = false;
Group groupToRemove = new Group();
for (int i =0, l = groups.size(); i < l; i++) {
	Group curGroup = groups.get(i);
	if(curGroup.getTitle().equalsIgnoreCase(childCourse.getCourseId())) {
		groupToRemove = groupLoader.loadById(curGroup.getId());
		needToRemoveGroup = true;
	}
}

if(needToRemoveGroup) {
	List<GroupMembership> groupMemberships= gmLoader.loadByGroupId(groupToRemove.getId());
	for (int i = 0, l = groupMemberships.size(); i < l; i++) {
		gmPersister.deleteById(groupMemberships.get(i).getId());
	}
}


ccManager.removeChildFromMaster(childCourse.getId(), parentCourse.getId(), CourseCourseManager.DecrosslistStyle.KEEP_ORIGINAL_COURSE);

childCourse.setHonorTermAvailability(false);
childCourse.setIsAvailable(false);
coursePersister.persist(childCourse);

response.sendRedirect("/");

%>

</bbNG:learningSystemPage>