package com.company.lms.controller;

import com.company.lms.dao.LeaveRequestDAO;
import com.company.lms.dao.EmployeeDAO;
import com.company.lms.model.Employee;
import com.company.lms.model.LeaveRequest;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.sql.*;
import java.util.List;

public class HomeServlet extends HttpServlet {
    
    private static final Logger logger = LoggerFactory.getLogger(HomeServlet.class);
    private LeaveRequestDAO leaveRequestDAO;
    private EmployeeDAO employeeDAO;
    
    @Override
    public void init() throws ServletException {
        leaveRequestDAO = new LeaveRequestDAO();
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
            // 1. Lấy số đơn đã duyệt
            int approvedCount = leaveRequestDAO.countLeaveRequestsByStatus(
                user.getEmployeeID(), "Approved");
            
            // 2. Lấy số đơn đang chờ
            int pendingCount = leaveRequestDAO.countLeaveRequestsByStatus(
                user.getEmployeeID(), "InProgress");
            
            // 3. Lấy thông tin leave quota (ngày phép còn lại và đã sử dụng)
            DashboardStats stats = getLeaveQuotaStats(user.getEmployeeID());
            
            // Set attributes để JSP hiển thị
            request.setAttribute("approvedCount", approvedCount);
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("remainingDays", stats.remainingDays);
            request.setAttribute("usedDays", stats.usedDays);
            request.setAttribute("totalDays", stats.totalDays);
            
            logger.info("Dashboard loaded for user {}: approved={}, pending={}, remaining={}, used={}", 
                       user.getUsername(), approvedCount, pendingCount, 
                       stats.remainingDays, stats.usedDays);
            
        } catch (Exception e) {
            logger.error("Error loading dashboard statistics", e);
            // Set default values nếu có lỗi
            request.setAttribute("approvedCount", 0);
            request.setAttribute("pendingCount", 0);
            request.setAttribute("remainingDays", 0);
            request.setAttribute("usedDays", 0);
            request.setAttribute("totalDays", 0);
        }
        
        request.getRequestDispatcher("/home.jsp").forward(request, response);
    }
    
    /**
     * Lấy thông tin leave quota từ database
     */
    private DashboardStats getLeaveQuotaStats(int employeeId) {
        DashboardStats stats = new DashboardStats();
        
        // Query để lấy tổng remaining days và used days từ LeaveQuotas
        String sql = "SELECT " +
                    "    ISNULL(SUM(RemainingDays), 0) as TotalRemaining, " +
                    "    ISNULL(SUM(UsedDays), 0) as TotalUsed, " +
                    "    ISNULL(SUM(TotalDays), 0) as TotalAllocation " +
                    "FROM LeaveQuotas " +
                    "WHERE EmployeeID = ? AND Year = YEAR(GETDATE())";
        
        try (Connection conn = com.company.lms.util.DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                stats.remainingDays = rs.getInt("TotalRemaining");
                stats.usedDays = rs.getInt("TotalUsed");
                stats.totalDays = rs.getInt("TotalAllocation");
            }
            
        } catch (SQLException e) {
            logger.error("Error getting leave quota stats", e);
        }
        
        return stats;
    }
    
    /**
     * Inner class để lưu dashboard statistics
     */
    private static class DashboardStats {
        int remainingDays = 0;
        int usedDays = 0;
        int totalDays = 0;
    }
}