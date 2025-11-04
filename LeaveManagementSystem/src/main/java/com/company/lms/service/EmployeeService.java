package com.company.lms.service;

import com.company.lms.dao.EmployeeDAO;
import com.company.lms.dao.RoleDAO;
import com.company.lms.model.Employee;
import com.company.lms.model.Role;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

public class EmployeeService {
    private static final Logger logger = LoggerFactory.getLogger(EmployeeService.class);
    private EmployeeDAO employeeDAO;
    private RoleDAO roleDAO;

    public EmployeeService() {
        this.employeeDAO = new EmployeeDAO();
        this.roleDAO = new RoleDAO();
    }

    public Employee authenticate(String username, String password) {
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            return null;
        }

        return employeeDAO.login(username.trim(), password);
    }

    public boolean registerEmployee(Employee employee) {
        if (employee == null) {
            return false;
        }

        if (employeeDAO.isUsernameExists(employee.getUsername())) {
            logger.warn("Username already exists: {}", employee.getUsername());
            return false;
        }

        if (employeeDAO.isEmailExists(employee.getEmail())) {
            logger.warn("Email already exists: {}", employee.getEmail());
            return false;
        }

        return employeeDAO.register(employee);
    }

    public Employee getEmployeeById(int employeeID) {
        return employeeDAO.getEmployeeById(employeeID);
    }

    public List<Employee> getSubordinates(int managerID) {
        return employeeDAO.getSubordinates(managerID);
    }

    public List<Role> getEmployeeRoles(int employeeID) {
        return roleDAO.getRolesByEmployeeId(employeeID);
    }

    public boolean updateAvatar(int employeeID, String avatarPath) {
        return employeeDAO.updateAvatar(employeeID, avatarPath);
    }

    public boolean hasRole(int employeeID, String roleCode) {
        List<Role> roles = roleDAO.getRolesByEmployeeId(employeeID);
        return roles.stream().anyMatch(r -> roleCode.equals(r.getRoleCode()));
    }

    public boolean isManager(int employeeID) {
        return hasRole(employeeID, "MANAGER") ||
               hasRole(employeeID, "DIVISION_LEADER") ||
               hasRole(employeeID, "TEAM_LEADER");
    }

    /**
     * Kiểm tra nhân viên có phải Senior Management (Level 1-2) không
     * Level 1: CEO, ADMIN
     * Level 2: DIV_LEADER, HR_MANAGER
     */
    public boolean isSeniorManagement(int employeeID) {
        List<Role> roles = roleDAO.getRolesByEmployeeId(employeeID);
        return roles.stream().anyMatch(r -> r.getLevel() == 1 || r.getLevel() == 2);
    }

    /**
     * Lấy Level thấp nhất (quyền cao nhất) của nhân viên
     * @param employeeID
     * @return Level (1=highest, 4=lowest), trả về 999 nếu không có role
     */
    public int getEmployeeLevel(int employeeID) {
        List<Role> roles = roleDAO.getRolesByEmployeeId(employeeID);
        
        if (roles == null || roles.isEmpty()) {
            logger.warn("Employee {} has no roles assigned", employeeID);
            return 999; // Không có role
        }
        
        // Lấy level thấp nhất (quyền cao nhất)
        int minLevel = roles.stream()
                .mapToInt(Role::getLevel)
                .min()
                .orElse(999);
        
        logger.debug("Employee {} has level: {}", employeeID, minLevel);
        return minLevel;
    }

    /**
     * Kiểm tra có quyền xem Agenda (lịch nghỉ phép phòng ban)
     * Chỉ Level 1-2 mới được xem
     */
    public boolean canViewAgenda(int employeeID) {
        int level = getEmployeeLevel(employeeID);
        return level <= 2;
    }

    /**
     * Kiểm tra có quyền duyệt đơn nghỉ phép
     * Chỉ Level 1-2 mới được duyệt
     */
    public boolean canApproveLeaveRequest(int employeeID) {
        int level = getEmployeeLevel(employeeID);
        return level <= 2;
    }

    /**
     * Kiểm tra có quyền quản lý nhân viên
     * Level 1-2 được quản lý
     */
    public boolean canManageEmployees(int employeeID) {
        int level = getEmployeeLevel(employeeID);
        return level <= 2;
    }

    /**
     * Kiểm tra có quyền xem báo cáo
     * Level 1-2 được xem
     */
    public boolean canViewReports(int employeeID) {
        int level = getEmployeeLevel(employeeID);
        return level <= 2;
    }
}