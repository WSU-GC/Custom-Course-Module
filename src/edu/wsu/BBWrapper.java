package edu.wsu;

import java.util.ArrayList;
import java.util.List;

import blackboard.data.course.Course;
import blackboard.data.course.CourseMembership;
import blackboard.data.user.User;
import blackboard.persist.Id;
import blackboard.persist.KeyNotFoundException;
import blackboard.persist.PersistenceException;
import blackboard.persist.course.CourseMembershipDbLoader;

public class BBWrapper {

	public User user;
	public List<Course> courses = new ArrayList<Course>();
	public String courseBasePath = "/webapps/blackboard/execute/launcher?type=Course&url=&id=";
	
	public BBWrapper() {
	}
	
	public BBWrapper(User user) {
		this.user = user;
	}
	
	public void setUser(User user) {
		this.user = user;
	}
	
	
	
}
