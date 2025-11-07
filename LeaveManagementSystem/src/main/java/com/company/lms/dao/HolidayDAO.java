package com.company.lms.dao;

import com.company.lms.model.Holiday;
import com.company.lms.util.DatabaseConnection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HolidayDAO {
    private static final Logger logger = LoggerFactory.getLogger(HolidayDAO.class);
    
    public List<Holiday> getHolidaysByYear(int year) {
        List<Holiday> holidays = new ArrayList<>();
        String sql = "SELECT * FROM Holidays WHERE Year = ? ORDER BY HolidayDate";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, year);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Holiday holiday = new Holiday();
                holiday.setHolidayID(rs.getInt("HolidayID"));
                holiday.setHolidayName(rs.getString("HolidayName"));
                holiday.setHolidayDate(rs.getDate("HolidayDate").toLocalDate());
                holiday.setYear(rs.getInt("Year"));
                holiday.setRecurring(rs.getBoolean("IsRecurring"));
                holiday.setDescription(rs.getString("Description"));
                holidays.add(holiday);
            }
            
        } catch (SQLException e) {
            logger.error("Error getting holidays by year", e);
        }
        
        return holidays;
    }
}