package com.company.lms.controller;

import com.company.lms.dao.DivisionDAO;
import com.company.lms.dao.EmployeeDAO;
import com.company.lms.dao.LeaveRequestDAO;
import com.company.lms.model.Division;
import com.company.lms.model.Employee;
import com.company.lms.model.LeaveRequest;
import com.company.lms.service.EmployeeService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

public class AgendaServlet extends HttpServlet {
    
    private static final Logger logger = LoggerFactory.getLogger(AgendaServlet.class);
    private LeaveRequestDAO leaveRequestDAO;
    private DivisionDAO divisionDAO;
    private EmployeeDAO employeeDAO;
    private EmployeeService employeeService;
    
    @Override
    public void init() throws ServletException {
        leaveRequestDAO = new LeaveRequestDAO();
        divisionDAO = new DivisionDAO();
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
        
        // KIỂM TRA QUYỀN: Chỉ Manager mới được xem agenda
        if (!employeeService.isManager(user.getEmployeeID())) {
            logger.warn("Unauthorized access attempt to agenda by employee: {}", user.getEmployeeID());
            session.setAttribute("error", "Bạn không có quyền truy cập trang này! Chỉ quản lý mới có thể xem lịch nghỉ phép.");
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        
        try {
            // Get all divisions for filter dropdown
            List<Division> divisions = divisionDAO.getAllDivisions();
            request.setAttribute("divisions", divisions);
            
            // Get filter parameters
            String divisionIdParam = request.getParameter("divisionId");
            String startDateParam = request.getParameter("startDate");
            String endDateParam = request.getParameter("endDate");
            
            // Default values
            Integer selectedDivisionId = null;
            LocalDate startDate = LocalDate.now();
            LocalDate endDate = LocalDate.now().plusDays(30);
            
            // Parse division filter
            if (divisionIdParam != null && !divisionIdParam.isEmpty()) {
                try {
                    selectedDivisionId = Integer.parseInt(divisionIdParam);
                } catch (NumberFormatException e) {
                    logger.warn("Invalid division ID: {}", divisionIdParam);
                }
            } else {
                // Default to user's division
                selectedDivisionId = user.getDivisionID();
            }
            
            // Parse date filters
            if (startDateParam != null && !startDateParam.isEmpty()) {
                try {
                    startDate = LocalDate.parse(startDateParam);
                } catch (Exception e) {
                    logger.warn("Invalid start date: {}", startDateParam);
                }
            }
            
            if (endDateParam != null && !endDateParam.isEmpty()) {
                try {
                    endDate = LocalDate.parse(endDateParam);
                } catch (Exception e) {
                    logger.warn("Invalid end date: {}", endDateParam);
                }
            }
            
            // Validate date range
            if (endDate.isBefore(startDate)) {
                endDate = startDate.plusDays(30);
            }
            
            // Get employees in selected division
            List<Employee> employees = null;
            if (selectedDivisionId != null) {
                employees = employeeDAO.getEmployeesByDivision(selectedDivisionId);
            }
            
            // Get approved leave requests for the selected employees in date range
            List<LeaveRequest> leaveRequests = null;
            if (selectedDivisionId != null) {
                leaveRequests = leaveRequestDAO.getApprovedLeavesByDivisionAndDateRange(
                    selectedDivisionId, startDate, endDate);
            }
            
            // Set attributes
            request.setAttribute("employees", employees);
            request.setAttribute("leaveRequests", leaveRequests);
            request.setAttribute("selectedDivisionId", selectedDivisionId);
            request.setAttribute("startDate", startDate.toString());
            request.setAttribute("endDate", endDate.toString());
            
            logger.info("Agenda loaded: division={}, employees={}, leaves={}, dateRange={} to {}", 
                       selectedDivisionId, 
                       employees != null ? employees.size() : 0,
                       leaveRequests != null ? leaveRequests.size() : 0,
                       startDate, endDate);
            
        } catch (Exception e) {
            logger.error("Error loading agenda", e);
            request.setAttribute("error", "Không thể tải lịch nghỉ phép: " + e.getMessage());
        }
        
        // Forward to agenda page
        request.getRequestDispatcher("/agenda.jsp").forward(request, response);
    }
}