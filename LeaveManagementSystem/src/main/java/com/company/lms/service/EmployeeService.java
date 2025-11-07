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

    /**
     * Kiểm tra có phải Manager không (Level 1 hoặc 2)
     */
    public boolean isManager(int employeeID) {
        List<Role> roles = roleDAO.getRolesByEmployeeId(employeeID);
        return roles.stream().anyMatch(r -> r.getLevel() == 1 || r.getLevel() == 2);
    }

    /**
     * Kiểm tra có phải Senior Management không (Level 1 hoặc 2)
     * Dùng để kiểm tra quyền xem Agenda và Duyệt đơn
     */
    public boolean isSeniorManagement(int employeeID) {
        List<Role> roles = roleDAO.getRolesByEmployeeId(employeeID);
        return roles.stream().anyMatch(r -> r.getLevel() == 1 || r.getLevel() == 2);
    }

    /**
     * Kiểm tra có phải CEO không (chỉ Level 1)
     * Dùng để kiểm tra quyền xem Agenda
     */
    public boolean isCEO(int employeeID) {
        List<Role> roles = roleDAO.getRolesByEmployeeId(employeeID);
        return roles.stream().anyMatch(r -> r.getLevel() == 1);
    }

    /**
     * Lấy role level thấp nhất của employee (level càng thấp càng cao cấp)
     */
    public int getLowestRoleLevel(int employeeID) {
        List<Role> roles = roleDAO.getRolesByEmployeeId(employeeID);
        return roles.stream()
                .mapToInt(Role::getLevel)
                .min()
                .orElse(999); // Nếu không có role, trả về level rất cao (không có quyền)
    }
    public boolean isHRManager(int employeeID) {
    List<Role> roles = roleDAO.getRolesByEmployeeId(employeeID);
    return roles.stream().anyMatch(r -> "HR_MANAGER".equals(r.getRoleCode()));
}

/**
 * Kiểm tra có phải Division Leader không (RoleCode = 'DIV_LEADER')
 */
public boolean isDivisionLeader(int employeeID) {
    List<Role> roles = roleDAO.getRolesByEmployeeId(employeeID);
    return roles.stream().anyMatch(r -> "DIV_LEADER".equals(r.getRoleCode()));
}

/**
 * Kiểm tra có phải CEO/Admin không (Level 1)
 */
public boolean isCEOorAdmin(int employeeID) {
    List<Role> roles = roleDAO.getRolesByEmployeeId(employeeID);
    return roles.stream().anyMatch(r -> r.getLevel() == 1);
}
}