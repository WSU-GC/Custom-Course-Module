package edu.wsu;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
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
	public String title;
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
		//String saipRegex = "^\\d+-\\d+-\\d+-\\w+-\\w+-\\d+$";
		String saipRegex = "^ROSTER-.+";
		String onlineRegex = "(?i).+-ONLIN-.+";
		this.course = course;
		this.title = this.course.getTitle();
		this.id = this.course.getId();
		this.coursePkId = this.id.toExternalString();
		this.courseId = this.course.getCourseId();
		this.courseBatchUid = this.course.getBatchUid();
		this.isAvailable = this.course.getIsAvailable();
		this.isRoster = this.courseId.matches(saipRegex);
		this.isOnline = this.courseId.matches(onlineRegex);
		this.isParent = course.isParent();
		this.isChild = course.isChild();
		//this.memberships = CourseMembershipDbLoader.Default.getInstance().loadByCourseId(this.id);
		//this.enrollment = this.memberships != null ? this.memberships.size() : 0;
	}
	
	public List<CourseMembership> loadMemberships() throws KeyNotFoundException, PersistenceException {
		return CourseMembershipDbLoader.Default.getInstance().loadByCourseId(this.id);
	}
	
	public List<CourseWrapper> loadChildren() 
			throws PersistenceException {
		return CourseWrapper.loadChildCourseWrappersByParentCourse(this.course);
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
		CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
		List<CourseWrapper> cwCourses = new ArrayList<CourseWrapper>();
		List<CourseCourse> ccMappings = CourseCourseDbLoader.Default.getInstance().loadByParentId(course.getId());
		for (int i = 0, l = ccMappings.size(); i < l; i++) {
			CourseCourse ccMap = ccMappings.get(i);
			try {
				Course child = CourseDbLoader.Default.getInstance().loadById(ccMap.getChildCourseId());
				cwCourses.add(new CourseWrapper(child));								
			} catch (Exception e) {
				
			}
			
		}
		return cwCourses;
	}
	
	public static List<CourseWrapper> loadByCourses(List<Course> courses) {
		List<CourseWrapper> cw = new ArrayList<CourseWrapper>();
		for(Course course: courses) {
			cw.add(new CourseWrapper(course));
		}
		return cw;
	}
	
	public static void sort(List<CourseWrapper> courses) {
		Collections.sort(courses, new Comparator<CourseWrapper>() {
			public int compare(CourseWrapper o1, CourseWrapper o2) {
				if ((!o1.isRoster && !o2.isRoster)
						|| (o1.isRoster && o2.isRoster)) {
					return secondCompare(o1, o2);
				} else if (!o1.isRoster && o2.isRoster) {
					return -1;
				} else {
					return 1;
				}
			}
			
			private int secondCompare(CourseWrapper o1, CourseWrapper o2) {
				if ((!o1.isAvailable && !o2.isAvailable)
						|| (o1.isAvailable && o2.isAvailable)) {
					return thirdCompare(o1, o2);
				} else if (!o1.isAvailable && o2.isAvailable) {
					return 1;
				} else {
					return -1;
				}
			}
			
			private int thirdCompare(CourseWrapper o1, CourseWrapper o2) {
				return o1.courseId.compareTo(o2.courseId);
			}
		});
	}
}
