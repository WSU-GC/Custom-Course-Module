package edu.wsu;

import java.util.List;

import blackboard.admin.data.datasource.DataSource;
import blackboard.admin.persist.datasource.DataSourceLoader;
import blackboard.base.FormattedText;
import blackboard.data.ValidationException;
import blackboard.data.course.Course;
import blackboard.data.course.CourseCourseManager;
import blackboard.data.course.CourseCourseManagerFactory;
import blackboard.data.course.CourseMembership;
import blackboard.data.course.Group;
import blackboard.data.course.GroupMembership;
import blackboard.persist.Id;
import blackboard.persist.KeyNotFoundException;
import blackboard.persist.PersistenceException;
import blackboard.persist.course.CourseDbLoader;
import blackboard.persist.course.CourseDbPersister;
import blackboard.persist.course.GroupDbLoader;
import blackboard.persist.course.GroupDbPersister;
import blackboard.persist.course.GroupMembershipDbLoader;
import blackboard.persist.course.GroupMembershipDbPersister;


public class CourseManagement {
	
	public CourseManagement() {
	}
	
	public static String[] getBatchAndCourseIdFromRoster(String rosterId) 
			throws Exception {
		int lastDigit = 0;
		String rosterRegex = "(?i)ROSTER-\\d+-\\w+-\\w+-\\w+-\\w+-\\d+-.+";
		String invalidRosterId = "Invalid Roster ID: " + rosterId + ", cannot generate batchuid or courseid from roster Id.";
		
		if(rosterId == null || !rosterId.matches(rosterRegex)) {
			throw new IllegalArgumentException(invalidRosterId);
		}
		
		String[] courseIdArr = rosterId.split("-");
		String[] yearTermComponents = courseIdArr[1].split("");
		
		if (yearTermComponents.length < 5) {
			throw new IllegalArgumentException(invalidRosterId);
		}
		
		if (courseIdArr[2].equalsIgnoreCase("fall")) {
			lastDigit = 7;
		} else if (courseIdArr[2].equalsIgnoreCase("spri")) {
			lastDigit = 3;
		} else if (courseIdArr[2].equalsIgnoreCase("summ")){
			lastDigit = 5;
		} else {
			throw new IllegalArgumentException(invalidRosterId);
		}
		
		String yearTerm = yearTermComponents[1] + yearTermComponents[3] 
				+ yearTermComponents[4] + Integer.toString(lastDigit);
		
		String id = yearTerm + "-" + Integer.toString(Integer.parseInt(courseIdArr[6]));
		String publicCourseId = courseIdArr[1] 
				+ "-" + courseIdArr[2]
				+ "-" + courseIdArr[3]
				+ "-" + courseIdArr[4]
				+ "-" + courseIdArr[5]
				+ "-" + courseIdArr[6]
				+ "-" + courseIdArr[7];
		
		return new String[] {publicCourseId, publicCourseId};
	}
	
	
	public static void createCourseSpaceFromRoster(String courseId, String title) 
			throws Exception {
		String[] ids = CourseManagement.getBatchAndCourseIdFromRoster(courseId);
		CourseManagement.createCourseSpace(ids[0], ids[1], title);
	}
	
	public static void createCourseSpaceFromRoster(String courseId, String title, String dataSource) 
			throws Exception {
		String[] ids = CourseManagement.getBatchAndCourseIdFromRoster(courseId);
		CourseManagement.createCourseSpace(ids[0], ids[1], title, dataSource);
	}
	
	public static void createCourseSpace(String batchUid, String courseId, String title) 
			throws Exception {
		CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
		String errorMessage = "Failed to create course space for bathcUid: " + batchUid
				+ " CourseId: " + courseId + " as it already exists";
		
		Course course = new Course();
		
		if (courseLoader.doesCourseIdExist(courseId)) {
			//throw new IllegalArgumentException(errorMessage);
			return;
		}
		
		try {
			course.setBatchUid(batchUid);
			course.setCourseId(courseId);
			course.setTitle(title);
			CourseDbPersister.Default.getInstance().persist(course);
		} catch (Exception e) {
			throw new Exception("Could not persist course to DB. BatchUid: " + batchUid + ".");
		}
		
	}
	
	public static void createCourseSpace(String batchUid, String courseId, String title, String dataSource) 
			throws Exception {
		CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
		DataSourceLoader dataSourceLoader = DataSourceLoader.Default.getInstance();
		Id dataSourceId;
		String errorMessage = "Failed to create course space for bathcUid: " + batchUid
				+ " CourseId: " + courseId + " as it already exists";
		
		Course course = new Course();
		
		if (courseLoader.doesCourseIdExist(courseId)) {
			//throw new IllegalArgumentException(errorMessage);
			return;
		}
		
		try {
			dataSourceId = dataSourceLoader.loadByBatchUid(dataSource).getDataSourceId();
		} catch(Exception e) {
			dataSourceId = dataSourceLoader.loadDefault().getDataSourceId();
		}
		
		try {
			course.setBatchUid(batchUid);
			course.setCourseId(courseId);
			course.setTitle(title);
			course.setDataSourceId(dataSourceId);
			CourseDbPersister.Default.getInstance().persist(course);
		} catch (Exception e) {
			throw new Exception("Could not persist course to DB. BatchUid: " + batchUid + ".");
		}
		
	}
	
