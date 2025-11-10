package com.company.lms.dao;

import com.company.lms.model.Division;
import com.company.lms.util.DatabaseConnection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DivisionDAO {
    private static final Logger logger = LoggerFactory.getLogger(DivisionDAO.class);

    /**
     * Lấy tất cả các phòng ban đang hoạt động
     */
    public List<Division> getAllDivisions() {
        List<Division> divisions = new ArrayList<>();
        String sql = "SELECT DivisionID, DivisionCode, DivisionName, Description, IsActive " +
                     "FROM Divisions WHERE IsActive = 1 ORDER BY DivisionName";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Division division = new Division();
                division.setDivisionID(rs.getInt("DivisionID"));
                division.setDivisionCode(rs.getString("DivisionCode"));
                division.setDivisionName(rs.getString("DivisionName"));
                division.setDescription(rs.getString("Description"));
                division.setIsActive(rs.getBoolean("IsActive"));
                divisions.add(division);
            }
            
            logger.info("Retrieved {} divisions", divisions.size());
            
        } catch (SQLException e) {
            logger.error("Error getting all divisions", e);
        }
        
        return divisions;
    }
    
    /**
     * Lấy division theo ID
     */
    public Division getDivisionById(int divisionId) {
        String sql = "SELECT DivisionID, DivisionCode, DivisionName, Description, IsActive " +
                     "FROM Divisions WHERE DivisionID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, divisionId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Division division = new Division();
                division.setDivisionID(rs.getInt("DivisionID"));
                division.setDivisionCode(rs.getString("DivisionCode"));
                division.setDivisionName(rs.getString("DivisionName"));
                division.setDescription(rs.getString("Description"));
                division.setIsActive(rs.getBoolean("IsActive"));
                return division;
            }
            
        } catch (SQLException e) {
            logger.error("Error getting division by ID: {}", divisionId, e);
        }
        
        return null;
    }
}