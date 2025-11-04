package com.company.lms.controller;

import com.company.lms.dao.LeaveRequestDAO;
import com.company.lms.model.Employee;
import com.company.lms.model.LeaveRequest;
import com.company.lms.service.EmployeeService;
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
    private EmployeeService employeeService;
    
    @Override
    public void init() throws ServletException {
        leaveRequestDAO = new LeaveRequestDAO();
        employeeService = new EmployeeService();
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
        
        // KIỂM TRA QUYỀN: Chỉ Manager mới được xem danh sách đơn chờ duyệt
        if (!employeeService.isSeniorManagement(user.getEmployeeID())) {
    logger.warn("Unauthorized access attempt to pending requests by employee: {}", user.getEmployeeID());
    session.setAttribute("error", "Bạn không có quyền truy cập trang này! Chỉ quản lý cấp cao (Level 1-2) mới có thể xem và duyệt đơn.");
    response.sendRedirect(request.getContextPath() + "/home");
    return;
}
        
        // Lấy tất cả đơn có trạng thái InProgress
        List<LeaveRequest> pendingRequests = leaveRequestDAO.getPendingLeaveRequests();
        
        request.setAttribute("pendingRequests", pendingRequests);
        request.getRequestDispatcher("/request/pending.jsp").forward(request, response);
    }
}