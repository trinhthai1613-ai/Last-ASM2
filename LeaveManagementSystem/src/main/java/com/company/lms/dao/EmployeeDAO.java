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
    // Tạo EmployeeCode tự động
    String employeeCode = generateEmployeeCode();
    
    String sql = "INSERT INTO Employees " +
                "(EmployeeCode, Username, PasswordHash, Email, FullName, " +
                "PhoneNumber, Gender, DateOfBirth, DivisionID, HireDate, IsActive) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), 1)";
    
    Connection conn = null;
    PreparedStatement stmt = null;
    
    try {
        conn = DatabaseConnection.getConnection();
        conn.setAutoCommit(false); // Bắt đầu transaction
        
        stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        
        stmt.setString(1, employeeCode);
        stmt.setString(2, employee.getUsername());
        stmt.setString(3, hashPassword(employee.getPassword())); // Hash password
        stmt.setString(4, employee.getEmail());
        stmt.setString(5, employee.getFullName());
        
        // Optional fields
        if (employee.getPhoneNumber() != null && !employee.getPhoneNumber().isEmpty()) {
            stmt.setString(6, employee.getPhoneNumber());
        } else {
            stmt.setNull(6, Types.VARCHAR);
        }
        
        if (employee.getGender() != null && !employee.getGender().isEmpty()) {
            stmt.setString(7, employee.getGender());
        } else {
            stmt.setNull(7, Types.VARCHAR);
        }
        
        if (employee.getDateOfBirth() != null) {
            stmt.setDate(8, Date.valueOf(employee.getDateOfBirth()));
        } else {
            stmt.setNull(8, Types.DATE);
        }
        
        // DivisionID - default to 1 if not set
        stmt.setInt(9, employee.getDivisionID() > 0 ? employee.getDivisionID() : 1);
        
        int rowsAffected = stmt.executeUpdate();
        
        if (rowsAffected > 0) {
            // Lấy EmployeeID vừa tạo
            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                int newEmployeeId = rs.getInt(1);
                employee.setEmployeeID(newEmployeeId);
                
                // Gán role mặc định: EMPLOYEE (RoleID = 4)
                String roleSQL = "INSERT INTO EmployeeRoles (EmployeeID, RoleID) VALUES (?, 4)";
                try (PreparedStatement roleStmt = conn.prepareStatement(roleSQL)) {
                    roleStmt.setInt(1, newEmployeeId);
                    roleStmt.executeUpdate();
                }
                
                // Tạo quota nghỉ phép cho năm hiện tại
                createDefaultLeaveQuotas(conn, newEmployeeId);
            }
            
            conn.commit(); // Commit transaction
            logger.info("Employee registered successfully: {} (ID: {})", 
                       employee.getUsername(), employee.getEmployeeID());
            return true;
        }
        
        conn.rollback();
        return false;
        
    } catch (SQLException e) {
        logger.error("Error during registration", e);
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                logger.error("Error rolling back transaction", ex);
            }
        }
        return false;
    } finally {
        try {
            if (stmt != null) stmt.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        } catch (SQLException e) {
            logger.error("Error closing resources", e);
        }
    }
}

/**

 */
private String generateEmployeeCode() {
    String sql = "SELECT COUNT(*) + 1 as NextNumber FROM Employees";
    
    try (Connection conn = DatabaseConnection.getConnection();
         Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery(sql)) {
        
        if (rs.next()) {
            int nextNum = rs.getInt("NextNumber");
            return String.format("EMP%04d", nextNum);
        }
        
    } catch (SQLException e) {
        logger.error("Error generating employee code", e);
    }
    
    // Fallback
    return "EMP" + System.currentTimeMillis();
}

private void createDefaultLeaveQuotas(Connection conn, int employeeId) throws SQLException {
    String sql = "INSERT INTO LeaveQuotas (EmployeeID, LeaveTypeID, Year, TotalDays, UsedDays, RemainingDays) " +
                "SELECT ?, LeaveTypeID, YEAR(GETDATE()), DefaultDaysPerYear, 0, DefaultDaysPerYear " +
                "FROM LeaveTypes " +
                "WHERE LeaveTypeCode IN ('ANNUAL', 'SICK') AND IsActive = 1";
    
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, employeeId);
        int quotasCreated = stmt.executeUpdate();
        logger.info("Created {} leave quotas for employee {}", quotasCreated, employeeId);
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
    
    public List<Employee> getEmployeesByDivision(int divisionID) {
        List<Employee> employees = new ArrayList<>();
        String sql = "SELECT e.*, d.DivisionName " +
                    "FROM Employees e " +
                    "LEFT JOIN Divisions d ON e.DivisionID = d.DivisionID " +
                    "WHERE e.DivisionID = ? AND e.IsActive = 1 " +
                    "ORDER BY e.FullName";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, divisionID);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                employees.add(extractEmployeeFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            logger.error("Error getting employees by division", e);
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
                    "Gender = ?, DateOfBirth = ?, AvatarPath = ?, UpdatedAt = GETDATE() " +
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
            
            if (employee.getAvatarPath() != null) {
                stmt.setString(6, employee.getAvatarPath());
            } else {
                stmt.setNull(6, Types.VARCHAR);
            }
            
            stmt.setInt(7, employee.getEmployeeID());
            
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