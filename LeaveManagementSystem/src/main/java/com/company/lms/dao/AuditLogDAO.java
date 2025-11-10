package com.company.lms.dao;

import com.company.lms.model.AuditLog;
import com.company.lms.util.DatabaseConnection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AuditLogDAO {
    private static final Logger logger = LoggerFactory.getLogger(AuditLogDAO.class);

    /**
     * Lấy audit logs với filter theo phòng ban, nhân viên, thời gian, action
     */
    public List<AuditLog> getAuditLogsWithDivision(
            Integer divisionId, 
            Integer employeeId, 
            Date fromDate, 
            Date toDate,
            String action) {
        
        List<AuditLog> logs = new ArrayList<>();
        String sql = "{CALL sp_GetAuditLogsWithDivision(?, ?, ?, ?, ?)}";
        
        try (Connection conn = DatabaseConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {
            
            // Set parameters
            if (divisionId != null) {
                stmt.setInt(1, divisionId);
            } else {
                stmt.setNull(1, Types.INTEGER);
            }
            
            if (employeeId != null) {
                stmt.setInt(2, employeeId);
            } else {
                stmt.setNull(2, Types.INTEGER);
            }
            
            if (fromDate != null) {
                stmt.setDate(3, fromDate);
            } else {
                stmt.setNull(3, Types.DATE);
            }
            
            if (toDate != null) {
                stmt.setDate(4, toDate);
            } else {
                stmt.setNull(4, Types.DATE);
            }
            
            if (action != null && !action.isEmpty()) {
                stmt.setString(5, action);
            } else {
                stmt.setNull(5, Types.VARCHAR);
            }
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                AuditLog log = new AuditLog();
                log.setAuditID(rs.getLong("AuditID"));
                log.setTableName(rs.getString("TableName"));
                log.setRecordID(rs.getInt("RecordID"));
                log.setAction(rs.getString("Action"));
                log.setEmployeeID(rs.getInt("EmployeeID"));
                log.setEmployeeCode(rs.getString("EmployeeCode"));
                log.setEmployeeName(rs.getString("EmployeeName"));
                log.setDivisionID(rs.getInt("DivisionID"));
                log.setDivisionName(rs.getString("DivisionName"));
                log.setDivisionCode(rs.getString("DivisionCode"));
                log.setOldValue(rs.getString("OldValue"));
                log.setNewValue(rs.getString("NewValue"));
                log.setNote(rs.getString("Note"));
                log.setIPAddress(rs.getString("IPAddress"));
                log.setUserAgent(rs.getString("UserAgent"));
                log.setCreatedAt(rs.getTimestamp("CreatedAt"));
                log.setActionDisplay(rs.getString("ActionDisplay"));
                
                logs.add(log);
            }
            
            logger.info("Retrieved {} audit logs", logs.size());
            
        } catch (SQLException e) {
            logger.error("Error getting audit logs with division filter", e);
        }
        
        return logs;
    }
}