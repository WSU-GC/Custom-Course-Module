package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import blackboard.data.course.Course;
import blackboard.data.navigation.CourseToolSettings;
import blackboard.persist.SearchOperator;
import blackboard.persist.course.CourseDbLoader;
import blackboard.persist.course.CourseSearch;
import blackboard.platform.context.Context;
import blackboard.platform.context.ContextManager;
import blackboard.platform.context.ContextManagerFactory;
import blackboard.platform.plugin.PlugInUtil;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import edu.wsu.CourseWrapper;
import edu.wsu.CourseWrapperSerializer;
import blackboard.persist.navigation.*;

/**
 * Servlet implementation class ToolManager
 */
public class ToolManager extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	public static final String BASE_PATH = PlugInUtil.getUri("wsu", "wsu-custom-course-module", ""); 
	public static final Map<String, SearchOperator> searchOp;
	public static final Map<String, CourseSearch.SearchKey> searchKey;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ToolManager() {
        super();
        // TODO Auto-generated constructor stub
    }
    
    static {
    	searchOp = new HashMap<String, SearchOperator>();
    	searchOp.put("contains", SearchOperator.Contains);
    	searchOp.put("equals", SearchOperator.Equals);
    	searchOp.put("notblank", SearchOperator.NotBlank);
    	searchOp.put("startswith", SearchOperator.StartsWith);
    	searchOp.put("greaterthan", SearchOperator.GreaterThan);
    	searchOp.put("lessthan", SearchOperator.LessThan);
    	
    	searchKey = new HashMap<String, CourseSearch.SearchKey>();
    	searchKey.put("coursedescription", CourseSearch.SearchKey.CourseDescription);
    	searchKey.put("courseid", CourseSearch.SearchKey.CourseId);
    	searchKey.put("coursename", CourseSearch.SearchKey.CourseName);
    	searchKey.put("term", CourseSearch.SearchKey.Term);
    	searchKey.put("instructor", CourseSearch.SearchKey.Instructor);
    	searchKey.put("datecreated", CourseSearch.SearchKey.DateCreated);
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		try {
			ContextManager contextManager = ContextManagerFactory.getInstance();
			Context ctx = contextManager.getContext();
			CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
			CourseSearch courseSearch = new CourseSearch();
			
			String searchTerm = request.getParameter("search");
			String so = request.getParameter("operator");
			String sk = request.getParameter("key");
			String toolId = request.getParameter("tool-id");
			

			CourseSearch.SearchKey key = searchKey.get(sk);
			SearchOperator operator = searchOp.get(so);
			
			CourseSearch.SearchParameter param = new CourseSearch.SearchParameter(key, searchTerm, operator);
			
			courseSearch.addParameter(param);
			
			List<Course> courses = courseLoader.loadByCourseSearch(courseSearch);
			
			ToolSettingsManager toolManager = ToolSettingsManagerFactory.getInstance();
			
			for (Course course: courses) {
				
			}
			
			
			Gson gson = new GsonBuilder()
			.registerTypeAdapter(CourseWrapper.class, new CourseWrapperSerializer()).create();
			
			List<CourseWrapper> courseWrappers = CourseWrapper.loadByCourses(courses);
			
			String jsonResponse = gson.toJson(courseWrappers);
			
			response.setContentType("application/json");
	        PrintWriter writer = response.getWriter();
	        writer.print(jsonResponse);
			
		} catch (Exception e) {
			response.setContentType("application/json");
	        PrintWriter writer = response.getWriter();
	        writer.print("Error: " + e.getMessage());
		}
	}

}
