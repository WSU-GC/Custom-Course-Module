package edu.wsu;

import helper.buildingblock.BuildingBlockHelper;

import java.lang.reflect.Type;

import blackboard.persist.KeyNotFoundException;
import blackboard.persist.PersistenceException;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;

import java.util.ArrayList;
import java.util.List;

public class CMWrapperSerializer implements JsonSerializer<CMWrapper> {

	public JsonElement serialize(final CMWrapper cm, final Type type,
			final JsonSerializationContext context) {
		// TODO Auto-generated method stub
		Gson gson = new GsonBuilder()
			.registerTypeAdapter(CMWrapper.class, new CMWrapperSerializer()).create();
		
		JsonObject result = new JsonObject();
		//result.add("course", gson.toJsonTree(cm.course));
		
		result.add("coursePkId", new JsonPrimitive(cm.course.coursePkId));
		result.add("courseId", new JsonPrimitive(cm.course.courseId));
		result.add("courseBatchUid", new JsonPrimitive(cm.course.courseBatchUid));
		result.add("title", new JsonPrimitive(cm.course.title));
		result.add("isAvailable", new JsonPrimitive(cm.course.isAvailable));
		result.add("isRoster", new JsonPrimitive(cm.course.isRoster));
		result.add("isOnline", new JsonPrimitive(cm.course.isOnline));
		result.add("isParent", new JsonPrimitive(cm.course.isParent));
		result.add("isChild", new JsonPrimitive(cm.course.isChild));
		result.add("parent", new JsonPrimitive(cm.course.parent));
		result.addProperty("cvUri", "http://cdpemoss.wsu.edu/_layouts/CDPE/CourseVerification/Version08/Summary.aspx?pk1=" + cm.course.courseId);
		result.addProperty("disableUri", BuildingBlockHelper.getBaseUrl() + "Disable?course-id=" + cm.course.courseId);
		result.addProperty("displayTitle", cm.course.title + " (" + cm.course.courseId + ")");
		result.addProperty("enableUri", BuildingBlockHelper.getBaseUrl() + "Enable?course-id=" + cm.course.courseId);
		result.addProperty("unmergeUri", BuildingBlockHelper.getBaseUrl() + "Remove?parent-course=" + cm.course.parent + "&child-course=" + cm.course.courseId);
		result.addProperty("activateUri", BuildingBlockHelper.getBaseUrl() + "Activate?course-id=" + cm.course.courseId + "&title=" + cm.course.title);
		result.addProperty("accessUri", "/webapps/blackboard/execute/launcher?type=Course&url=&id=" + cm.course.coursePkId);
		try {
			result.add("enrl", new JsonPrimitive(cm.course.loadMemberships().size()));
		} catch (KeyNotFoundException e1) {
			// TODO Auto-generated catch block
			result.add("enrl", new JsonPrimitive(0));
			e1.printStackTrace();
		} catch (PersistenceException e1) {
			result.add("enrl", new JsonPrimitive(0));
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		try {
			result.add("children", gson.toJsonTree(cm.loadChildren()));
			//result.add("children", new JsonPrimitive(gson.toJson(cw.loadChildren())));
			//result.addProperty("children", gson.toJson(cw.loadChildren()));
		} catch (Exception e) {
			List<String> children = new ArrayList<String>();
			children.add("Unable to load child course for " + cm.course.courseId);
			// TODO Auto-generated catch block
			result.add("Children", new Gson().toJsonTree(children));
		}
		
		result.addProperty("isSecondaryInstructor", cm.role.equalsIgnoreCase("si") || cm.role.equalsIgnoreCase("scb"));
		result.addProperty("isInstructor", cm.role.equalsIgnoreCase("si") || cm.role.equalsIgnoreCase("scb") 
				|| cm.role.equalsIgnoreCase("instructor") || cm.role.equalsIgnoreCase("pcb") || cm.role.equalsIgnoreCase("support") 
				|| cm.role.equalsIgnoreCase("course_editor"));
		result.add("role", new JsonPrimitive(cm.role));
		return result;
	}

}
