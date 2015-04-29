package edu.wsu;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import blackboard.data.course.Course;
import blackboard.data.course.CourseCourse;
import blackboard.data.course.CourseMembership;
import blackboard.data.course.CourseToolUtil;
import blackboard.data.navigation.CourseToolSettings;
import blackboard.data.navigation.ToolSettingsException;
import blackboard.data.user.User;
import blackboard.persist.Id;
import blackboard.persist.KeyNotFoundException;
import blackboard.persist.PersistenceException;
import blackboard.persist.course.CourseCourseDbLoader;
import blackboard.persist.course.CourseDbLoader;
import blackboard.persist.user.UserDbLoader;
import blackboard.persist.course.CourseMembershipDbLoader;
import blackboard.persist.navigation.*;

public class CourseWrapper {
	
	public Course course;
	public String coursePkId;
	public Id id;
	public String courseId;
	public String courseBatchUid; 
	public String title;
	public String parent;
	public boolean isAvailable;
	public boolean isRoster;
	public boolean isOnline;
	public boolean isParent;
	public boolean isChild;
	public boolean isUsingCourseVerification;
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
		this.parent = this.loadParentCourseId();
		this.isUsingCourseVerification = checkForCourseVerification();
		//this.memberships = CourseMembershipDbLoader.Default.getInstance().loadByCourseId(this.id);
		//this.enrollment = this.memberships != null ? this.memberships.size() : 0;
	}
	
	public boolean checkForCourseVerification() {
		boolean isCV = false;
		ToolSettingsManager toolManager = ToolSettingsManagerFactory.getInstance();
		CourseToolSettings courseToolSettings;
		try {
			courseToolSettings = toolManager.loadCourseToolSettings(this.id, "wsu-wsu-course-verification", CourseToolSettings.CourseToolType.Application);
			isCV = courseToolSettings.getToolEnabledSetting().isAvailable();
		} catch (Exception e) {
			
		} 
		return isCV;
	}
	
	public List<String> loadCourseTools() throws PersistenceException {
		List<String> settingStrings = new ArrayList<String>();
		ToolSettingsManager toolManager = ToolSettingsManagerFactory.getInstance();
		List<CourseToolSettings> allSettings = toolManager.loadAllCourseToolSettings(this.id, CourseToolSettings.CourseToolType.Application, true);
		for(CourseToolSettings settings : allSettings) {
			settingStrings.add(settings.toString());
		}
		return settingStrings;
	}
	
	public List<CourseMembership> loadMemberships() throws KeyNotFoundException, PersistenceException {
		return CourseMembershipDbLoader.Default.getInstance().loadByCourseId(this.id);
	}
	
	public List<CourseMembership> loadInstructorMemberships() throws KeyNotFoundException, PersistenceException {
		return CourseMembershipDbLoader.Default.getInstance().loadByCourseIdAndInstructorFlag(this.id);
	}
	
	public List<String> loadInstructorEmails() throws KeyNotFoundException, PersistenceException {
		List<CourseMembership> instructorMemberships = this.loadInstructorMemberships();
		List<String> emails = new ArrayList<String>();
		for(CourseMembership instructor : instructorMemberships) {
			try {
				emails.add(UserDbLoader.Default.getInstance().loadById(instructor.getUserId()).getEmailAddress());
			} catch (Exception e) {
				emails.add("----ERROR LOADING EMAIL----");
			}
		}
		return emails;
	}
	
	public Map<String, String> loadInstructorInfo() throws KeyNotFoundException, PersistenceException {
		List<CourseMembership> instructorMemberships = this.loadInstructorMemberships();
		Map<String, String> info = new HashMap<String, String>();
		for(CourseMembership instructor : instructorMemberships) {
			try {
				User user = UserDbLoader.Default.getInstance().loadById(instructor.getUserId());
				info.put(user.getGivenName() + " " + user.getFamilyName(), user.getEmailAddress());
			} catch (Exception e) {
				info.put("Error", "----ERROR LOADING INSTRUCTOR INFO----");
			}
		}
		return info;
	}
	
	public List<CourseWrapper> loadChildren() 
			throws PersistenceException, Exception {
//		try {
			return CourseWrapper.loadChildCourseWrappersByParentCourse(this.course);
//		} catch (Exception e) {
//			throw new Exception("Unable to load CourseWrappers");
//		}
	}
	
	public String loadParentCourseId () {
		String id = "";
		if (this.isChild) {
			try {
				id =  CourseDbLoader.Default.getInstance().loadById(CourseCourseDbLoader.Default.getInstance().loadParent(this.id).getParentCourseId()).getCourseId();
			} catch (KeyNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (PersistenceException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return id;
	}
	
	public static List<CourseWrapper> loadCourseWrappersByUser(User user) 
			throws KeyNotFoundException, PersistenceException, ToolSettingsException {
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
	
	public static List<CourseWrapper> loadByCourses(List<Course> courses) throws PersistenceException, ToolSettingsException {
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
