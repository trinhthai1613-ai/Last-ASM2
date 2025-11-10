package com.company.lms.controller;

import com.company.lms.dao.AuditLogDAO;
import com.company.lms.dao.EmployeeDAO;
import com.company.lms.dao.DivisionDAO;
import com.company.lms.model.AuditLog;
import com.company.lms.model.Employee;
import com.company.lms.model.Division;
import com.company.lms.service.EmployeeService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.sql.Date;
import java.util.List;

public class AuditLogsServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(AuditLogsServlet.class);
    private AuditLogDAO auditLogDAO;
    private EmployeeDAO employeeDAO;
    private DivisionDAO divisionDAO;
    private EmployeeService employeeService;
    
    @Override
    public void init() throws ServletException {
        auditLogDAO = new AuditLogDAO();
        employeeDAO = new EmployeeDAO();
        divisionDAO = new DivisionDAO();
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
        
        // Chỉ CEO (level 1) mới được xem
        if (roleLevel != 1) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        
        try {
            // Lấy tham số filter
            String divisionIdParam = request.getParameter("divisionId");
            String employeeIdParam = request.getParameter("employeeId");
            String actionParam = request.getParameter("action");
            String fromDateParam = request.getParameter("fromDate");
            String toDateParam = request.getParameter("toDate");
            
            Integer divisionId = null;
            if (divisionIdParam != null && !divisionIdParam.isEmpty()) {
                try {
                    divisionId = Integer.parseInt(divisionIdParam);
                } catch (NumberFormatException e) {
                    logger.warn("Invalid division ID: {}", divisionIdParam);
                }
            }
            
            Integer employeeId = null;
            if (employeeIdParam != null && !employeeIdParam.isEmpty()) {
                try {
                    employeeId = Integer.parseInt(employeeIdParam);
                } catch (NumberFormatException e) {
                    logger.warn("Invalid employee ID: {}", employeeIdParam);
                }
            }
            
            Date fromDate = null;
            if (fromDateParam != null && !fromDateParam.isEmpty()) {
                try {
                    fromDate = Date.valueOf(fromDateParam);
                } catch (IllegalArgumentException e) {
                    logger.warn("Invalid from date: {}", fromDateParam);
                }
            }
            
            Date toDate = null;
            if (toDateParam != null && !toDateParam.isEmpty()) {
                try {
                    toDate = Date.valueOf(toDateParam);
                } catch (IllegalArgumentException e) {
                    logger.warn("Invalid to date: {}", toDateParam);
                }
            }
            
            // Lấy danh sách audit logs
            List<AuditLog> logs = auditLogDAO.getAuditLogsWithDivision(
                divisionId, employeeId, fromDate, toDate, actionParam
            );
            
            // Lấy danh sách divisions và employees cho filter
            List<Division> divisions = divisionDAO.getAllDivisions();
            List<Employee> employees = employeeDAO.getAllEmployees();
            
            // Set attributes
            request.setAttribute("logs", logs);
            request.setAttribute("divisions", divisions);
            request.setAttribute("employees", employees);
            request.setAttribute("selectedDivisionId", divisionIdParam);
            request.setAttribute("selectedEmployeeId", employeeIdParam);
            request.setAttribute("selectedAction", actionParam);
            request.setAttribute("selectedFromDate", fromDateParam);
            request.setAttribute("selectedToDate", toDateParam);
            
            logger.info("Audit logs loaded for CEO {}: {} logs", user.getEmployeeID(), logs.size());
            
        } catch (Exception e) {
            logger.error("Error loading audit logs", e);
            request.setAttribute("error", "Không thể tải audit logs: " + e.getMessage());
        }
        
        request.getRequestDispatcher("/audit/logs.jsp").forward(request, response);
    }
}