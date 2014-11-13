package edu.wsu;

import java.util.ArrayList;
import java.util.List;

import blackboard.data.course.Course;
import blackboard.data.course.CourseMembership;
import blackboard.data.user.User;
import blackboard.persist.KeyNotFoundException;
import blackboard.persist.PersistenceException;
import blackboard.persist.course.CourseMembershipDbLoader;

public class CMWrapper {
	public User user;
	public Course _course;
	public CourseWrapper course;
	public CourseMembership membership = null;
	public String role;
	
	public CMWrapper() {
	}
	
	public CMWrapper(User user, Course course) 
			throws KeyNotFoundException, PersistenceException {
		this.user = user;
		this._course = course;
		this.course = new CourseWrapper(course);
		this.membership = CourseMembershipDbLoader.Default.getInstance()
				.loadByCourseAndUserId(this.course.id, this.user.getId());
		this.role = this.membership.getRoleAsString();
	}
	
	public static List<CMWrapper> loadCMWrappersByUser(User user) throws KeyNotFoundException, PersistenceException {
		List<CourseWrapper> courseWrappers = CourseWrapper.loadCourseWrappersByUser(user);
		return CMWrapper.loadCMWrappersByUserAndCourseWrappers(user, courseWrappers);
	}
	
	public static List<CMWrapper> loadCMWrappersByUserAndCourses(User user, List<Course> courses) 
			throws KeyNotFoundException, PersistenceException {
		List<CMWrapper> cmWrappers = new ArrayList<CMWrapper>();
		for (int i =0, l = courses.size(); i < l; i++) {
			cmWrappers.add(new CMWrapper(user, courses.get(i)));
		}
		return cmWrappers;
	}
	
	public static List<CMWrapper> loadCMWrappersByUserAndCourseWrappers(User user, List<CourseWrapper> courses) 
			throws KeyNotFoundException, PersistenceException {
		List<CMWrapper> cmWrappers = new ArrayList<CMWrapper>();
		for (int i =0, l = courses.size(); i < l; i++) {
			cmWrappers.add(new CMWrapper(user, courses.get(i).course));
		}
		return cmWrappers;
	}
	
	public static List<CMWrapper> filterCMWrappersByAvailability(List<CMWrapper> courses, 
			boolean isAvailable) {
		List<CMWrapper> cmWrappers = new ArrayList<CMWrapper>();
		for (int i = 0, l = courses.size(); i < l; i++) {
			CMWrapper cm = courses.get(i);
			if (cm.course.isAvailable == isAvailable) {
				cmWrappers.add(cm);
			}
		}
		return cmWrappers;
	}
	
	public static List<CMWrapper> filterCMWrappersByRole(List<CMWrapper> courses, String role, boolean equals) {
		List<CMWrapper> cmWrappers = new ArrayList<CMWrapper>();
		for (int i = 0, l = courses.size(); i < l; i++) {
			CMWrapper cm = courses.get(i);
			if (equals) {
				if(cm.role.equalsIgnoreCase(role)) {
					cmWrappers.add(cm);
				}
			} else {
				if(!cm.role.equalsIgnoreCase(role)) {
					cmWrappers.add(cm);
				}
			}
		}
		return cmWrappers;
	}
	
}
