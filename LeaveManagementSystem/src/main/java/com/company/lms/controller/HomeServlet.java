package com.company.lms.controller;

import com.company.lms.dao.LeaveRequestDAO;
import com.company.lms.dao.EmployeeDAO;
import com.company.lms.model.Employee;
import com.company.lms.service.EmployeeService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.sql.*;

public class HomeServlet extends HttpServlet {
    
    private static final Logger logger = LoggerFactory.getLogger(HomeServlet.class);
    private LeaveRequestDAO leaveRequestDAO;
    private EmployeeDAO employeeDAO;
    private EmployeeService employeeService;
    
    @Override
    public void init() throws ServletException {
        leaveRequestDAO = new LeaveRequestDAO();
        employeeDAO = new EmployeeDAO();
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
        int roleLevel = employeeService.getLowestRoleLevel(user.getEmployeeID());
        
        try {
            if (roleLevel == 1) {
                // CEO: Hiển thị thống kê toàn hệ thống
                int approvedCount = leaveRequestDAO.countAllLeaveRequestsByStatus("Approved");
                int pendingCount = leaveRequestDAO.countAllLeaveRequestsByStatus("InProgress");
                
                // Thống kê audit logs
                int auditLogCount = getAuditLogCount();
                int todayAuditLogCount = getTodayAuditLogCount();
                
                request.setAttribute("approvedCount", approvedCount);
                request.setAttribute("pendingCount", pendingCount);
                request.setAttribute("remainingDays", auditLogCount);
                request.setAttribute("usedDays", todayAuditLogCount);
                
                logger.info("CEO Dashboard loaded for user {}: approved={}, pending={}, auditLogs={}", 
                           user.getUsername(), approvedCount, pendingCount, auditLogCount);
            } else {
                // Nhân viên thường: Hiển thị thống kê cá nhân
                int approvedCount = leaveRequestDAO.countLeaveRequestsByStatus(
                    user.getEmployeeID(), "Approved");
                
                int pendingCount = leaveRequestDAO.countLeaveRequestsByStatus(
                    user.getEmployeeID(), "InProgress");
                
                DashboardStats stats = getLeaveQuotaStats(user.getEmployeeID());
                
                request.setAttribute("approvedCount", approvedCount);
                request.setAttribute("pendingCount", pendingCount);
                request.setAttribute("remainingDays", stats.remainingDays);
                request.setAttribute("usedDays", stats.usedDays);
                request.setAttribute("totalDays", stats.totalDays);
                
                logger.info("Dashboard loaded for user {}: approved={}, pending={}, remaining={}, used={}", 
                           user.getUsername(), approvedCount, pendingCount, 
                           stats.remainingDays, stats.usedDays);
            }
            
        } catch (Exception e) {
            logger.error("Error loading dashboard statistics", e);
            request.setAttribute("approvedCount", 0);
            request.setAttribute("pendingCount", 0);
            request.setAttribute("remainingDays", 0);
            request.setAttribute("usedDays", 0);
            request.setAttribute("totalDays", 0);
        }
        
        request.getRequestDispatcher("/home.jsp").forward(request, response);
    }
    
    private DashboardStats getLeaveQuotaStats(int employeeId) {
        DashboardStats stats = new DashboardStats();
        
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
    
    private int getAuditLogCount() {
        String sql = "SELECT COUNT(*) as TotalCount FROM AuditLogs";
        
        try (Connection conn = com.company.lms.util.DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("TotalCount");
            }
            
        } catch (SQLException e) {
            logger.error("Error getting audit log count", e);
        }
        
        return 0;
    }
    
    private int getTodayAuditLogCount() {
        String sql = "SELECT COUNT(*) as TodayCount FROM AuditLogs " +
                    "WHERE CAST(CreatedAt AS DATE) = CAST(GETDATE() AS DATE)";
        
        try (Connection conn = com.company.lms.util.DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("TodayCount");
            }
            
        } catch (SQLException e) {
            logger.error("Error getting today audit log count", e);
        }
        
        return 0;
    }
    
    private static class DashboardStats {
        int remainingDays = 0;
        int usedDays = 0;
        int totalDays = 0;
    }
}