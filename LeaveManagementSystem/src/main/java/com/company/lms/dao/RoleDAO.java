package com.company.lms.dao;

import com.company.lms.model.Role;
import com.company.lms.util.DatabaseConnection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoleDAO {
    private static final Logger logger = LoggerFactory.getLogger(RoleDAO.class);
    // Thêm vào RoleDAO.java
public int getHighestRoleLevel(int employeeID) {
    String sql = "SELECT MIN(r.Level) as MinLevel " +
                "FROM Roles r " +
                "INNER JOIN EmployeeRoles er ON r.RoleID = er.RoleID " +
                "WHERE er.EmployeeID = ? AND er.IsActive = 1 AND r.IsActive = 1";
    
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setInt(1, employeeID);
        ResultSet rs = stmt.executeQuery();
        
        if (rs.next()) {
            int level = rs.getInt("MinLevel");
            return rs.wasNull() ? 4 : level; // Default: Employee
        }
    } catch (SQLException e) {
        logger.error("Error getting highest role level", e);
    }
    
    return 4; // Default: Employee
}
    public List<Role> getAllRoles() {
        List<Role> roles = new ArrayList<>();
        String sql = "SELECT * FROM Roles WHERE IsActive = 1 ORDER BY Level";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                roles.add(extractRoleFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            logger.error("Error getting all roles", e);
        }
        
        return roles;
    }
    
    public Role getRoleById(int roleID) {
        String sql = "SELECT * FROM Roles WHERE RoleID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, roleID);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return extractRoleFromResultSet(rs);
            }
            
        } catch (SQLException e) {
            logger.error("Error getting role by ID", e);
        }
        
        return null;
    }
    
    public List<Role> getRolesByEmployeeId(int employeeID) {
        List<Role> roles = new ArrayList<>();
        String sql = "SELECT r.* FROM Roles r " +
                    "INNER JOIN EmployeeRoles er ON r.RoleID = er.RoleID " +
                    "WHERE er.EmployeeID = ? AND er.IsActive = 1 AND r.IsActive = 1";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeID);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                roles.add(extractRoleFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            logger.error("Error getting roles by employee ID", e);
        }
        
        return roles;
    }
    
    private Role extractRoleFromResultSet(ResultSet rs) throws SQLException {
        Role role = new Role();
        role.setRoleID(rs.getInt("RoleID"));
        role.setRoleCode(rs.getString("RoleCode"));
        role.setRoleName(rs.getString("RoleName"));
        role.setDescription(rs.getString("Description"));
        role.setLevel(rs.getInt("Level"));
        role.setActive(rs.getBoolean("IsActive"));
        return role;
    }
}