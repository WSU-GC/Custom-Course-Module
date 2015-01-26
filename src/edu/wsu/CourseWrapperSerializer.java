package edu.wsu;

import java.lang.reflect.Type;

import blackboard.persist.KeyNotFoundException;
import blackboard.persist.PersistenceException;
import blackboard.platform.plugin.PlugInUtil;

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
		
		String moduleBasePath = PlugInUtil.getUri("wsu", "wsu-custom-course-module", "") + "module/";
		
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
		result.addProperty("disableUri", moduleBasePath + "disable.jsp?course-id=" + cw.courseId);
		result.addProperty("displayTitle", cw.title + "(" + cw.courseId + ")");
		result.addProperty("enableUri", moduleBasePath + "enable.jsp?course-id=" + cw.courseId);
		result.addProperty("unmergeUri", moduleBasePath + "remove.jsp?parent-course=" + cw.parent + "&child-course=" + cw.courseId);
		result.addProperty("activateUri", moduleBasePath + "activate.jsp?course-id=" + cw.courseId + "&title=" + cw.title);
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
		} catch (PersistenceException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return result;
	}

}
