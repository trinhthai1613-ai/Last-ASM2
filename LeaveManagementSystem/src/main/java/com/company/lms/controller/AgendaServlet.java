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
import java.time.YearMonth;
import java.util.ArrayList;
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
        int roleLevel = employeeService.getLowestRoleLevel(user.getEmployeeID());
        
        if (roleLevel != 1) {
            logger.warn("Unauthorized access to agenda by employee: {}", user.getEmployeeID());
            session.setAttribute("error", "Bạn không có quyền truy cập trang này!");
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        try {
            // Lấy danh sách phòng ban và loại nghỉ phép
            List<Division> divisions = divisionDAO.getAllDivisions();
            request.setAttribute("divisions", divisions);

            // Lấy tham số filter
            String divisionIdParam = request.getParameter("divisionId");
            String employeeIdParam = request.getParameter("employeeId");
            String leaveTypeIdParam = request.getParameter("leaveTypeId");
            String monthParam = request.getParameter("month");

            // Xác định tháng hiển thị
            YearMonth currentMonth;
            if (monthParam != null && !monthParam.isEmpty()) {
                try {
                    currentMonth = YearMonth.parse(monthParam);
                } catch (Exception e) {
                    currentMonth = YearMonth.now();
                }
            } else {
                currentMonth = YearMonth.now();
            }

            LocalDate startDate = currentMonth.atDay(1);
            LocalDate endDate = currentMonth.atEndOfMonth();

            // Parse filters
            Integer selectedDivisionId = null;
            Integer selectedEmployeeId = null;
            Integer selectedLeaveTypeId = null;

            if (divisionIdParam != null && !divisionIdParam.isEmpty()) {
                try {
                    selectedDivisionId = Integer.parseInt(divisionIdParam);
                } catch (NumberFormatException e) {
                    logger.warn("Invalid division ID: {}", divisionIdParam);
                }
            } else {
                selectedDivisionId = user.getDivisionID();
            }

            if (employeeIdParam != null && !employeeIdParam.isEmpty()) {
                try {
                    selectedEmployeeId = Integer.parseInt(employeeIdParam);
                } catch (NumberFormatException e) {
                    logger.warn("Invalid employee ID: {}", employeeIdParam);
                }
            }

            if (leaveTypeIdParam != null && !leaveTypeIdParam.isEmpty()) {
                try {
                    selectedLeaveTypeId = Integer.parseInt(leaveTypeIdParam);
                } catch (NumberFormatException e) {
                    logger.warn("Invalid leave type ID: {}", leaveTypeIdParam);
                }
            }

            // Lấy danh sách nhân viên theo phòng ban
            List<Employee> employees = new ArrayList<>();
            if (selectedDivisionId != null) {
                employees = employeeDAO.getEmployeesByDivision(selectedDivisionId);
            }

            // Lấy danh sách đơn nghỉ đã duyệt
            List<LeaveRequest> leaveRequests = new ArrayList<>();
            if (selectedDivisionId != null) {
                leaveRequests = leaveRequestDAO.getApprovedLeavesByDivisionAndDateRange(
                    selectedDivisionId, startDate, endDate);
                
                // Lọc theo employee nếu được chọn
                if (selectedEmployeeId != null) {
                    final int empId = selectedEmployeeId;
                    leaveRequests.removeIf(lr -> lr.getEmployeeID() != empId);
                }
                
                // Lọc theo leave type nếu được chọn
                if (selectedLeaveTypeId != null) {
                    final int typeId = selectedLeaveTypeId;
                    leaveRequests.removeIf(lr -> lr.getLeaveTypeID() != typeId);
                }
            }

            // Set attributes
            request.setAttribute("employees", employees);
            request.setAttribute("leaveRequests", leaveRequests);
            request.setAttribute("selectedDivisionId", selectedDivisionId);
            request.setAttribute("selectedEmployeeId", selectedEmployeeId);
            request.setAttribute("selectedLeaveTypeId", selectedLeaveTypeId);
            request.setAttribute("currentMonth", currentMonth.toString());
            request.setAttribute("startDate", startDate);
            request.setAttribute("endDate", endDate);

            logger.info("Calendar loaded: division={}, month={}, leaves={}", 
                       selectedDivisionId, currentMonth, leaveRequests.size());

        } catch (Exception e) {
            logger.error("Error loading calendar", e);
            request.setAttribute("error", "Không thể tải lịch nghỉ phép: " + e.getMessage());
        }

        request.getRequestDispatcher("/agenda.jsp").forward(request, response);
    }
}