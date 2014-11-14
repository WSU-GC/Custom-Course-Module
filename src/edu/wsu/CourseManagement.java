package edu.wsu;

import java.util.List;

import blackboard.base.FormattedText;
import blackboard.data.ValidationException;
import blackboard.data.course.Course;
import blackboard.data.course.CourseCourseManager;
import blackboard.data.course.CourseCourseManagerFactory;
import blackboard.data.course.CourseMembership;
import blackboard.data.course.Group;
import blackboard.data.course.GroupMembership;
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
	
	public static String[] getBatchAndCourseIdFromRoster(String rosterId) {
		int lastDigit = 0;
		String[] courseIdArr = rosterId.split("-");
		String[] yearTermComponents = courseIdArr[1].split("");
		
		if (courseIdArr[2].equalsIgnoreCase("fall")) {
			lastDigit = 7;
		} else if (courseIdArr[2].equalsIgnoreCase("spri")) {
			lastDigit = 3;
		} else {
			lastDigit = 5;
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
		
		return new String[] {id, publicCourseId};
	}
	
	
	public static void createCourseSpaceFromRoster(String courseId, String title) 
			throws PersistenceException, ValidationException {
		String[] ids = CourseManagement.getBatchAndCourseIdFromRoster(courseId);
		CourseManagement.createCourseSpace(ids[0], ids[1], title);
	}
	
	public static void createCourseSpace(String batchUid, String courseId, String title) 
			throws PersistenceException, ValidationException {
		
		Course course = new Course();
		course.setBatchUid(batchUid);
		course.setCourseId(courseId);
		course.setTitle(title);
		CourseDbPersister.Default.getInstance().persist(course);
		
	}
	
	public static void mergeCourses(String parentId, String[] childIds) 
			throws PersistenceException, ValidationException {
		CourseCourseManager ccManager = CourseCourseManagerFactory.getInstance();
		CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
		Course parentCourse = courseLoader.loadByCourseId(parentId);
		for (int i = 0, l = childIds.length; i < l; i++) {
			Course childCourse = courseLoader.loadByCourseId(childIds[i]);
			ccManager.addChildToMaster(childCourse.getId(), parentCourse.getId());
			CourseManagement.createGroup(parentId, childIds[i]);
		}
	}
	
	public static void unmerge(String parentId, String childId) throws Exception {
		CourseCourseManager ccManager = CourseCourseManagerFactory.getInstance();
		CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
		Course parentCourse = courseLoader.loadByCourseId(parentId);
		Course childCourse = courseLoader.loadByCourseId(childId);
		CourseManagement.removeGroup(parentId, childId);
		ccManager.removeChildFromMaster(childCourse.getId(), parentCourse.getId(), 
				CourseCourseManager.DecrosslistStyle.KEEP_ORIGINAL_COURSE);
		CourseManagement.enableOrDisableCourse(childCourse.getCourseId(), false);
	}
	
	public static void createGroup(String parentCourseId, String childCourseId) 
			throws KeyNotFoundException, PersistenceException, ValidationException {
		CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
		GroupDbLoader groupLoader = GroupDbLoader.Default.getInstance();
		GroupDbPersister groupPersister = GroupDbPersister.Default.getInstance();
		GroupMembershipDbPersister gmPersister = GroupMembershipDbPersister.Default.getInstance();
		
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
			throws PersistenceException {
		CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
		GroupDbLoader groupLoader = GroupDbLoader.Default.getInstance();
		GroupMembershipDbLoader gmLoader = GroupMembershipDbLoader.Default.getInstance();
		GroupMembershipDbPersister gmPersister = GroupMembershipDbPersister.Default.getInstance();
		
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
			throws KeyNotFoundException, PersistenceException, ValidationException {
		CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
		CourseDbPersister coursePersister = CourseDbPersister.Default.getInstance();

		Course course = courseLoader.loadByCourseId(courseId);
		course.setHonorTermAvailability(false);
		course.setIsAvailable(enabled);
		coursePersister.persist(course);
	}
	
}
