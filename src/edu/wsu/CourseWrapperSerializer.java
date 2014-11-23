package edu.wsu;

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

public class CourseWrapperSerializer implements JsonSerializer<CourseWrapper> {

	public JsonElement serialize(final CourseWrapper cw, final Type type,
			final JsonSerializationContext context) {
		
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
		try {
			result.add("enrl", new JsonPrimitive(cw.loadMemberships().size()));
		} catch (KeyNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (PersistenceException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		try {
			result.addProperty("children", gson.toJson(cw.loadChildren()));
		} catch (PersistenceException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return result;
	}

}
