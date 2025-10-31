package com.company.lms.dao;

import com.company.lms.model.Employee;
import com.company.lms.util.DatabaseConnection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class EmployeeDAO {
    private static final Logger logger = LoggerFactory.getLogger(EmployeeDAO.class);
    
    /**
     * Hash password sử dụng SHA-256
     */
    private String hashPassword(String plainPassword) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(plainPassword.getBytes());
            
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
            
        } catch (NoSuchAlgorithmException e) {
            logger.error("Error hashing password", e);
            throw new RuntimeException("Cannot hash password", e);
        }
    }
    
    public Employee login(String username, String password) {
    String sql = "SELECT e.*, d.DivisionName " +
                "FROM Employees e " +
                "LEFT JOIN Divisions d ON e.DivisionID = d.DivisionID " +
                "WHERE e.Username = ? AND e.IsActive = 1";
    
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        System.out.println("=== LOGIN DEBUG ===");
        System.out.println("Username nhập vào: " + username);
        System.out.println("Password nhập vào: " + password);
        
        stmt.setString(1, username);
        ResultSet rs = stmt.executeQuery();
        
        if (rs.next()) {
            String storedPasswordHash = rs.getString("PasswordHash");
            
            // Hash password người dùng nhập trước khi so sánh
            String inputPasswordHash = hashPassword(password);
            
            System.out.println("Password hash trong DB: " + storedPasswordHash);
            System.out.println("Password hash từ input: " + inputPasswordHash);
            System.out.println("Password khớp? " + inputPasswordHash.equals(storedPasswordHash));
            
            // Kiểm tra password đã hash
            if (inputPasswordHash.equals(storedPasswordHash)) {
                Employee employee = extractEmployeeFromResultSet(rs);
                
                // Update last login
                updateLastLogin(employee.getEmployeeID());
                
                System.out.println("✓ Đăng nhập thành công!");
                return employee;
            } else {
                System.out.println("✗ Password không khớp!");
            }
        } else {
            System.out.println("✗ Không tìm thấy username: " + username);
        }
        
        return null;
        
    } catch (SQLException e) {
        System.out.println("✗ Lỗi SQL: " + e.getMessage());
        e.printStackTrace();
        return null;
    }
}
    
    public boolean register(Employee employee) {
        String sql = "{CALL sp_RegisterEmployee(?, ?, ?, ?)}";
        
        try (Connection conn = DatabaseConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {
            
            stmt.setString(1, employee.getUsername());
            // Hash password trước khi lưu vào DB
            stmt.setString(2, hashPassword(employee.getPassword()));
            stmt.setString(3, employee.getEmail());
            stmt.setString(4, employee.getFullName());
            
            stmt.execute();
            logger.info("Employee registered successfully: {}", employee.getUsername());
            return true;
            
        } catch (SQLException e) {
            logger.error("Error during registration", e);
            return false;
        }
    }
    
    public boolean isUsernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM Employees WHERE Username = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            logger.error("Error checking username", e);
        }
        
        return false;
    }
    
    public boolean isEmailExists(String email) {
        String sql = "SELECT COUNT(*) FROM Employees WHERE Email = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            logger.error("Error checking email", e);
        }
        
        return false;
    }
    
    public Employee getEmployeeById(int employeeID) {
        String sql = "SELECT e.*, d.DivisionName, m.FullName as ManagerName " +
                    "FROM Employees e " +
                    "LEFT JOIN Divisions d ON e.DivisionID = d.DivisionID " +
                    "LEFT JOIN Employees m ON e.ManagerID = m.EmployeeID " +
                    "WHERE e.EmployeeID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeID);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return extractEmployeeFromResultSet(rs);
            }
            
        } catch (SQLException e) {
            logger.error("Error getting employee by ID", e);
        }
        
        return null;
    }
    
    public List<Employee> getSubordinates(int managerID) {
        List<Employee> subordinates = new ArrayList<>();
        String sql = "SELECT e.*, d.DivisionName " +
                    "FROM Employees e " +
                    "LEFT JOIN Divisions d ON e.DivisionID = d.DivisionID " +
                    "WHERE e.ManagerID = ? AND e.IsActive = 1 " +
                    "ORDER BY e.FullName";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, managerID);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                subordinates.add(extractEmployeeFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            logger.error("Error getting subordinates", e);
        }
        
        return subordinates;
    }
    
    public List<Employee> getAllEmployees() {
        List<Employee> employees = new ArrayList<>();
        String sql = "SELECT e.*, d.DivisionName, m.FullName as ManagerName " +
                    "FROM Employees e " +
                    "LEFT JOIN Divisions d ON e.DivisionID = d.DivisionID " +
                    "LEFT JOIN Employees m ON e.ManagerID = m.EmployeeID " +
                    "WHERE e.IsActive = 1 " +
                    "ORDER BY e.FullName";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                employees.add(extractEmployeeFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            logger.error("Error getting all employees", e);
        }
        
        return employees;
    }
    
    private void updateLastLogin(int employeeID) {
        String sql = "UPDATE Employees SET LastLogin = GETDATE() WHERE EmployeeID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeID);
            stmt.executeUpdate();
            
        } catch (SQLException e) {
            logger.error("Error updating last login", e);
        }
    }
    
    public boolean updateAvatar(int employeeID, String avatarPath) {
        String sql = "UPDATE Employees SET AvatarPath = ?, UpdatedAt = GETDATE() WHERE EmployeeID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, avatarPath);
            stmt.setInt(2, employeeID);
            
            int updated = stmt.executeUpdate();
            return updated > 0;
            
        } catch (SQLException e) {
            logger.error("Error updating avatar", e);
            return false;
        }
    }
    
    public boolean updateEmployee(Employee employee) {
        String sql = "UPDATE Employees SET " +
                    "FullName = ?, Email = ?, PhoneNumber = ?, " +
                    "Gender = ?, DateOfBirth = ?, UpdatedAt = GETDATE() " +
                    "WHERE EmployeeID = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, employee.getFullName());
            stmt.setString(2, employee.getEmail());
            stmt.setString(3, employee.getPhoneNumber());
            stmt.setString(4, employee.getGender());
            
            if (employee.getDateOfBirth() != null) {
                stmt.setDate(5, Date.valueOf(employee.getDateOfBirth()));
            } else {
                stmt.setNull(5, Types.DATE);
            }
            
            stmt.setInt(6, employee.getEmployeeID());
            
            int updated = stmt.executeUpdate();
            return updated > 0;
            
        } catch (SQLException e) {
            logger.error("Error updating employee", e);
            return false;
        }
    }
    
    private Employee extractEmployeeFromResultSet(ResultSet rs) throws SQLException {
        Employee employee = new Employee();
        
        employee.setEmployeeID(rs.getInt("EmployeeID"));
        employee.setEmployeeCode(rs.getString("EmployeeCode"));
        employee.setUsername(rs.getString("Username"));
        employee.setEmail(rs.getString("Email"));
        employee.setFullName(rs.getString("FullName"));
        employee.setPhoneNumber(rs.getString("PhoneNumber"));
        
        if (rs.getDate("DateOfBirth") != null) {
            employee.setDateOfBirth(rs.getDate("DateOfBirth").toLocalDate());
        }
        
        employee.setGender(rs.getString("Gender"));
        
        if (rs.getDate("HireDate") != null) {
            employee.setHireDate(rs.getDate("HireDate").toLocalDate());
        }
        
        employee.setDivisionID(rs.getInt("DivisionID"));
        
        try {
            employee.setDivisionName(rs.getString("DivisionName"));
        } catch (SQLException e) {
            // Column might not exist
        }
        
        int managerID = rs.getInt("ManagerID");
        if (!rs.wasNull()) {
            employee.setManagerID(managerID);
        }
        
        try {
            employee.setManagerName(rs.getString("ManagerName"));
        } catch (SQLException e) {
            // Column might not exist
        }
        
        employee.setActive(rs.getBoolean("IsActive"));
        
        if (rs.getTimestamp("LastLogin") != null) {
            employee.setLastLogin(rs.getTimestamp("LastLogin").toLocalDateTime());
        }
        
        try {
            employee.setAvatarPath(rs.getString("AvatarPath"));
        } catch (SQLException e) {
            // Column might not exist, set to null
            employee.setAvatarPath(null);
        }
        
        if (rs.getTimestamp("CreatedAt") != null) {
            employee.setCreatedAt(rs.getTimestamp("CreatedAt").toLocalDateTime());
        }
        
        if (rs.getTimestamp("UpdatedAt") != null) {
            employee.setUpdatedAt(rs.getTimestamp("UpdatedAt").toLocalDateTime());
        }
        
        return employee;
    }
    
}