package com.company.lms.controller;

import com.company.lms.dao.LeaveRequestDAO;
import com.company.lms.dao.LeaveTypeDAO;
import com.company.lms.model.Employee;
import com.company.lms.model.LeaveRequest;
import com.company.lms.model.LeaveType;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;


public class CreateLeaveRequestServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(CreateLeaveRequestServlet.class);
    private LeaveRequestDAO leaveRequestDAO;
    private LeaveTypeDAO leaveTypeDAO;
    
    @Override
    public void init() throws ServletException {
        leaveRequestDAO = new LeaveRequestDAO();
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
        
        List<LeaveType> leaveTypes = leaveTypeDAO.getAllLeaveTypes();
        request.setAttribute("leaveTypes", leaveTypes);
        
        request.getRequestDispatcher("/request/create.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        Employee user = (Employee) session.getAttribute("user");
        
        try {
            int leaveTypeID = Integer.parseInt(request.getParameter("leaveTypeID"));
            LocalDate startDate = LocalDate.parse(request.getParameter("startDate"));
            LocalDate endDate = LocalDate.parse(request.getParameter("endDate"));
            String customReason = request.getParameter("customReason");
            
            LeaveRequest leaveRequest = new LeaveRequest();
            leaveRequest.setEmployeeID(user.getEmployeeID());
            leaveRequest.setLeaveTypeID(leaveTypeID);
            leaveRequest.setStartDate(startDate);
            leaveRequest.setEndDate(endDate);
            leaveRequest.setCustomReason(customReason);
            
            if (leaveRequestDAO.createLeaveRequest(leaveRequest)) {
                request.setAttribute("success", "Tạo đơn nghỉ phép thành công!");
                response.sendRedirect(request.getContextPath() + "/request/list");
            } else {
                request.setAttribute("error", "Tạo đơn thất bại. Vui lòng thử lại!");
                doGet(request, response);
            }
            
        } catch (Exception e) {
            logger.error("Error creating leave request", e);
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            doGet(request, response);
        }
    }
}