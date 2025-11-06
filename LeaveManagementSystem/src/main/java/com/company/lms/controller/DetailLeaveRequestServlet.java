package com.company.lms.controller;

import com.company.lms.dao.LeaveRequestDAO;
import com.company.lms.dao.RoleDAO;
import com.company.lms.dao.EmployeeDAO;
import com.company.lms.model.Employee;
import com.company.lms.model.LeaveRequest;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.io.IOException;

public class DetailLeaveRequestServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(DetailLeaveRequestServlet.class);
    private LeaveRequestDAO leaveRequestDAO;
    private RoleDAO roleDAO;
    private EmployeeDAO employeeDAO;
    
    @Override
    public void init() throws ServletException {
        leaveRequestDAO = new LeaveRequestDAO();
        roleDAO = new RoleDAO();
        employeeDAO = new EmployeeDAO();
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
            String requestIdParam = request.getParameter("id");
            if (requestIdParam == null || requestIdParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/request/list");
                return;
            }
            
            int requestId = Integer.parseInt(requestIdParam);
            LeaveRequest leaveRequest = leaveRequestDAO.getLeaveRequestById(requestId);
            
            if (leaveRequest == null) {
                session.setAttribute("error", "Không tìm thấy đơn nghỉ phép!");
                response.sendRedirect(request.getContextPath() + "/request/list");
                return;
            }
            
            // ✅ FIX: Kiểm tra quyền xem
            int roleLevel = roleDAO.getHighestRoleLevel(user.getEmployeeID());
            boolean canView = false;
            
            if (roleLevel <= 1) {
                // CEO/Admin: xem tất cả
                canView = true;
            } else if (roleLevel == 2) {
                // Manager: xem trong phòng ban
                Employee requestEmployee = employeeDAO.getEmployeeById(leaveRequest.getEmployeeID());
                canView = (requestEmployee != null && requestEmployee.getDivisionID() == user.getDivisionID());
            } else if (roleLevel == 3) {
                // Team Lead: xem nhân viên dưới quyền hoặc của mình
                Employee requestEmployee = employeeDAO.getEmployeeById(leaveRequest.getEmployeeID());
                canView = (leaveRequest.getEmployeeID() == user.getEmployeeID()) ||
                         (requestEmployee != null && requestEmployee.getManagerID() != null && 
                          requestEmployee.getManagerID() == user.getEmployeeID());
            } else {
                // Employee: chỉ xem của mình
                canView = (leaveRequest.getEmployeeID() == user.getEmployeeID());
            }
            
            if (!canView) {
                logger.warn("Access denied: User {} tried to view request {}", user.getEmployeeID(), requestId);
                session.setAttribute("error", "Bạn không có quyền xem đơn này!");
                response.sendRedirect(request.getContextPath() + "/request/list");
                return;
            }
            
            request.setAttribute("leaveRequest", leaveRequest);
            request.getRequestDispatcher("/request/detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            logger.error("Invalid request ID format", e);
            session.setAttribute("error", "ID đơn không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/request/list");
        } catch (Exception e) {
            logger.error("Error loading leave request detail", e);
            session.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/request/list");
        }
    }
}