package edu.wsu;

import blackboard.data.ValidationException;
import blackboard.data.course.Course;
import blackboard.data.course.CourseCourseManager;
import blackboard.data.course.CourseCourseManagerFactory;
import blackboard.persist.PersistenceException;
import blackboard.persist.course.CourseDbLoader;
import blackboard.persist.course.CourseDbPersister;


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
		}
		
	}
	
	public static void unmerge(String parentId, String childId) throws Exception {
		CourseCourseManager ccManager = CourseCourseManagerFactory.getInstance();
		CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
		Course parentCourse = courseLoader.loadByCourseId(parentId);
		Course childCourse = courseLoader.loadByCourseId(childId);
		ccManager.removeChildFromMaster(childCourse.getId(), parentCourse.getId(), 
				CourseCourseManager.DecrosslistStyle.KEEP_ORIGINAL_COURSE);
	}
	
}
