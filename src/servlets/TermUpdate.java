package servlets;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;

import blackboard.data.user.*;
import blackboard.persist.user.*;
import blackboard.data.role.*;
import blackboard.persist.role.*;


/**
 * Servlet implementation class TermUpdate
 */
public class TermUpdate extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public TermUpdate() {
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
			String roleId = request.getParameter("role-id");
			String label = StringUtils.join(roleId.split("-"), " ");
			
			User user = UserDbLoader.Default.getInstance().loadByBatchUid(userId);
			try {
				PortalRole role = PortalRoleDbLoader.Default.getInstance().loadByRoleId(roleId);
				user.setPortalRole(role);
			} catch (Exception ex) {
				PortalRole pr = new PortalRole();
				pr.setDescription(roleId);
				pr.setRoleID(roleId);
				pr.setRoleName(label);
				PortalRoleDbPersister.Default.getInstance().persist(pr);
				
				PortalRole role = PortalRoleDbLoader.Default.getInstance().loadByRoleId(roleId);
				user.setPortalRole(role);
			}
			
			UserDbPersister.Default.getInstance().persist(user);
			
			response.setContentType("application/json");
	        PrintWriter writer = response.getWriter();
	        writer.print("{\"result\": \"success\"}");
	        
	        
		} catch (Exception e) {
			throw new ServletException(e.getMessage());
		}
		
	}

}
