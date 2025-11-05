package com.company.lms.dao;

import com.company.lms.model.LeaveRequest;
import com.company.lms.util.DatabaseConnection;
import org.slf4j.Logger;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.LoggerFactory;

public class LeaveRequestDAO {
    private static final Logger logger = LoggerFactory.getLogger(LeaveRequestDAO.class);
    
    public boolean createLeaveRequest(LeaveRequest request) {
        String sql = "{CALL sp_CreateLeaveRequest(?, ?, ?, ?, ?, ?, ?)}";
        
        try (Connection conn = DatabaseConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {
            
            stmt.setInt(1, request.getEmployeeID());
            stmt.setInt(2, request.getLeaveTypeID());
            stmt.setDate(3, Date.valueOf(request.getStartDate()));
            stmt.setDate(4, Date.valueOf(request.getEndDate()));
            
            if (request.getReasonTemplateID() != null) {
                stmt.setInt(5, request.getReasonTemplateID());
            } else {
                stmt.setNull(5, Types.INTEGER);
            }
            
            if (request.getCustomReason() != null && !request.getCustomReason().isEmpty()) {
                stmt.setString(6, request.getCustomReason());
            } else {
                stmt.setNull(6, Types.NVARCHAR);
            }
            
            if (request.getAttachmentPath() != null && !request.getAttachmentPath().isEmpty()) {
                stmt.setString(7, request.getAttachmentPath());
            } else {
                stmt.setNull(7, Types.VARCHAR);
            }
            
            stmt.execute();
            logger.info("Leave request created successfully");
            return true;
            
        } catch (SQLException e) {
            logger.error("Error creating leave request", e);
            return false;
        }
    }
    
    public List<LeaveRequest> getLeaveRequests(int employeeID, String status) {
        List<LeaveRequest> requests = new ArrayList<>();
        String sql = "{CALL sp_GetLeaveRequests(?, ?)}";
        
        try (Connection conn = DatabaseConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {
            
            stmt.setInt(1, employeeID);
            if (status != null && !status.isEmpty()) {
                stmt.setString(2, status);
            } else {
                stmt.setNull(2, Types.VARCHAR);
            }
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                requests.add(extractLeaveRequestFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            logger.error("Error getting leave requests", e);
        }
        
        return requests;
    }
    public List<LeaveRequest> getFilteredLeavesByDivisionAndDateRange(
        int divisionID, LocalDate startDate, LocalDate endDate, 
        String searchName, String searchReason, String statusFilter) {
    
    List<LeaveRequest> requests = new ArrayList<>();
    
    StringBuilder sql = new StringBuilder(
        "SELECT lr.*, e.FullName as EmployeeName, lt.LeaveTypeName " +
        "FROM LeaveRequests lr " +
        "INNER JOIN Employees e ON lr.EmployeeID = e.EmployeeID " +
        "LEFT JOIN LeaveTypes lt ON lr.LeaveTypeID = lt.LeaveTypeID " +
        "WHERE e.DivisionID = ? " +
        "  AND e.IsActive = 1 " +
        "  AND ((lr.StartDate >= ? AND lr.StartDate <= ?) " +
        "       OR (lr.EndDate >= ? AND lr.EndDate <= ?) " +
        "       OR (lr.StartDate <= ? AND lr.EndDate >= ?))"
    );
    
    // Dynamic filters
    if (searchName != null && !searchName.trim().isEmpty()) {
        sql.append(" AND e.FullName LIKE ?");
    }
    if (searchReason != null && !searchReason.trim().isEmpty()) {
        sql.append(" AND lr.Reason LIKE ?");
    }
    if (statusFilter != null && !statusFilter.trim().isEmpty()) {
        sql.append(" AND lr.Status = ?");
    }
    
    sql.append(" ORDER BY e.FullName, lr.StartDate");
    
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
        
        int paramIndex = 1;
        stmt.setInt(paramIndex++, divisionID);
        stmt.setDate(paramIndex++, Date.valueOf(startDate));
        stmt.setDate(paramIndex++, Date.valueOf(endDate));
        stmt.setDate(paramIndex++, Date.valueOf(startDate));
        stmt.setDate(paramIndex++, Date.valueOf(endDate));
        stmt.setDate(paramIndex++, Date.valueOf(startDate));
        stmt.setDate(paramIndex++, Date.valueOf(endDate));
        
        if (searchName != null && !searchName.trim().isEmpty()) {
            stmt.setString(paramIndex++, "%" + searchName.trim() + "%");
        }
        if (searchReason != null && !searchReason.trim().isEmpty()) {
            stmt.setString(paramIndex++, "%" + searchReason.trim() + "%");
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            stmt.setString(paramIndex++, statusFilter.trim());
        }
        
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            requests.add(extractLeaveRequestFromResultSet(rs));
        }
        
    } catch (SQLException e) {
        logger.error("Error getting filtered leaves", e);
    }
    
    return requests;
}
    
    /**
     * Lấy tất cả đơn nghỉ phép đang chờ xét duyệt (status = 'InProgress')
     * Dành cho Manager/CEO để duyệt đơn
     */
    public List<LeaveRequest> getPendingLeaveRequests() {
        List<LeaveRequest> requests = new ArrayList<>();
        String sql = "SELECT lr.*, e.FullName as EmployeeName, lt.LeaveTypeName " +
                    "FROM LeaveRequests lr " +
                    "LEFT JOIN Employees e ON lr.EmployeeID = e.EmployeeID " +
                    "LEFT JOIN LeaveTypes lt ON lr.LeaveTypeID = lt.LeaveTypeID " +
                    "WHERE lr.Status = 'InProgress' " +
                    "ORDER BY lr.CreatedAt DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                requests.add(extractLeaveRequestFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            logger.error("Error getting pending leave requests", e);
        }
        
        return requests;
    }
    
