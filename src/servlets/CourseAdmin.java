package servlets;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import blackboard.data.course.Course;
import blackboard.persist.course.CourseDbLoader;
import blackboard.platform.plugin.PlugInUtil;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import edu.wsu.CourseWrapper;
import edu.wsu.CourseWrapperSerializer;

/**
 * Servlet implementation class CourseAdmin
 */
public class CourseAdmin extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	public static final String BASE_PATH = PlugInUtil.getUri("wsu", "wsu-custom-course-module", ""); 
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CourseAdmin() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			CourseDbLoader courseLoader = CourseDbLoader.Default.getInstance();
			Gson gson = new GsonBuilder()
				.registerTypeAdapter(CourseWrapper.class, new CourseWrapperSerializer()).create();
			String courseId = request.getParameter("course-id");
			
			Course course = courseLoader.loadByCourseId(courseId);
			
			CourseWrapper cw = new CourseWrapper(course);
			
			String jsonResponse = gson.toJson(cw);
			
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
