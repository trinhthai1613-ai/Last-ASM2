package com.company.lms.dao;

import com.company.lms.model.LeaveType;
import com.company.lms.util.DatabaseConnection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LeaveTypeDAO {
    private static final Logger logger = LoggerFactory.getLogger(LeaveTypeDAO.class);
    
    public List<LeaveType> getAllLeaveTypes() {
        List<LeaveType> leaveTypes = new ArrayList<>();
        String sql = "SELECT * FROM LeaveTypes WHERE IsActive = 1 ORDER BY LeaveTypeName";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                leaveTypes.add(extractLeaveTypeFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            logger.error("Error getting all leave types", e);
        }
        
        return leaveTypes;
    }
    
    public LeaveType getLeaveTypeById(int leaveTypeID) {
        String sql = "SELECT * FROM LeaveTypes WHERE LeaveTypeID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, leaveTypeID);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return extractLeaveTypeFromResultSet(rs);
            }
            
        } catch (SQLException e) {
            logger.error("Error getting leave type by ID", e);
        }
        
        return null;
    }
    
    private LeaveType extractLeaveTypeFromResultSet(ResultSet rs) throws SQLException {
        LeaveType leaveType = new LeaveType();
        leaveType.setLeaveTypeID(rs.getInt("LeaveTypeID"));
        leaveType.setLeaveTypeCode(rs.getString("LeaveTypeCode"));
        leaveType.setLeaveTypeName(rs.getString("LeaveTypeName"));
        leaveType.setDescription(rs.getString("Description"));
        leaveType.setDefaultDaysPerYear(rs.getInt("DefaultDaysPerYear"));
        leaveType.setRequiresApproval(rs.getBoolean("RequiresApproval"));
        leaveType.setPaid(rs.getBoolean("IsPaid"));
        leaveType.setAllowCustomReason(rs.getBoolean("AllowCustomReason"));
        leaveType.setActive(rs.getBoolean("IsActive"));
        return leaveType;
    }
}