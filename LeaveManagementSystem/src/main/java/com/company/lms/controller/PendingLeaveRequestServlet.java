package com.company.lms.controller;

import com.company.lms.dao.LeaveRequestDAO;
import com.company.lms.model.Employee;
import com.company.lms.model.LeaveRequest;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.List;

@WebServlet("/request/pending")
public class PendingLeaveRequestServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(PendingLeaveRequestServlet.class);
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
        
        // Lấy tất cả đơn có trạng thái InProgress
        // TODO: Thêm logic kiểm tra quyền - chỉ Manager/CEO mới được xem
        List<LeaveRequest> pendingRequests = leaveRequestDAO.getPendingLeaveRequests();
        
        request.setAttribute("pendingRequests", pendingRequests);
        request.getRequestDispatcher("/request/pending.jsp").forward(request, response);
    }
}