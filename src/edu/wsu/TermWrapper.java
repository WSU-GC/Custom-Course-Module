package edu.wsu;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TermWrapper {
	
	public Map<String, List<CMWrapper>> terms = new HashMap<String, List<CMWrapper>>();

	public TermWrapper(List<CMWrapper> memberships) {
		
		Map<String, String> regExMapping = new HashMap<String, String>();
		/*regExMapping.put(".*2011.+(?i)spr.+", "2011 Spring");
		regExMapping.put(".*2011.+(?i)sum.+", "2011 Summer");
		regExMapping.put(".*2011.+(?i)fall.+", "2011 Fall");
		regExMapping.put(".*2012.+(?i)spr.+", "2012 Spring");
		regExMapping.put(".*2012.+(?i)sum.+", "2012 Summer");
		regExMapping.put(".*2012.+(?i)fall.+", "2012 Fall");
		regExMapping.put(".*2013.+(?i)spr.+", "2013 Spring");
		regExMapping.put(".*2013.+(?i)sum.+", "2013 Summer");
		regExMapping.put(".*2013.+(?i)fall.+", "2013 Fall");
		regExMapping.put(".*2014.+(?i)spr.+", "2014 Spring");
		regExMapping.put(".*2014.+(?i)sum.+", "2014 Summer");
		regExMapping.put(".*2014.+(?i)fall.+", "2014 Fall");
		regExMapping.put(".*2015.+(?i)spr.+", "2015 Spring");
		regExMapping.put(".*2015.+(?i)sum.+", "2015 Summer");
		regExMapping.put(".*2015.+(?i)fall.+", "2015 Fall");*/
		
		int year = Calendar.getInstance().get(Calendar.YEAR) + 2;
		int numYears = 7;
		int numSemesters = 3;
		ArrayList<String> semesters = new ArrayList<String>();
		ArrayList<String> menu = new ArrayList<String>();
		semesters.add("fall");
		semesters.add("sum");
		semesters.add("spr");
		menu.add("Fall");
		menu.add("Summer");
		menu.add("Spring");
		
		for (int i = 0; i < numYears; i++) {
			for (int j = 0; j < numSemesters; j++) {
				String sem = semesters.get(j);
				String y = Integer.toString(year - i);
				String regex = ".*" + y + ".+(?i)" + sem + ".+";
				regExMapping.put(regex, y + " " + menu.get(j));
			}
		}
		
		for (CMWrapper membership : memberships) {
			boolean match = false;
			for (String regex : regExMapping.keySet()) {
				if (membership.course.courseId.matches(regex)) {
					if(!terms.containsKey(regExMapping.get(regex))) {
						terms.put(regExMapping.get(regex), new ArrayList<CMWrapper>());
					}
					terms.get(regExMapping.get(regex)).add(membership);
					match = true;
					break;
				}
			}
			if (!match) {
				if(!terms.containsKey("Continuous")) {
					terms.put("Continuous", new ArrayList<CMWrapper>());
				}
				terms.get("Continuous").add(membership);
			}
		}
	}
	
}
