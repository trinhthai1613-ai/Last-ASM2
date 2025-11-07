package com.company.lms.dao;

import com.company.lms.model.LeaveQuota;
import com.company.lms.util.DatabaseConnection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LeaveQuotaDAO {
    
    private static final Logger logger = LoggerFactory.getLogger(LeaveQuotaDAO.class);
    
    public List<LeaveQuota> getLeaveQuotasByEmployee(int employeeId, int year) {
        List<LeaveQuota> quotas = new ArrayList<>();
        
        String sql = "SELECT lq.QuotaID, lq.EmployeeID, lq.LeaveTypeID, lq.Year, " +
                    "lq.TotalDays, lq.UsedDays, lq.RemainingDays, lq.CarryOverDays, " +
                    "lt.LeaveTypeName, lt.LeaveTypeCode " +
                    "FROM LeaveQuotas lq " +
                    "JOIN LeaveTypes lt ON lq.LeaveTypeID = lt.LeaveTypeID " +
                    "WHERE lq.EmployeeID = ? AND lq.Year = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            stmt.setInt(2, year);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                LeaveQuota quota = new LeaveQuota();
                quota.setQuotaID(rs.getInt("QuotaID"));
                quota.setEmployeeID(rs.getInt("EmployeeID"));
                quota.setLeaveTypeID(rs.getInt("LeaveTypeID"));
                quota.setYear(rs.getInt("Year"));
                quota.setTotalDays(rs.getDouble("TotalDays"));
                quota.setUsedDays(rs.getDouble("UsedDays"));
                quota.setRemainingDays(rs.getDouble("RemainingDays"));
                quota.setCarryOverDays(rs.getDouble("CarryOverDays"));
                quota.setLeaveTypeName(rs.getString("LeaveTypeName"));
                quota.setLeaveTypeCode(rs.getString("LeaveTypeCode"));
                
                quotas.add(quota);
            }
            
        } catch (SQLException e) {
            logger.error("Error getting leave quotas for employee {}", employeeId, e);
        }
        
        return quotas;
    }
}