package com.company.lms.controller;

import com.company.lms.dao.*;
import com.company.lms.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;

public class UpdateLeaveRequestServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(UpdateLeaveRequestServlet.class);
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
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        Employee user = (Employee) session.getAttribute("user");
        request.setCharacterEncoding("UTF-8");
        
        try {
            int requestId = Integer.parseInt(request.getParameter("requestId"));
            LeaveRequest oldRequest = leaveRequestDAO.getLeaveRequestById(requestId);
            
            if (oldRequest == null) {
                session.setAttribute("error", "Không tìm thấy đơn!");
                response.sendRedirect(request.getContextPath() + "/request/list");
                return;
            }
            
            int roleLevel = roleDAO.getHighestRoleLevel(user.getEmployeeID());
            
            // Kiểm tra quyền sửa
            boolean canEdit = false;
            if (roleLevel <= 2) {
                // CEO/Manager: sửa được tất cả
                canEdit = true;
            } else if (roleLevel == 3) {
                // Team Lead: sửa đơn của nhân viên dưới quyền
                Employee requestEmployee = employeeDAO.getEmployeeById(oldRequest.getEmployeeID());
                canEdit = (requestEmployee != null && requestEmployee.getManagerID() != null && 
                          requestEmployee.getManagerID() == user.getEmployeeID());
            } else {
                // Employee: chỉ sửa đơn InProgress của mình
                canEdit = (oldRequest.getEmployeeID() == user.getEmployeeID() && 
                          "InProgress".equals(oldRequest.getStatus()));
            }
            
            if (!canEdit) {
                session.setAttribute("error", "Bạn không có quyền sửa đơn này!");
                response.sendRedirect(request.getContextPath() + "/request/detail?id=" + requestId);
                return;
            }
            
            // Lấy thông tin từ form
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            String reasonTemplateIdStr = request.getParameter("reasonTemplateId");
            String customReason = request.getParameter("customReason");
            String newStatus = request.getParameter("newStatus");
            String updateNote = request.getParameter("updateNote");
            
            // Gọi stored procedure
            String sql = "{CALL sp_UpdateLeaveRequest(?, ?, ?, ?, ?, ?, ?, ?)}";
            
            try (Connection conn = com.company.lms.util.DatabaseConnection.getConnection();
                 CallableStatement stmt = conn.prepareCall(sql)) {
                
                stmt.setInt(1, requestId);
                stmt.setInt(2, user.getEmployeeID());
                
                // StartDate
                if (startDateStr != null && !startDateStr.isEmpty()) {
                    stmt.setDate(3, Date.valueOf(startDateStr));
                } else {
                    stmt.setNull(3, Types.DATE);
                }
                
                // EndDate
                if (endDateStr != null && !endDateStr.isEmpty()) {
                    stmt.setDate(4, Date.valueOf(endDateStr));
                } else {
                    stmt.setNull(4, Types.DATE);
                }
                
                // ReasonTemplateID
                if (reasonTemplateIdStr != null && !reasonTemplateIdStr.isEmpty() && !"0".equals(reasonTemplateIdStr)) {
                    stmt.setInt(5, Integer.parseInt(reasonTemplateIdStr));
                } else {
                    stmt.setNull(5, Types.INTEGER);
                }
                
                // CustomReason
                if (customReason != null && !customReason.isEmpty()) {
                    stmt.setString(6, customReason);
                } else {
                    stmt.setNull(6, Types.NVARCHAR);
                }
                
                // NewStatus (chỉ cấp trên mới sửa được)
                if (roleLevel <= 2 && newStatus != null && !newStatus.isEmpty()) {
                    stmt.setString(7, newStatus);
                } else {
                    stmt.setNull(7, Types.VARCHAR);
                }
                
                // UpdateNote
                if (updateNote != null && !updateNote.isEmpty()) {
                    stmt.setString(8, updateNote);
                } else {
                    stmt.setNull(8, Types.NVARCHAR);
                }
                
                stmt.execute();
                
                session.setAttribute("success", "Cập nhật đơn thành công!");
                response.sendRedirect(request.getContextPath() + "/request/detail?id=" + requestId);
                
            }
            
        } catch (Exception e) {
            logger.error("Error updating leave request", e);
            session.setAttribute("error", "Lỗi: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/request/list");
        }
    }
}