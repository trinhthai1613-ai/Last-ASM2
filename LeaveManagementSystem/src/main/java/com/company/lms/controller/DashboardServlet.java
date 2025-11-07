package com.company.lms.controller;

import com.company.lms.dao.LeaveRequestDAO;
import com.company.lms.model.Employee;
import com.company.lms.service.EmployeeService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.io.IOException;
import java.sql.*;
import java.util.*;

public class DashboardServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(DashboardServlet.class);
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
        int roleLevel = employeeService.getLowestRoleLevel(user.getEmployeeID());
        
        if (roleLevel != 1) {
            session.setAttribute("error", "Bạn không có quyền truy cập!");
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        
        try {
            // 1. Thống kê theo tháng (12 tháng gần nhất)
            Map<String, Integer> monthlyStats = getMonthlyStats();
            
            // 2. Top 5 phòng ban nghỉ nhiều nhất
            List<DivisionStat> topDivisions = getTopDivisions();
            
            // 3. Tỷ lệ duyệt/từ chối
            Map<String, Integer> statusStats = getStatusStats();
            
            // 4. Xu hướng so với tháng trước
            Map<String, Object> trends = getTrends();
            
            request.setAttribute("monthlyStats", monthlyStats);
            request.setAttribute("topDivisions", topDivisions);
            request.setAttribute("statusStats", statusStats);
            request.setAttribute("trends", trends);
            
            logger.info("Dashboard loaded for CEO: {}", user.getUsername());
            
        } catch (Exception e) {
            logger.error("Error loading dashboard", e);
            request.setAttribute("error", "Có lỗi xảy ra khi tải dashboard");
        }
        
        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }
    
    private Map<String, Integer> getMonthlyStats() {
        Map<String, Integer> stats = new LinkedHashMap<>();
        String sql = "SELECT " +
                    "    FORMAT(CreatedAt, 'MM/yyyy') as MonthYear, " +
                    "    COUNT(*) as Total " +
                    "FROM LeaveRequests " +
                    "WHERE CreatedAt >= DATEADD(MONTH, -11, GETDATE()) " +
                    "GROUP BY FORMAT(CreatedAt, 'MM/yyyy'), YEAR(CreatedAt), MONTH(CreatedAt) " +
                    "ORDER BY YEAR(CreatedAt), MONTH(CreatedAt)";
        
        try (Connection conn = com.company.lms.util.DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                stats.put(rs.getString("MonthYear"), rs.getInt("Total"));
            }
            
        } catch (SQLException e) {
            logger.error("Error getting monthly stats", e);
        }
        
        return stats;
    }
    
    private List<DivisionStat> getTopDivisions() {
        List<DivisionStat> divisions = new ArrayList<>();
        String sql = "SELECT TOP 5 " +
                    "    d.DivisionName, " +
                    "    COUNT(lr.RequestID) as TotalRequests, " +
                    "    SUM(CASE WHEN lr.Status = 'Approved' THEN lr.TotalDays ELSE 0 END) as TotalDays " +
                    "FROM Divisions d " +
                    "INNER JOIN Employees e ON d.DivisionID = e.DivisionID " +
                    "INNER JOIN LeaveRequests lr ON e.EmployeeID = lr.EmployeeID " +
                    "WHERE lr.Status = 'Approved' " +
                    "  AND YEAR(lr.CreatedAt) = YEAR(GETDATE()) " +
                    "GROUP BY d.DivisionName " +
                    "ORDER BY TotalDays DESC";
        
        try (Connection conn = com.company.lms.util.DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                divisions.add(new DivisionStat(
                    rs.getString("DivisionName"),
                    rs.getInt("TotalRequests"),
                    rs.getDouble("TotalDays")
                ));
            }
            
        } catch (SQLException e) {
            logger.error("Error getting top divisions", e);
        }
        
        return divisions;
    }
    
    private Map<String, Integer> getStatusStats() {
        Map<String, Integer> stats = new LinkedHashMap<>();
        String sql = "SELECT Status, COUNT(*) as Total " +
                    "FROM LeaveRequests " +
                    "WHERE YEAR(CreatedAt) = YEAR(GETDATE()) " +
                    "GROUP BY Status";
        
        try (Connection conn = com.company.lms.util.DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                stats.put(rs.getString("Status"), rs.getInt("Total"));
            }
            
        } catch (SQLException e) {
            logger.error("Error getting status stats", e);
        }
        
        return stats;
    }
    
    private Map<String, Object> getTrends() {
        Map<String, Object> trends = new HashMap<>();
        String sql = "SELECT " +
                    "    SUM(CASE WHEN MONTH(CreatedAt) = MONTH(GETDATE()) THEN 1 ELSE 0 END) as ThisMonth, " +
                    "    SUM(CASE WHEN MONTH(CreatedAt) = MONTH(DATEADD(MONTH, -1, GETDATE())) THEN 1 ELSE 0 END) as LastMonth " +
                    "FROM LeaveRequests " +
                    "WHERE YEAR(CreatedAt) = YEAR(GETDATE())";
        
        try (Connection conn = com.company.lms.util.DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                int thisMonth = rs.getInt("ThisMonth");
                int lastMonth = rs.getInt("LastMonth");
                double change = lastMonth > 0 ? ((double)(thisMonth - lastMonth) / lastMonth * 100) : 0;
                
                trends.put("thisMonth", thisMonth);
                trends.put("lastMonth", lastMonth);
                trends.put("change", change);
                trends.put("isIncrease", change > 0);
            }
            
        } catch (SQLException e) {
            logger.error("Error getting trends", e);
        }
        
        return trends;
    }
    
    public static class DivisionStat {
        public String name;
        public int requests;
        public double days;
        
        public DivisionStat(String name, int requests, double days) {
            this.name = name;
            this.requests = requests;
            this.days = days;
        }
    }
}