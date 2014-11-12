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

// CURRENT USER
User user = bbContext.getUser();


// LOADERS
CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
CourseCourseManager ccManager = CourseCourseManagerFactory.getInstance();
GroupDbLoader groupLoader = GroupDbLoader.Default.getInstance();
CourseMembershipDbLoader cmLoader = CourseMembershipDbLoader.Default.getInstance();

// PERSISTERS
CourseDbPersister coursePersister = CourseDbPersister.Default.getInstance();
CourseCourseDbPersister ccPersister = CourseCourseDbPersister.Default.getInstance();
CourseMembershipDbPersister cmPersister = CourseMembershipDbPersister.Default.getInstance();
GroupDbPersister groupPersister = GroupDbPersister.Default.getInstance();
GroupMembershipDbPersister gmPersister = GroupMembershipDbPersister.Default.getInstance();

// PAGE PARAMETERS - PARENT COURSE BATCHUID & LIST OF CHILD COURSE BATCHUIDS[OPTIONAL]
String parentCourseBatchUid = request.getParameter("parent-course");
String childCourseParam = request.getParameter("child-courses");

// CHILD_COURSE_BATCHUIDS|STRING -> CHILD_COURSES|ARRAY<STR>
// CHILD_COURSES|LIST<COURSE>
String[] childCoursesStr = childCourseParam.isEmpty() ? new String[0] : childCourseParam.split(",");
List<Course> childCourses = new ArrayList<Course>();


// LOAD THE ROSTER COURSE SELECTED TO BE THE "PARENT" SPACE
Course selectedRoster = courseLoader.loadByBatchUid(parentCourseBatchUid);


// PREPARE THE PARENT COURSE SECTION SPACE 
// ENROLL THE CURRENT INSTR OF THE ROSTER SPACE AS INSTR IN COURSE SECTION
Course parentCourse = new Course();
CourseMembership instrMembership = new CourseMembership();

// CHILD_COURSE_BATCHUID|ARRAY<STR> -> CHILD_COURSES|LIST<COURSE>
for (int i = 0, l = childCoursesStr.length; i<l; i++) {
	Course course = courseLoader.loadByBatchUid(childCoursesStr[i]);
	childCourses.add(course);
}

// PARENT SECTION BATCHUID
String courseBatchUid = "";
String courseUid = selectedRoster.getCourseId();

String[] CourseBatchUidTokens = selectedRoster.getBatchUid().split("-");

// SAIP_ID|STR -> COURSE_UID|STR (105423-01-2147-1-01-03214 -> 2147-03214)
if (5 < CourseBatchUidTokens.length) {
	courseBatchUid = CourseBatchUidTokens[2] + "-" + CourseBatchUidTokens[5];
}

String[] CourseUidTokens = selectedRoster.getCourseId().split("-");

// COURSE_ROSTER_ID|ARRAY<STR> -> COURSE_ID|STR
// E.G. ROSTER-2014-FALL-CHEM-105-3552-LEC-02 -> 2014-FALL-CHEM-105-3552-LEC
if (7 <= CourseUidTokens.length) {
	courseUid = "";
	int count = CourseUidTokens[0].equalsIgnoreCase("roster") ? 8 : 7;
	int skip = count == 8 ? 1 : 0;
	for(int i = 0; i < count; i++) {
		if (i >= skip) {
			String prefix = i > skip ? "-" : "";
			courseUid += prefix + CourseUidTokens[i];
		}
    }
}

// CONFIGURE AND PERSIST PARENT SECTION
if (courseLoader.doesCourseIdExist(courseUid)) {
	parentCourse = courseLoader.loadByCourseId(courseUid);
} else {
	parentCourse.setBatchUid(courseBatchUid);
	parentCourse.setCourseId(courseUid);
	String title = selectedRoster.getTitle().isEmpty() ? courseUid : selectedRoster.getTitle();
	parentCourse.setTitle(title);
	coursePersister.persist(parentCourse);
}

// ENROLL THE INSTRUCTOR INTO THE NEWLY CREATED PARENT SECTION
instrMembership.setRole(CourseMembership.Role.INSTRUCTOR);
instrMembership.setCourseId(parentCourse.getId());
instrMembership.setUserId(user.getId());
try { // POSSIBLY UPDATING PREVIOUSLY CREATED COURSE THE INSTR IS ALREADY ENROLLED IN
	CourseMembershipDbLoader.Default.getInstance()
		.loadByCourseAndUserId(parentCourse.getId(), user.getId());
} catch(Exception e) {
	try {
		cmPersister.persist(instrMembership);
	} catch(Exception d) {
		throw d;
	}
}

// MERGE SELECTED ROSTER INTO THE PARENT SECTION
if (!selectedRoster.equals(parentCourse)) { // IF NOT UPDATING AN EXISTING COURSE SPACE
	// ccManager.addChildToMaster(selectedRoster.getId(), parentCourse.getId());
	// ADD TO LIST OF CHILD SPACES TO MERGE AND CREATE GROUPS
	childCourses.add(selectedRoster);
}

// LOAD PARENT SECTION GROUPS
List<Group> groups = groupLoader.loadGroupsAndSetsByCourseId(parentCourse.getId());

// MERGE CHILD COURSE INTO PARENT SECTION
for(int i =0, l = childCourses.size(); i<l; i++) {
	Course curCourse = childCourses.get(i);
	Id coursePkId = curCourse.getId();
	String childCourseId = curCourse.getCourseId();

	// CREATING GROUPS
	boolean doesCurChildGroupExist = false;
	Group newGroup = new Group();
	for(int k=0, n = groups.size(); k < n; k++) { // DOES GROUP EXIST?
			
		Group curGroup = groups.get(k);
		if (curGroup.getTitle().equalsIgnoreCase(childCourseId)) {
			newGroup = groupLoader.loadById(curGroup.getId());
			doesCurChildGroupExist = true;
			break; 
		}
		
	}
	
	if (!doesCurChildGroupExist) { // IF NOT THEN CREATE ONE
		newGroup.setTitle(childCourseId);
		FormattedText text = new FormattedText(childCourseId, FormattedText.Type.PLAIN_TEXT);
		newGroup.setDescription(text);
		newGroup.setCourseId(parentCourse.getId());
		newGroup.setIsAvailable(false);
		groupPersister.persist(newGroup);
	}
	out.println(newGroup.getTitle());
	
	// LOAD MEMBERSHIPS OF CHILD SECTION AND CREATE CORRESPONDING GROUPS IN PARENT SECTION
	List<CourseMembership> childMemberships = cmLoader.loadByCourseId(coursePkId);
	
	for(int j=0, m = childMemberships.size(); j < m; j++) {
		
		CourseMembership curMembership = childMemberships.get(j);
		
		if(!newGroup.isUserAMember(curMembership.getId())) {
			GroupMembership groupMembership = new GroupMembership();
			groupMembership.setCourseMembershipId(curMembership.getId());
			groupMembership.setGroupId(newGroup.getId());
			gmPersister.persist(groupMembership);
		}
	}  
	
	// MERGE
	ccManager.addChildToMaster(coursePkId, parentCourse.getId());
}


response.sendRedirect("/");

%>

</bbNG:learningSystemPage>