    public LeaveRequest getLeaveRequestById(int requestID) {
        String sql = "SELECT lr.*, e.FullName as EmployeeName, lt.LeaveTypeName, " +
                    "p.FullName as ProcessedByName " +
                    "FROM LeaveRequests lr " +
                    "LEFT JOIN Employees e ON lr.EmployeeID = e.EmployeeID " +
                    "LEFT JOIN LeaveTypes lt ON lr.LeaveTypeID = lt.LeaveTypeID " +
                    "LEFT JOIN Employees p ON lr.ProcessedBy = p.EmployeeID " +
                    "WHERE lr.RequestID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, requestID);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return extractLeaveRequestFromResultSet(rs);
            }
            
        } catch (SQLException e) {
            logger.error("Error getting leave request by ID", e);
        }
        
        return null;
    }
    
    public boolean processLeaveRequest(int requestID, int processedBy, String action, String note) {
        String sql = "{CALL sp_ProcessLeaveRequest(?, ?, ?, ?)}";
        
        try (Connection conn = DatabaseConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {
            
            stmt.setInt(1, requestID);
            stmt.setInt(2, processedBy);
            stmt.setString(3, action);
            
            if (note != null && !note.isEmpty()) {
                stmt.setString(4, note);
            } else {
                stmt.setNull(4, Types.NVARCHAR);
            }
            
            stmt.execute();
            logger.info("Leave request processed: ID={}, Action={}", requestID, action);
            return true;
            
        } catch (SQLException e) {
            logger.error("Error processing leave request", e);
            return false;
        }
    }
    
    /**
     * Extract LeaveRequest từ ResultSet
    
    /**
     * Lấy tất cả đơn nghỉ phép đã được duyệt của một nhân viên
     * Dùng để hiển thị trên calendar/agenda
     */
    public List<LeaveRequest> getApprovedLeavesByEmployee(int employeeID) {
        List<LeaveRequest> requests = new ArrayList<>();
        String sql = "SELECT lr.*, lt.LeaveTypeName " +
                    "FROM LeaveRequests lr " +
                    "LEFT JOIN LeaveTypes lt ON lr.LeaveTypeID = lt.LeaveTypeID " +
                    "WHERE lr.EmployeeID = ? AND lr.Status = 'Approved' " +
                    "ORDER BY lr.StartDate DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeID);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                requests.add(extractLeaveRequestFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            logger.error("Error getting approved leaves by employee", e);
        }
        
        return requests;
    }
   
    private LeaveRequest extractLeaveRequestFromResultSet(ResultSet rs) throws SQLException {
        LeaveRequest request = new LeaveRequest();
        
        // Các cột BẮT BUỘC
        request.setRequestID(rs.getInt("RequestID"));
        request.setRequestCode(rs.getString("RequestCode"));
        
        // EmployeeID - có thể không có trong một số query
        try {
            request.setEmployeeID(rs.getInt("EmployeeID"));
        } catch (SQLException e) {
            // Column might not exist
        }
        
        // LeaveTypeID - có thể không có trong một số query
        try {
            request.setLeaveTypeID(rs.getInt("LeaveTypeID"));
        } catch (SQLException e) {
            // Column might not exist
        }
        
        if (rs.getDate("StartDate") != null) {
            request.setStartDate(rs.getDate("StartDate").toLocalDate());
        }
        
        if (rs.getDate("EndDate") != null) {
            request.setEndDate(rs.getDate("EndDate").toLocalDate());
        }
        
        request.setTotalDays(rs.getBigDecimal("TotalDays"));
        
        // ReasonTemplateID - có thể không có
        try {
            int templateID = rs.getInt("ReasonTemplateID");
            if (!rs.wasNull()) {
                request.setReasonTemplateID(templateID);
            }
        } catch (SQLException e) {
            // Column might not exist
        }
        
        // CustomReason - có thể không có
        try {
            request.setCustomReason(rs.getString("CustomReason"));
        } catch (SQLException e) {
            // Column might not exist
        }
        
        request.setReason(rs.getString("Reason"));
        request.setStatus(rs.getString("Status"));
        
        // ProcessedBy - có thể không có
        try {
            int processedBy = rs.getInt("ProcessedBy");
            if (!rs.wasNull()) {
                request.setProcessedBy(processedBy);
            }
        } catch (SQLException e) {
            // Column might not exist
        }
        
        if (rs.getTimestamp("ProcessedDate") != null) {
            request.setProcessedDate(rs.getTimestamp("ProcessedDate").toLocalDateTime());
        }
        
        // ProcessedNote - có thể không có
        try {
            request.setProcessedNote(rs.getString("ProcessedNote"));
        } catch (SQLException e) {
            // Column might not exist
        }
        
        // AttachmentPath - có thể không có
        try {
            request.setAttachmentPath(rs.getString("AttachmentPath"));
        } catch (SQLException e) {
            // Column might not exist
        }
        
        if (rs.getTimestamp("CreatedAt") != null) {
            request.setCreatedAt(rs.getTimestamp("CreatedAt").toLocalDateTime());
        }
        
        // Các cột JOIN - có thể không có
        try {
            request.setEmployeeName(rs.getString("EmployeeName"));
            request.setLeaveTypeName(rs.getString("LeaveTypeName"));
            request.setProcessedByName(rs.getString("ProcessedByName"));
        } catch (SQLException e) {
            // Columns might not exist in some queries
        }
        
        return request;
    }
    public List<LeaveRequest> getApprovedLeavesByDivisionAndDateRange(
        int divisionID, LocalDate startDate, LocalDate endDate) {
    List<LeaveRequest> requests = new ArrayList<>();
    
    String sql = "SELECT lr.*, e.FullName as EmployeeName, lt.LeaveTypeName " +
                "FROM LeaveRequests lr " +
                "INNER JOIN Employees e ON lr.EmployeeID = e.EmployeeID " +
                "LEFT JOIN LeaveTypes lt ON lr.LeaveTypeID = lt.LeaveTypeID " +
                "WHERE e.DivisionID = ? " +
                "  AND lr.Status = 'Approved' " +
                "  AND e.IsActive = 1 " +
                "  AND (" +
                "    (lr.StartDate >= ? AND lr.StartDate <= ?) " +  // Starts in range
                "    OR (lr.EndDate >= ? AND lr.EndDate <= ?) " +    // Ends in range
                "    OR (lr.StartDate <= ? AND lr.EndDate >= ?)" +   // Spans entire range
                "  ) " +
                "ORDER BY e.FullName, lr.StartDate";
    
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setInt(1, divisionID);
        stmt.setDate(2, Date.valueOf(startDate));
        stmt.setDate(3, Date.valueOf(endDate));
        stmt.setDate(4, Date.valueOf(startDate));
        stmt.setDate(5, Date.valueOf(endDate));
        stmt.setDate(6, Date.valueOf(startDate));
        stmt.setDate(7, Date.valueOf(endDate));
        
        ResultSet rs = stmt.executeQuery();
        
        while (rs.next()) {
            requests.add(extractLeaveRequestFromResultSet(rs));
        }
        
        logger.info("Found {} approved leaves for division {} between {} and {}", 
                   requests.size(), divisionID, startDate, endDate);
        
    } catch (SQLException e) {
        logger.error("Error getting approved leaves by division and date range", e);
    }
    
    return requests;
}

