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
}