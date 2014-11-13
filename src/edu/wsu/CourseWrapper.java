package edu.wsu;

import java.util.ArrayList;
import java.util.List;

import blackboard.data.course.Course;
import blackboard.data.course.CourseMembership;
import blackboard.data.user.User;
import blackboard.persist.Id;
import blackboard.persist.KeyNotFoundException;
import blackboard.persist.PersistenceException;
import blackboard.persist.course.CourseDbLoader;
import blackboard.persist.course.CourseMembershipDbLoader;

class CourseWrapper {
	
	public Course course;
	public String coursePkId;
	public Id id;
	public String courseId;
	public String courseBatchUid; 
	public boolean isAvailable;
	//public List<CourseMembership> memberships = new ArrayList<CourseMembership>();
	//public int enrollment;
	
	
	public CourseWrapper() {
	}
	
	public CourseWrapper(Course course) {
		this.course = course;
		this.id = this.course.getId();
		this.coursePkId = this.id.toExternalString();
		this.courseId = this.course.getCourseId();
		this.courseBatchUid = this.course.getBatchUid();
		this.isAvailable = course.getIsAvailable();
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
}