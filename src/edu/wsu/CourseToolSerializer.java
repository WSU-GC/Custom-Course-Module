package edu.wsu;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

import blackboard.persist.KeyNotFoundException;
import blackboard.persist.PersistenceException;
import blackboard.platform.plugin.PlugInUtil;
import helper.buildingblock.BuildingBlockHelper;
import blackboard.data.navigation.*;
import blackboard.persist.navigation.*;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;

public class CourseToolSerializer implements JsonSerializer<ToolSettings> {

	public JsonElement serialize(final ToolSettings cts, final Type type,
			final JsonSerializationContext context) {
		
		Gson plainGson = new Gson();
		
		Gson gson = new GsonBuilder()
			.registerTypeAdapter(CourseWrapper.class, new CourseWrapperSerializer()).create();
		
		// TODO Auto-generated method stub
		JsonObject result = new JsonObject();
		
		try {
		 	result.addProperty("id", cts.getApplicationId().toExternalString());
		 	result.addProperty("label", cts.getApplicationLabel());
		 	result.addProperty("identifier", cts.getIdentifier());
		 	result.addProperty("type", cts.getType().toString());
		 	result.addProperty("handle", cts.getContentHandler().getHandle());
		} catch (Exception ex) {
			
		}
		
		return result;
	}

}
