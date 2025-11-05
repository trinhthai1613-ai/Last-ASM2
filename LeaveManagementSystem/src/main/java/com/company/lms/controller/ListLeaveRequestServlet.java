package com.company.lms.controller;

import com.company.lms.dao.DivisionDAO;
import com.company.lms.dao.LeaveRequestDAO;
import com.company.lms.dao.LeaveTypeDAO;
import com.company.lms.model.Division;
import com.company.lms.model.Employee;
import com.company.lms.model.LeaveRequest;
import com.company.lms.model.LeaveType;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

public class ListLeaveRequestServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(ListLeaveRequestServlet.class);
    private LeaveRequestDAO leaveRequestDAO;
    private DivisionDAO divisionDAO;
    private LeaveTypeDAO leaveTypeDAO;
    
    @Override
    public void init() throws ServletException {
        leaveRequestDAO = new LeaveRequestDAO();
        divisionDAO = new DivisionDAO();
        leaveTypeDAO = new LeaveTypeDAO();
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
        
        try {
            // Lấy tham số filter
            String status = request.getParameter("status");
            String divisionIdParam = request.getParameter("divisionId");
            String leaveTypeIdParam = request.getParameter("leaveTypeId");
            
            // Lấy danh sách đơn của nhân viên
            List<LeaveRequest> requests = leaveRequestDAO.getLeaveRequests(user.getEmployeeID(), null);
            
            // Lọc theo status
            if (status != null && !status.isEmpty()) {
                requests = requests.stream()
                    .filter(r -> status.equals(r.getStatus()))
                    .collect(Collectors.toList());
            }
            
            // Lọc theo divisionId (nếu có)
            if (divisionIdParam != null && !divisionIdParam.isEmpty()) {
                try {
                    int divisionId = Integer.parseInt(divisionIdParam);
                    requests = requests.stream()
                        .filter(r -> r.getEmployeeID() == user.getEmployeeID()) // Chỉ show đơn của mình
                        .collect(Collectors.toList());
                } catch (NumberFormatException e) {
                    logger.warn("Invalid division ID: {}", divisionIdParam);
                }
            }
            
            // Lọc theo leaveTypeId
            if (leaveTypeIdParam != null && !leaveTypeIdParam.isEmpty()) {
                try {
                    int leaveTypeId = Integer.parseInt(leaveTypeIdParam);
                    requests = requests.stream()
                        .filter(r -> r.getLeaveTypeID() == leaveTypeId)
                        .collect(Collectors.toList());
                } catch (NumberFormatException e) {
                    logger.warn("Invalid leave type ID: {}", leaveTypeIdParam);
                }
            }
            
            // Set attributes
            request.setAttribute("requests", requests);
            request.setAttribute("divisions", divisionDAO.getAllDivisions());
            request.setAttribute("leaveTypes", leaveTypeDAO.getAllLeaveTypes());
            request.setAttribute("selectedStatus", status);
            request.setAttribute("selectedDivisionId", divisionIdParam);
            request.setAttribute("selectedLeaveTypeId", leaveTypeIdParam);
            
            logger.info("List loaded for user {}: {} requests", user.getEmployeeID(), requests.size());
            
        } catch (Exception e) {
            logger.error("Error loading leave requests", e);
            request.setAttribute("error", "Không thể tải danh sách đơn: " + e.getMessage());
        }
        
        request.getRequestDispatcher("/request/list.jsp").forward(request, response);
    }
}