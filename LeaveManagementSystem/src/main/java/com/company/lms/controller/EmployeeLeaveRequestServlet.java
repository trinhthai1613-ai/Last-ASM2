package com.company.lms.controller;

import com.company.lms.dao.DivisionDAO;
import com.company.lms.dao.LeaveRequestDAO;
import com.company.lms.dao.LeaveTypeDAO;
import com.company.lms.dao.EmployeeDAO;
import com.company.lms.model.*;
import com.company.lms.service.EmployeeService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

public class EmployeeLeaveRequestServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(EmployeeLeaveRequestServlet.class);
    private LeaveRequestDAO leaveRequestDAO;
    private DivisionDAO divisionDAO;
    private LeaveTypeDAO leaveTypeDAO;
    private EmployeeDAO employeeDAO;
    private EmployeeService employeeService;
    
    @Override
    public void init() throws ServletException {
        leaveRequestDAO = new LeaveRequestDAO();
        divisionDAO = new DivisionDAO();
        leaveTypeDAO = new LeaveTypeDAO();
        employeeDAO = new EmployeeDAO();
        employeeService = new EmployeeService();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        Employee user = (Employee) session.getAttribute("user");
        int roleLevel = employeeService.getLowestRoleLevel(user.getEmployeeID());
        
        // Chỉ CEO (level 1) và Manager (level 2) mới được xem
        if (roleLevel > 2) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        
        try {
            // Lấy tham số filter
            String status = request.getParameter("status");
            String divisionIdParam = request.getParameter("divisionId");
            String leaveTypeIdParam = request.getParameter("leaveTypeId");
            String employeeIdParam = request.getParameter("employeeId");
            
            // Lấy danh sách đơn dựa theo role
            List<LeaveRequest> requests;
            List<Division> divisions;
            
            if (roleLevel == 1) {
                // CEO: xem tất cả
                requests = leaveRequestDAO.getAllLeaveRequests();
                divisions = divisionDAO.getAllDivisions();
            } else {
                // Manager (level 2): chỉ xem đơn trong phòng ban của mình
                requests = leaveRequestDAO.getLeaveRequestsByDivision(user.getDivisionID());
                divisions = divisionDAO.getAllDivisions().stream()
                    .filter(d -> d.getDivisionID() == user.getDivisionID())
                    .collect(Collectors.toList());
            }
            
            // Lọc theo status
            if (status != null && !status.isEmpty()) {
                final String finalStatus = status;
                requests = requests.stream()
                    .filter(r -> finalStatus.equals(r.getStatus()))
                    .collect(Collectors.toList());
            }
            
            // Lọc theo divisionId
            if (divisionIdParam != null && !divisionIdParam.isEmpty()) {
                try {
                    int divisionId = Integer.parseInt(divisionIdParam);
                    // Manager chỉ được lọc trong phòng của mình
                    if (roleLevel == 2 && divisionId != user.getDivisionID()) {
                        divisionId = user.getDivisionID();
                    }
                    final int finalDivisionId = divisionId;
                    requests = requests.stream()
                        .filter(r -> {
                            try {
                                Employee emp = employeeDAO.getEmployeeById(r.getEmployeeID());
                                return emp != null && emp.getDivisionID() == finalDivisionId;
                            } catch (Exception e) {
                                return false;
                            }
                        })
                        .collect(Collectors.toList());
                } catch (NumberFormatException e) {
                    logger.warn("Invalid division ID: {}", divisionIdParam);
                }
            }
            
            // Lọc theo leaveTypeId
            if (leaveTypeIdParam != null && !leaveTypeIdParam.isEmpty()) {
                try {
                    int leaveTypeId = Integer.parseInt(leaveTypeIdParam);
                    final int finalLeaveTypeId = leaveTypeId;
                    requests = requests.stream()
                        .filter(r -> r.getLeaveTypeID() == finalLeaveTypeId)
                        .collect(Collectors.toList());
                } catch (NumberFormatException e) {
                    logger.warn("Invalid leave type ID: {}", leaveTypeIdParam);
                }
            }
            
            // Lọc theo employeeId
            if (employeeIdParam != null && !employeeIdParam.isEmpty()) {
                try {
                    int employeeId = Integer.parseInt(employeeIdParam);
                    final int finalEmployeeId = employeeId;
                    requests = requests.stream()
                        .filter(r -> r.getEmployeeID() == finalEmployeeId)
                        .collect(Collectors.toList());
                } catch (NumberFormatException e) {
                    logger.warn("Invalid employee ID: {}", employeeIdParam);
                }
            }
            
            // Lấy danh sách employees cho filter
            List<Employee> employees;
            if (roleLevel == 1) {
                employees = employeeDAO.getAllEmployees();
            } else {
                employees = employeeDAO.getEmployeesByDivision(user.getDivisionID());
            }
            
            // Set attributes
            request.setAttribute("requests", requests);
            request.setAttribute("divisions", divisions);
            request.setAttribute("leaveTypes", leaveTypeDAO.getAllLeaveTypes());
            request.setAttribute("employees", employees);
            request.setAttribute("selectedStatus", status);
            request.setAttribute("selectedDivisionId", divisionIdParam);
            request.setAttribute("selectedLeaveTypeId", leaveTypeIdParam);
            request.setAttribute("selectedEmployeeId", employeeIdParam);
            request.setAttribute("roleLevel", roleLevel);
            
            logger.info("Employee requests loaded for user {}: {} requests", user.getEmployeeID(), requests.size());
            
        } catch (Exception e) {
            logger.error("Error loading employee leave requests", e);
            request.setAttribute("error", "Không thể tải danh sách đơn: " + e.getMessage());
        }
        
        request.getRequestDispatcher("/request/employee-requests.jsp").forward(request, response);
    }
}