package com.company.lms.controller;

import com.company.lms.dao.DivisionDAO;
import com.company.lms.dao.EmployeeDAO;
import com.company.lms.dao.LeaveRequestDAO;
import com.company.lms.model.Employee;
import com.company.lms.model.LeaveRequest;
import com.company.lms.service.EmployeeService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.List;

public class ExportServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(ExportServlet.class);
    private LeaveRequestDAO leaveRequestDAO;
    private EmployeeDAO employeeDAO;
    private EmployeeService employeeService;

    @Override
    public void init() throws ServletException {
        leaveRequestDAO = new LeaveRequestDAO();
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
        
        // Chỉ CEO mới được export
        if (roleLevel != 1) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập!");
            return;
        }

        String action = request.getParameter("action");
        
        if ("csv".equals(action)) {
            exportCSV(request, response);
        } else {
            request.getRequestDispatcher("/export.jsp").forward(request, response);
        }
    }

    private void exportCSV(HttpServletRequest request, HttpServletResponse response) {
    String startDateParam = request.getParameter("startDate");
    String endDateParam = request.getParameter("endDate");
    String divisionIdParam = request.getParameter("divisionId");

    LocalDate startDate = startDateParam != null ? LocalDate.parse(startDateParam) : LocalDate.now().withDayOfMonth(1);
    LocalDate endDate = endDateParam != null ? LocalDate.parse(endDateParam) : LocalDate.now().withDayOfMonth(LocalDate.now().lengthOfMonth());

    Integer divisionId = null;
    if (divisionIdParam != null && !divisionIdParam.isEmpty()) {
        try {
            divisionId = Integer.parseInt(divisionIdParam);
        } catch (NumberFormatException e) {
            logger.warn("Invalid division ID: {}", divisionIdParam);
        }
    }

    List<LeaveRequest> requests;
    List<Employee> employees;
    
    if (divisionId != null) {
        requests = leaveRequestDAO.getApprovedLeavesByDivisionAndDateRange(divisionId, startDate, endDate);
        employees = employeeDAO.getEmployeesByDivision(divisionId);
    } else {
        requests = leaveRequestDAO.getAllApprovedLeavesByDateRange(startDate, endDate);
        employees = employeeDAO.getAllActiveEmployees();
    }

    response.setContentType("text/csv; charset=UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Content-Disposition",
            "attachment; filename=\"lich_nghi_phep_" + startDate + "_den_" + endDate + ".csv\"");

    try (PrintWriter writer = response.getWriter()) {
        writer.write('\ufeff');
        
        writer.println("Nhan vien,Phong ban,Ngay,Loai nghi,Ly do");

        java.time.format.DateTimeFormatter dateFormatter = 
            java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");

        for (Employee emp : employees) {
            LocalDate current = startDate;
            while (!current.isAfter(endDate)) {
                for (LeaveRequest lr : requests) {
                    if (lr.getEmployeeID() == emp.getEmployeeID() &&
                            !current.isBefore(lr.getStartDate()) &&
                            !current.isAfter(lr.getEndDate())) {
                        
                        String reason = lr.getReason()
                                .replace("\"", "\"\"")
                                .replace("\n", " ")
                                .replace("\r", "");
                        
                        // ✅ Thêm dấu = trước để Excel hiểu là text
                        writer.printf("\"%s\",\"%s\",=\"%s\",\"%s\",\"%s\"%n",
                                emp.getFullName(),
                                emp.getDivisionName() != null ? emp.getDivisionName() : "",
                                current.format(dateFormatter),
                                lr.getLeaveTypeName(),
                                reason);
                        break;
                    }
                }
                current = current.plusDays(1);
            }
        }
        
        logger.info("CSV exported: {} employees", employees.size());
    } catch (IOException e) {
        logger.error("Error exporting CSV", e);
    }
}
}