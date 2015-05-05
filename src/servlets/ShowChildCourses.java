package servlets;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;

import blackboard.data.role.PortalRole;
import blackboard.data.user.User;
import blackboard.persist.role.PortalRoleDbLoader;
import blackboard.persist.user.UserDbLoader;
import blackboard.persist.user.UserDbPersister;

/**
 * Servlet implementation class ShowChildCourses
 */
public class ShowChildCourses extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ShowChildCourses() {
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
			String userId = request.getParameter("user-id");
			String showChildren = request.getParameter("show-child-courses");
			
			User user = UserDbLoader.Default.getInstance().loadByBatchUid(userId);
			user.setBusinessPhone1(showChildren);
			
			UserDbPersister.Default.getInstance().persist(user);
			
			response.setContentType("application/json");
	        PrintWriter writer = response.getWriter();
	        writer.print("{\"result\": \"success\"}");
	        
	        
		} catch (Exception e) {
			throw new ServletException(e.getMessage());
		}
	}

}
