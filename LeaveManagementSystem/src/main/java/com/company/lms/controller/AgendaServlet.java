package com.company.lms.controller;

import com.company.lms.dao.LeaveRequestDAO;
import com.company.lms.model.Employee;
import com.company.lms.model.LeaveRequest;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

public class AgendaServlet extends HttpServlet {
    
    private LeaveRequestDAO leaveRequestDAO;
    
    @Override
    public void init() throws ServletException {
        leaveRequestDAO = new LeaveRequestDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        Employee user = (Employee) session.getAttribute("user");
        
        try {
            // Get approved leave requests for calendar view
            List<LeaveRequest> approvedRequests = leaveRequestDAO.getApprovedLeavesByEmployee(user.getEmployeeId());
            request.setAttribute("leaveRequests", approvedRequests);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Không thể tải lịch nghỉ phép: " + e.getMessage());
        }
        
        // Forward to agenda page (you'll need to create this JSP)
        request.getRequestDispatcher("/agenda.jsp").forward(request, response);
    }
}