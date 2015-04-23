package servlets;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import edu.wsu.CourseManagement;

/**
 * Servlet implementation class Waitlist
 */
public class Waitlist extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public Waitlist() {
        super();
        // TODO Auto-generated constructor stub
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
			String courseID = request.getParameter("course-id");
			String childID = "WAITLIST-" + courseID;
			String title = request.getParameter("title");

			CourseManagement.createCourseSpace(childID, childID, title, "CCM");

			CourseManagement.mergeCourses(courseID, new String[] {childID});
			
			response.sendRedirect("/");
			
		} catch (Exception e) {
			throw new ServletException(e.getMessage());
		}
	}

}
