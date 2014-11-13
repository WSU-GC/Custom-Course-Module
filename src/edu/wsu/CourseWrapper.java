package edu.wsu;

import java.util.ArrayList;
import java.util.List;

import blackboard.data.course.Course;
import blackboard.data.course.CourseCourse;
import blackboard.data.course.CourseMembership;
import blackboard.data.user.User;
import blackboard.persist.Id;
import blackboard.persist.KeyNotFoundException;
import blackboard.persist.PersistenceException;
import blackboard.persist.course.CourseCourseDbLoader;
import blackboard.persist.course.CourseDbLoader;
import blackboard.persist.course.CourseMembershipDbLoader;

public class CourseWrapper {
	
	public Course course;
	public String coursePkId;
	public Id id;
	public String courseId;
	public String courseBatchUid; 
	public boolean isAvailable;
	public boolean isRoster;
	public boolean isOnline;
	public boolean isParent;
	public boolean isChild;
	//public List<CourseMembership> memberships = new ArrayList<CourseMembership>();
	//public int enrollment;
	
	
	public CourseWrapper() {
	}
	
	public CourseWrapper(Course course) {
		String saipRegex = "^\\d+-\\d+-\\d+-\\w+-\\w+-\\d+$";
		String onlineRegex = "(?i).+-ONLIN-.+";
		this.course = course;
		this.id = this.course.getId();
		this.coursePkId = this.id.toExternalString();
		this.courseId = this.course.getCourseId();
		this.courseBatchUid = this.course.getBatchUid();
		this.isAvailable = course.getIsAvailable();
		this.isRoster = this.courseBatchUid.matches(saipRegex);
		this.isOnline = this.courseId.matches(onlineRegex);
		this.isParent = course.isParent();
		this.isChild = course.isChild();
		//this.memberships = CourseMembershipDbLoader.Default.getInstance().loadByCourseId(this.id);
		//this.enrollment = this.memberships != null ? this.memberships.size() : 0;
	}
	
	public List<CourseMembership> loadMemberships() throws KeyNotFoundException, PersistenceException {
		return CourseMembershipDbLoader.Default.getInstance().loadByCourseId(this.id);
	}
	
	public static List<CourseWrapper> loadCourseWrappersByUser(User user) 
			throws KeyNotFoundException, PersistenceException {
		List<CourseWrapper> cwCourses = new ArrayList<CourseWrapper>();
		List<Course> courses = CourseDbLoader.Default.getInstance()
				.loadByUserId(user.getId());
		for (int i = 0, l = courses.size(); i < l; i++) {
			cwCourses.add(new CourseWrapper(courses.get(i)));
		}
		return cwCourses;
	}
	
	public static List<CourseWrapper> loadChildCourseWrappersByParentCourse(Course course) 
			throws PersistenceException {
		List<CourseWrapper> cwCourses = new ArrayList<CourseWrapper>();
		List<CourseCourse> ccMappings = CourseCourseDbLoader.Default.getInstance().loadByParentId(course.getId());
		for (int i = 0, l = ccMappings.size(); i < l; i++) {
			CourseCourse ccMap = ccMappings.get(i);
			Course child = CourseDbLoader.Default.getInstance().loadById(ccMap.getChildCourseId());
			cwCourses.add(new CourseWrapper(child));
		}
		return cwCourses;
	}
}