/**
 * Lấy tất cả đơn nghỉ phép đã được duyệt của TẤT CẢ phòng ban trong khoảng thời gian
 * Dùng khi muốn xem toàn công ty (CEO, HR)
 * 
 * @param startDate Ngày bắt đầu
 * @param endDate Ngày kết thúc
 * @return List các đơn nghỉ phép đã approved
 */
public List<LeaveRequest> getAllApprovedLeavesByDateRange(
        LocalDate startDate, LocalDate endDate) {
    List<LeaveRequest> requests = new ArrayList<>();
    
    String sql = "SELECT lr.*, e.FullName as EmployeeName, e.DivisionID, " +
                "       lt.LeaveTypeName, d.DivisionName " +
                "FROM LeaveRequests lr " +
                "INNER JOIN Employees e ON lr.EmployeeID = e.EmployeeID " +
                "LEFT JOIN LeaveTypes lt ON lr.LeaveTypeID = lt.LeaveTypeID " +
                "LEFT JOIN Divisions d ON e.DivisionID = d.DivisionID " +
                "WHERE lr.Status = 'Approved' " +
                "  AND e.IsActive = 1 " +
                "  AND (" +
                "    (lr.StartDate >= ? AND lr.StartDate <= ?) " +
                "    OR (lr.EndDate >= ? AND lr.EndDate <= ?) " +
                "    OR (lr.StartDate <= ? AND lr.EndDate >= ?)" +
                "  ) " +
                "ORDER BY d.DivisionName, e.FullName, lr.StartDate";
    
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setDate(1, Date.valueOf(startDate));
        stmt.setDate(2, Date.valueOf(endDate));
        stmt.setDate(3, Date.valueOf(startDate));
        stmt.setDate(4, Date.valueOf(endDate));
        stmt.setDate(5, Date.valueOf(startDate));
        stmt.setDate(6, Date.valueOf(endDate));
        
        ResultSet rs = stmt.executeQuery();
        
        while (rs.next()) {
            requests.add(extractLeaveRequestFromResultSet(rs));
        }
        
        logger.info("Found {} approved leaves between {} and {}", 
                   requests.size(), startDate, endDate);
        
    } catch (SQLException e) {
        logger.error("Error getting all approved leaves by date range", e);
    }
    
    return requests;
}
public int countLeaveRequestsByStatus(int employeeID, String status) {
    String sql = "SELECT COUNT(*) as Total " +
                "FROM LeaveRequests " +
                "WHERE EmployeeID = ? AND Status = ?";
    
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setInt(1, employeeID);
        stmt.setString(2, status);
        
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            return rs.getInt("Total");
        }
        
    } catch (SQLException e) {
        logger.error("Error counting leave requests by status", e);
    }
    
    return 0;
}
}