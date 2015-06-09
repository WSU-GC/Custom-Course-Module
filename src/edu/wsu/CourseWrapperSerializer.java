package edu.wsu;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

import blackboard.persist.KeyNotFoundException;
import blackboard.persist.PersistenceException;
import blackboard.platform.plugin.PlugInUtil;
import helper.buildingblock.BuildingBlockHelper;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;

public class CourseWrapperSerializer implements JsonSerializer<CourseWrapper> {

	public JsonElement serialize(final CourseWrapper cw, final Type type,
			final JsonSerializationContext context) {
		
		Gson plainGson = new Gson();
		
		Gson gson = new GsonBuilder()
			.registerTypeAdapter(CourseWrapper.class, new CourseWrapperSerializer()).create();
		
		// TODO Auto-generated method stub
		JsonObject result = new JsonObject();
		result.add("coursePkId", new JsonPrimitive(cw.coursePkId));
		result.add("courseId", new JsonPrimitive(cw.courseId));
		result.add("courseBatchUid", new JsonPrimitive(cw.courseBatchUid));
		result.add("title", new JsonPrimitive(cw.title));
		result.add("isAvailable", new JsonPrimitive(cw.isAvailable));
		result.add("isRoster", new JsonPrimitive(cw.isRoster));
		result.add("isOnline", new JsonPrimitive(cw.isOnline));
		result.add("isParent", new JsonPrimitive(cw.isParent));
		result.add("isChild", new JsonPrimitive(cw.isChild));
		result.add("parent", new JsonPrimitive(cw.parent));
		result.addProperty("cvUri", "http://cdpemoss.wsu.edu/_layouts/CDPE/CourseVerification/Version08/Summary.aspx?pk1=" + cw.courseId);
		result.addProperty("disableUri", BuildingBlockHelper.getBaseUrl() + "Disable?course-id=" + cw.courseId);
		result.addProperty("displayTitle", cw.title + " (" + cw.courseId + ")");
		result.addProperty("enableUri", BuildingBlockHelper.getBaseUrl() + "Enable?course-id=" + cw.courseId);
		result.addProperty("unmergeUri", BuildingBlockHelper.getBaseUrl() + "Remove?parent-course=" + cw.parent + "&child-course=" + cw.courseId);
		result.addProperty("activateUri", BuildingBlockHelper.getBaseUrl() + "Activate?course-id=" + cw.courseId + "&title=" + cw.title);
		result.addProperty("accessUri", "/webapps/blackboard/execute/launcher?type=Course&url=&id=" + cw.coursePkId);
		result.addProperty("isUsingCourseVerification", cw.isUsingCourseVerification);
		result.add("tool", new JsonPrimitive(cw.tool));
		try {
			result.add("instructorEmails", plainGson.toJsonTree(cw.loadInstructorInfo()));
		} catch (Exception e2) {
			// TODO Auto-generated catch block
			result.addProperty("instructorEmails", "falied");
		} 
		try {
			result.add("enrl", new JsonPrimitive(cw.loadMemberships().size()));
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
			result.add("children", gson.toJsonTree(cw.loadChildren()));
			//result.add("children", new JsonPrimitive(gson.toJson(cw.loadChildren())));
			//result.addProperty("children", gson.toJson(cw.loadChildren()));
		} catch (Exception e) {
			List<String> children = new ArrayList<String>();
			children.add("Unable to load child course for " + cw.courseId);
			// TODO Auto-generated catch block
			result.add("Children", new Gson().toJsonTree(children));
		}
		return result;
	}

}
