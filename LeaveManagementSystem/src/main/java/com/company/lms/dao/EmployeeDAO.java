package com.company.lms.dao;

import com.company.lms.model.Employee;
import com.company.lms.util.DatabaseConnection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class EmployeeDAO {
    private static final Logger logger = LoggerFactory.getLogger(EmployeeDAO.class);
    
    // Đăng nhập
    public Employee login(String username, String password) {
        String sql = "SELECT e.*, d.DivisionName, m.FullName as ManagerName " +
                    "FROM Employees e " +
                    "LEFT JOIN Divisions d ON e.DivisionID = d.DivisionID " +
                    "LEFT JOIN Employees m ON e.ManagerID = m.EmployeeID " +
                    "WHERE e.Username = ? AND e.PasswordHash = ? AND e.IsActive = 1";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            stmt.setString(2, password);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Employee emp = extractEmployeeFromResultSet(rs);
                updateLastLogin(emp.getEmployeeID());
                logger.info("User logged in: {}", username);
                return emp;
            }
        } catch (SQLException e) {
            logger.error("Error during login", e);
        }
        return null;
    }
    
    // Đăng ký tài khoản mới
    public boolean register(Employee employee) {
        String sql = "INSERT INTO Employees (EmployeeCode, Username, PasswordHash, Email, FullName, " +
                    "PhoneNumber, DateOfBirth, Gender, HireDate, DivisionID, IsActive) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            // Tạo mã nhân viên tự động
            String employeeCode = generateEmployeeCode();
            
            stmt.setString(1, employeeCode);
            stmt.setString(2, employee.getUsername());
            stmt.setString(3, employee.getPassword());
            stmt.setString(4, employee.getEmail());
            stmt.setString(5, employee.getFullName());
            stmt.setString(6, employee.getPhoneNumber());
            
            if (employee.getDateOfBirth() != null) {
                stmt.setDate(7, Date.valueOf(employee.getDateOfBirth()));
            } else {
                stmt.setNull(7, Types.DATE);
            }
            
            stmt.setString(8, employee.getGender());
            stmt.setDate(9, Date.valueOf(LocalDate.now())); // HireDate = today
            stmt.setInt(10, employee.getDivisionID() > 0 ? employee.getDivisionID() : 1); // Default division
            
            int affected = stmt.executeUpdate();
            
            if (affected > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    employee.setEmployeeID(rs.getInt(1));
                    
                    // Gán role mặc định là "Nhân viên"
                    assignDefaultRole(employee.getEmployeeID());
                    
                    logger.info("New user registered: {}", employee.getUsername());
                    return true;
                }
            }
        } catch (SQLException e) {
            logger.error("Error during registration", e);
        }
        return false;
    }
    
    // Kiểm tra username đã tồn tại
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
    
    // Kiểm tra email đã tồn tại
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
    
    // Cập nhật ảnh đại diện
    public boolean updateAvatar(int employeeID, String avatarPath) {
        String sql = "UPDATE Employees SET UpdatedAt = GETDATE() WHERE EmployeeID = ?";
        
        // Thêm cột AvatarPath nếu chưa có
        try (Connection conn = DatabaseConnection.getConnection()) {
            String checkColumnSql = "IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employees') AND name = 'AvatarPath') " +
                                   "ALTER TABLE Employees ADD AvatarPath VARCHAR(500)";
            try (Statement stmt = conn.createStatement()) {
                stmt.execute(checkColumnSql);
            }
            
            sql = "UPDATE Employees SET AvatarPath = ?, UpdatedAt = GETDATE() WHERE EmployeeID = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, avatarPath);
                stmt.setInt(2, employeeID);
                
                int affected = stmt.executeUpdate();
                logger.info("Avatar updated for employee: {}", employeeID);
                return affected > 0;
            }
        } catch (SQLException e) {
            logger.error("Error updating avatar", e);
        }
        return false;
    }
    
    // Lấy thông tin nhân viên theo ID
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
    
    // Lấy danh sách cấp dưới
    public List<Employee> getSubordinates(int managerID) {
        List<Employee> subordinates = new ArrayList<>();
        String sql = "SELECT e.*, d.DivisionName " +
                    "FROM Employees e " +
                    "LEFT JOIN Divisions d ON e.DivisionID = d.DivisionID " +
                    "WHERE e.ManagerID = ? AND e.IsActive = 1";
        
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
    
    // Helper methods
    private Employee extractEmployeeFromResultSet(ResultSet rs) throws SQLException {
        Employee emp = new Employee();
        emp.setEmployeeID(rs.getInt("EmployeeID"));
        emp.setEmployeeCode(rs.getString("EmployeeCode"));
        emp.setUsername(rs.getString("Username"));
        emp.setEmail(rs.getString("Email"));
        emp.setFullName(rs.getString("FullName"));
        emp.setPhoneNumber(rs.getString("PhoneNumber"));
        
        if (rs.getDate("DateOfBirth") != null) {
            emp.setDateOfBirth(rs.getDate("DateOfBirth").toLocalDate());
        }
        
        emp.setGender(rs.getString("Gender"));
        
        if (rs.getDate("HireDate") != null) {
            emp.setHireDate(rs.getDate("HireDate").toLocalDate());
        }
        
        emp.setDivisionID(rs.getInt("DivisionID"));
        emp.setDivisionName(rs.getString("DivisionName"));
        
        int managerID = rs.getInt("ManagerID");
        if (!rs.wasNull()) {
            emp.setManagerID(managerID);
        }
        
        emp.setManagerName(rs.getString("ManagerName"));
        emp.setActive(rs.getBoolean("IsActive"));
        
        if (rs.getTimestamp("LastLogin") != null) {
            emp.setLastLogin(rs.getTimestamp("LastLogin").toLocalDateTime());
        }
        
        // Thử lấy avatar path nếu có
        try {
            String avatarPath = rs.getString("AvatarPath");
            emp.setAvatarPath(avatarPath);
        } catch (SQLException e) {
            // Column không tồn tại, bỏ qua
        }
        
        return emp;
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
    
    private String generateEmployeeCode() {
        String sql = "SELECT TOP 1 EmployeeCode FROM Employees ORDER BY EmployeeID DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                String lastCode = rs.getString("EmployeeCode");
                int number = Integer.parseInt(lastCode.substring(3)) + 1;
                return String.format("EMP%04d", number);
            }
        } catch (SQLException e) {
            logger.error("Error generating employee code", e);
        }
        return "EMP0001";
    }
    
    private void assignDefaultRole(int employeeID) {
        String sql = "INSERT INTO EmployeeRoles (EmployeeID, RoleID) " +
                    "SELECT ?, RoleID FROM Roles WHERE RoleCode = 'EMPLOYEE'";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeID);
            stmt.executeUpdate();
        } catch (SQLException e) {
            logger.error("Error assigning default role", e);
        }
    }
}
