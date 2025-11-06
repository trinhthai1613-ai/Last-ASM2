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

    public List<AuditLog> getAllAuditLogs(String tableName, Integer employeeId, Date fromDate, Date toDate) {
        List<AuditLog> logs = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT a.*, e.FullName as EmployeeName, e.EmployeeCode " +
            "FROM AuditLogs a " +
            "LEFT JOIN Employees e ON a.EmployeeID = e.EmployeeID " +
            "WHERE 1=1 "
        );
        
        if (tableName != null && !tableName.isEmpty()) {
            sql.append("AND a.TableName = ? ");
        }
        if (employeeId != null) {
            sql.append("AND a.EmployeeID = ? ");
        }
        if (fromDate != null) {
            sql.append("AND a.CreatedAt >= ? ");
        }
        if (toDate != null) {
            sql.append("AND a.CreatedAt <= ? ");
        }
        
        sql.append("ORDER BY a.CreatedAt DESC");
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (tableName != null && !tableName.isEmpty()) {
                stmt.setString(paramIndex++, tableName);
            }
            if (employeeId != null) {
                stmt.setInt(paramIndex++, employeeId);
            }
            if (fromDate != null) {
                stmt.setDate(paramIndex++, fromDate);
            }
            if (toDate != null) {
                stmt.setDate(paramIndex++, toDate);
            }
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                AuditLog log = new AuditLog();
                log.setAuditID(rs.getLong("AuditID"));
                log.setTableName(rs.getString("TableName"));
                log.setRecordID(rs.getInt("RecordID"));
                log.setAction(rs.getString("Action"));
                log.setEmployeeID(rs.getInt("EmployeeID"));
                log.setEmployeeName(rs.getString("EmployeeName"));
                log.setEmployeeCode(rs.getString("EmployeeCode"));
                log.setOldValue(rs.getString("OldValue"));
                log.setNewValue(rs.getString("NewValue"));
                log.setIPAddress(rs.getString("IPAddress"));
                log.setUserAgent(rs.getString("UserAgent"));
                log.setCreatedAt(rs.getTimestamp("CreatedAt"));
                logs.add(log);
            }
            
        } catch (SQLException e) {
            logger.error("Error getting audit logs", e);
        }
        
        return logs;
    }
}