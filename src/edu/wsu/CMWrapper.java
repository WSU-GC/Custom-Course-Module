package edu.wsu;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import blackboard.data.course.Course;
import blackboard.data.course.CourseMembership;
import blackboard.data.course.CourseToolUtil;
import blackboard.data.navigation.ToolSettingsException;
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
	//public boolean useCourseVerification;
	
	public CMWrapper() {
	}
	
	public CMWrapper(User user, Course course) 
			throws KeyNotFoundException, PersistenceException, ToolSettingsException {
		this.user = user;
		this._course = course;
		this.course = new CourseWrapper(course);
		this.membership = CourseMembershipDbLoader.Default.getInstance()
				.loadByCourseAndUserId(this.course.id, this.user.getId());
		this.role = this.membership.getRoleAsString();
		//this.useCourseVerification = this.isCourseVerificationEnabled();
	}
	
	public CMWrapper(User user, Course course, Course _parent) throws Exception {
		this.user = user;
		this._course = course;
		this.course = new CourseWrapper(course);
		CourseWrapper parent = new CourseWrapper(_parent);
		try {
			this.membership = CourseMembershipDbLoader.Default.getInstance()
					.loadByCourseAndUserId(this.course.id, this.user.getId());
		} catch (Exception e) {
			try {
				this.membership = CourseMembershipDbLoader.Default.getInstance()
						.loadByCourseAndUserId(parent.id, this.user.getId());
			} catch (Exception f) {
				throw new Exception("User is not associated to course: " + user.getUserName() + " " + this.course.courseId + " or " + parent.courseId);
			}
		}
		
		
		this.role = this.membership.getRoleAsString();
	}
	
	public List<CMWrapper> loadChildren() 
			throws PersistenceException, Exception {
//		try {
			return CMWrapper.loadCMWrappersByUserAndCourseWrappersAndParent(this.user, this.course.loadChildren(), this.course.course);			
//		} catch (Exception e) {
//			throw new Exception("Unable to load CM Wrappers.");
//		}
	}
	
	public static List<CMWrapper> loadCMWrappersByUser(User user) throws KeyNotFoundException, PersistenceException, ToolSettingsException {
		List<CourseWrapper> courseWrappers = CourseWrapper.loadCourseWrappersByUser(user);
		return CMWrapper.loadCMWrappersByUserAndCourseWrappers(user, courseWrappers);
	}
	
	public boolean isCourseVerificationEnabled() throws PersistenceException {
//		String pluginName = courseToolUtil.getLocalizedLabelForCourseTools(arg0, arg1, arg2);
		return CourseToolUtil.isToolAvailableForCourseUser("wsu-course-verification", this.membership);
	}
	
	public static List<CMWrapper> loadCMWrappersByUserAndCourses(User user, List<Course> courses) 
			throws KeyNotFoundException, PersistenceException, ToolSettingsException {
		List<CMWrapper> cmWrappers = new ArrayList<CMWrapper>();
		for (int i =0, l = courses.size(); i < l; i++) {
			cmWrappers.add(new CMWrapper(user, courses.get(i)));
		}
		return cmWrappers;
	}
	
	public static List<CMWrapper> loadCMWrappersByUserAndCourseWrappersAndParent(User user, List<CourseWrapper> courses, Course parent) 
			throws Exception {
		List<CMWrapper> cmWrappers = new ArrayList<CMWrapper>();
		for (CourseWrapper course: courses) {
			cmWrappers.add(new CMWrapper(user, course.course, parent));
		}
		return cmWrappers;
	}
	
	public static List<CMWrapper> loadCMWrappersByUserAndCourseWrappers(User user, List<CourseWrapper> courses) 
			throws PersistenceException, ToolSettingsException {
		List<CMWrapper> cmWrappers = new ArrayList<CMWrapper>();
		for (CourseWrapper course: courses) {
			cmWrappers.add(new CMWrapper(user, course.course));
		}
		return cmWrappers;
	}
	
	public static List<CMWrapper> filterCMWrappersByAvailability(List<CMWrapper> courses, 
			boolean isAvailable) {
		String userRegex = "^USER-.+";
		List<CMWrapper> cmWrappers = new ArrayList<CMWrapper>();
		for (int i = 0, l = courses.size(); i < l; i++) {
			CMWrapper cm = courses.get(i);
			if (cm.course.isAvailable == isAvailable && cm.membership.getIsAvailable()) {
				cmWrappers.add(cm);
			}
		}
		return cmWrappers;
	}
	
	
	public static List<CMWrapper> filterCMWrappersByRole(List<CMWrapper> courses, String role, boolean equals) {
		String userRegex = "^USER-.+";
		List<CMWrapper> cmWrappers = new ArrayList<CMWrapper>();
		for (int i = 0, l = courses.size(); i < l; i++) {
			CMWrapper cm = courses.get(i);
			if(cm.membership.getIsAvailable()) {
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
				
		}
		return cmWrappers;
	}
	
	public static List<CMWrapper> filterIsolatedRosters(List<CMWrapper> courses) {
		String userRegex = "^USER-.+";
		List<CMWrapper> cmWrappers = new ArrayList<CMWrapper>();
		for (int i = 0, l = courses.size(); i < l; i++) {
			CMWrapper cm = courses.get(i);
			if (cm.course.isRoster && !cm.course.isChild) {
				cmWrappers.add(cm);
			}
		}
		return cmWrappers;
	}
	
	public static void sort(List<CMWrapper> courses) {
		Collections.sort(courses, new Comparator<CMWrapper>() {
			public int compare(CMWrapper o1, CMWrapper o2) {
				if ((!o1.course.isRoster && !o2.course.isRoster)
						|| (o1.course.isRoster && o2.course.isRoster)) {
					return secondCompare(o1, o2);
				} else if (!o1.course.isRoster && o2.course.isRoster) {
					return -1;
				} else {
					return 1;
				}
			}
			
			private int secondCompare(CMWrapper o1, CMWrapper o2) {
				if ((!o1.course.isAvailable && !o2.course.isAvailable)
						|| (o1.course.isAvailable && o2.course.isAvailable)) {
					return thirdCompare(o1, o2);
				} else if (!o1.course.isAvailable && o2.course.isAvailable) {
					return 1;
				} else {
					return -1;
				}
			}
			
			private int thirdCompare(CMWrapper o1, CMWrapper o2) {
				return o1.course.courseId.compareTo(o2.course.courseId);
			}
		});
	}
	
}
