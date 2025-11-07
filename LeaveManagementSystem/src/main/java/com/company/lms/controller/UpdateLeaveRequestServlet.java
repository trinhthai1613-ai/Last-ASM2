package com.company.lms.controller;

import com.company.lms.dao.*;
import com.company.lms.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.io.IOException;
import java.sql.*;
import java.time.Duration;
import java.time.LocalDateTime;

public class UpdateLeaveRequestServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(UpdateLeaveRequestServlet.class);
    private LeaveRequestDAO leaveRequestDAO;
    private RoleDAO roleDAO;
    
    @Override
    public void init() throws ServletException {
        leaveRequestDAO = new LeaveRequestDAO();
        roleDAO = new RoleDAO();
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
            
            // ✅ KIỂM TRA 1H LIMIT (cho tất cả)
            LocalDateTime createdAt = oldRequest.getCreatedAt();
            LocalDateTime now = LocalDateTime.now();
            long minutesPassed = Duration.between(createdAt, now).toMinutes();
            
            if (minutesPassed > 60) {
                session.setAttribute("error", "Không thể sửa đơn sau 1 giờ kể từ lúc tạo!");
                response.sendRedirect(request.getContextPath() + "/request/detail?id=" + requestId);
                return;
            }
            
            int roleLevel = roleDAO.getHighestRoleLevel(user.getEmployeeID());
            String actionType = request.getParameter("actionType"); // "employee" hoặc "manager"
            
            // ===== PHÂN QUYỀN RÕ RÀNG =====
            if ("manager".equals(actionType)) {
                // ✅ CẤP TRÊN: CHỈ sửa trạng thái + ghi chú
                if (roleLevel > 2) {
                    session.setAttribute("error", "Bạn không có quyền duyệt đơn!");
                    response.sendRedirect(request.getContextPath() + "/request/detail?id=" + requestId);
                    return;
                }
                
                String newStatus = request.getParameter("newStatus");
                String updateNote = request.getParameter("updateNote");
                
                if (newStatus == null || newStatus.isEmpty()) {
                    session.setAttribute("error", "Vui lòng chọn trạng thái mới!");
                    response.sendRedirect(request.getContextPath() + "/request/detail?id=" + requestId);
                    return;
                }
                
                // Gọi SP với CHỈ trạng thái + note
                String sql = "{CALL sp_UpdateLeaveRequest(?, ?, NULL, NULL, NULL, NULL, ?, ?)}";
                
                try (Connection conn = com.company.lms.util.DatabaseConnection.getConnection();
                     CallableStatement stmt = conn.prepareCall(sql)) {
                    
                    stmt.setInt(1, requestId);
                    stmt.setInt(2, user.getEmployeeID());
                    stmt.setString(3, newStatus);
                    
                    if (updateNote != null && !updateNote.isEmpty()) {
                        stmt.setString(4, updateNote);
                    } else {
                        stmt.setNull(4, Types.NVARCHAR);
                    }
                    
                    stmt.execute();
                    session.setAttribute("success", "Cập nhật trạng thái thành công!");
                }
                
            } else {
                // ✅ NHÂN VIÊN: Sửa thời gian + lý do (chỉ đơn InProgress của mình)
                if (oldRequest.getEmployeeID() != user.getEmployeeID()) {
                    session.setAttribute("error", "Bạn chỉ được sửa đơn của mình!");
                    response.sendRedirect(request.getContextPath() + "/request/detail?id=" + requestId);
                    return;
                }
                
                if (!"InProgress".equals(oldRequest.getStatus())) {
                    session.setAttribute("error", "Chỉ sửa được đơn đang chờ xử lý!");
                    response.sendRedirect(request.getContextPath() + "/request/detail?id=" + requestId);
                    return;
                }
                
                String startDateStr = request.getParameter("startDate");
                String endDateStr = request.getParameter("endDate");
                String reasonTemplateIdStr = request.getParameter("reasonTemplateId");
                String customReason = request.getParameter("customReason");
                String updateNote = request.getParameter("updateNote");
                
                // Gọi SP với thời gian + lý do
                String sql = "{CALL sp_UpdateLeaveRequest(?, ?, ?, ?, ?, ?, NULL, ?)}";
                
                try (Connection conn = com.company.lms.util.DatabaseConnection.getConnection();
                     CallableStatement stmt = conn.prepareCall(sql)) {
                    
                    stmt.setInt(1, requestId);
                    stmt.setInt(2, user.getEmployeeID());
                    
                    if (startDateStr != null && !startDateStr.isEmpty()) {
                        stmt.setDate(3, Date.valueOf(startDateStr));
                    } else {
                        stmt.setNull(3, Types.DATE);
                    }
                    
                    if (endDateStr != null && !endDateStr.isEmpty()) {
                        stmt.setDate(4, Date.valueOf(endDateStr));
                    } else {
                        stmt.setNull(4, Types.DATE);
                    }
                    
                    if (reasonTemplateIdStr != null && !reasonTemplateIdStr.isEmpty() && !"0".equals(reasonTemplateIdStr)) {
                        stmt.setInt(5, Integer.parseInt(reasonTemplateIdStr));
                    } else {
                        stmt.setNull(5, Types.INTEGER);
                    }
                    
                    if (customReason != null && !customReason.isEmpty()) {
                        stmt.setString(6, customReason);
                    } else {
                        stmt.setNull(6, Types.NVARCHAR);
                    }
                    
                    if (updateNote != null && !updateNote.isEmpty()) {
                        stmt.setString(7, updateNote);
                    } else {
                        stmt.setNull(7, Types.NVARCHAR);
                    }
                    
                    stmt.execute();
                    session.setAttribute("success", "Cập nhật đơn thành công!");
                }
            }
            
            response.sendRedirect(request.getContextPath() + "/request/detail?id=" + requestId);
            
        } catch (Exception e) {
            logger.error("Error updating leave request", e);
            session.setAttribute("error", "Lỗi: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/request/list");
        }
    }
}