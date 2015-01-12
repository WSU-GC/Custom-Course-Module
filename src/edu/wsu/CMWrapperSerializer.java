package edu.wsu;

import java.lang.reflect.Type;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;

public class CMWrapperSerializer implements JsonSerializer<CMWrapper> {

	public JsonElement serialize(final CMWrapper cm, final Type type,
			final JsonSerializationContext context) {
		// TODO Auto-generated method stub
		Gson gson = new GsonBuilder()
			.registerTypeAdapter(CourseWrapper.class, new CourseWrapperSerializer()).create();
		
		JsonObject result = new JsonObject();
		result.add("course", gson.toJsonTree(cm.course));
		//result.add("course", new JsonPrimitive(gson.toJson(cm.course)));
		//result.addProperty("course", gson.toJson(cm.course));
		result.add("role", new JsonPrimitive(cm.role));
		return result;
	}

}