	public static void mergeCourses(String parentId, String[] childIds) 
			throws Exception {
		CourseCourseManager ccManager = CourseCourseManagerFactory.getInstance();
		CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
		String errorMessage = "";
		
		if (!courseLoader.doesCourseIdExist(parentId)) {
			throw new Exception("Failed to merge courses. Parent course " + parentId + " does not exist. Create parent space first");
		}
		
		Course parentCourse = courseLoader.loadByCourseId(parentId);
		
		for (int i = 0, l = childIds.length; i < l; i++) {
			if (!courseLoader.doesCourseIdExist(childIds[i])) {
				//throw new Exception("Failed to merge courses. Child course " + childIds[i] + " does not exist. Parent course: " + parentId);
				errorMessage += "Failed to merge courses, child course " + childIds[i] + " does not exist. parent course: " + parentId + ".<br/>";
			} else {
				Course childCourse = courseLoader.loadByCourseId(childIds[i]);
				try {
					ccManager.addChildToMaster(childCourse.getId(), parentCourse.getId());
				} catch (Exception e) {
					//throw new Exception("Failed to persist course merge for parent: " + parentId + " Child: " + childIds[i]);
					errorMessage += "Failed to persist course merge for parent: " + parentId + " Child: " + childIds[i] + ".<br/>";
				}
				//CourseManagement.createGroup(parentId, childIds[i]);
			}
		}
		
		if(!errorMessage.isEmpty()) {
			throw new Exception(errorMessage);
		}
	}
	
	public static void unmerge(String parentId, String childId) throws Exception {
		CourseCourseManager ccManager = CourseCourseManagerFactory.getInstance();
		CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
		
		if (!courseLoader.doesCourseIdExist(parentId)) {
			throw new Exception("Failed to unmerge courses. parent course: " + parentId + " Child course: " + childId + ". Parent course Does not exist.");
		}
		if (!courseLoader.doesCourseIdExist(childId)) {
			throw new Exception("Failed to unmerge courses. parent course: " + parentId + " Child course: " + childId + ". Child course Does not exist.");
		}
		
		Course parentCourse = courseLoader.loadByCourseId(parentId);
		Course childCourse = courseLoader.loadByCourseId(childId);
		//CourseManagement.removeGroup(parentId, childId);
		try {
			// should be KEEP_ORIGINAL_COURSE_RETAIN_CHILD_ENROLLMENTS_IN_MASTER
			ccManager.removeChildFromMaster(childCourse.getId(), parentCourse.getId(), 
					CourseCourseManager.DecrosslistStyle.KEEP_ORIGINAL_COURSE);
		} catch (Exception e) {
			throw new Exception("Failed to persist unmerge courses. parent course: " + parentId + " Child course: " + childId + ".");
		}
		CourseManagement.enableOrDisableCourse(childCourse.getCourseId(), false);
	}
	
	public static void createGroup(String parentCourseId, String childCourseId) 
			throws Exception {
		CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
		GroupDbLoader groupLoader = GroupDbLoader.Default.getInstance();
		GroupDbPersister groupPersister = GroupDbPersister.Default.getInstance();
		GroupMembershipDbPersister gmPersister = GroupMembershipDbPersister.Default.getInstance();
		
		if (!courseLoader.doesCourseIdExist(parentCourseId)) {
			throw new Exception("Failed to create group for " + childCourseId + ". In " + parentCourseId + ". Parent course does not exist.");
		}
		if (!courseLoader.doesCourseIdExist(childCourseId)) {
			throw new Exception("Failed to create group for " + childCourseId + ". In " + parentCourseId + ". Child course does not exist.");
		}
		
		Course parentCourse = courseLoader.loadByCourseId(parentCourseId);
		Course childCourse = courseLoader.loadByCourseId(childCourseId);
		CourseWrapper childWrapper = new CourseWrapper(childCourse);
		List<CourseMembership> childMemberships = childWrapper.loadMemberships();
		
		List<Group> groups = groupLoader.loadGroupsAndSetsByCourseId(parentCourse.getId());
		
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
		
		for(int j=0, m = childMemberships.size(); j < m; j++) {
			
			CourseMembership curMembership = childMemberships.get(j);
			
			if(!newGroup.isUserAMember(curMembership.getId())) {
				GroupMembership groupMembership = new GroupMembership();
				groupMembership.setCourseMembershipId(curMembership.getId());
				groupMembership.setGroupId(newGroup.getId());
				gmPersister.persist(groupMembership);
			}
		}  
		
	}
	
	public static void removeGroup(String parentCourseId, String childCourseId) 
			throws Exception {
		CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
		GroupDbLoader groupLoader = GroupDbLoader.Default.getInstance();
		GroupMembershipDbLoader gmLoader = GroupMembershipDbLoader.Default.getInstance();
		GroupMembershipDbPersister gmPersister = GroupMembershipDbPersister.Default.getInstance();
		
		if (!courseLoader.doesCourseIdExist(parentCourseId)) {
			throw new Exception("Failed to remove group for " + childCourseId + ". In " + parentCourseId + ". Parent course does not exist.");
		}
		if (!courseLoader.doesCourseIdExist(childCourseId)) {
			throw new Exception("Failed to remove group for " + childCourseId + ". In " + parentCourseId + ". Child course does not exist.");
		}
		
		Course parentCourse = courseLoader.loadByCourseId(parentCourseId);
		Course childCourse = courseLoader.loadByCourseId(childCourseId);
		
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
	}
	
	public static void enableOrDisableCourse(String courseId, boolean enabled) 
			throws Exception {
		CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
		CourseDbPersister coursePersister = CourseDbPersister.Default.getInstance();
		
		if (!courseLoader.doesCourseIdExist(courseId)) {
			throw new Exception("Failed to enable or disable course. Could not locate " + courseId);
		}

		Course course = courseLoader.loadByCourseId(courseId);
		course.setHonorTermAvailability(false);
		course.setIsAvailable(enabled);
		coursePersister.persist(course);
	}
	
}
