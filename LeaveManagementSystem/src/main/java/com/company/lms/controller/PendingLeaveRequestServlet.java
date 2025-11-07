package com.company.lms.controller;

import com.company.lms.dao.DivisionDAO;
import com.company.lms.dao.LeaveRequestDAO;
import com.company.lms.model.Division;
import com.company.lms.model.Employee;
import com.company.lms.model.LeaveRequest;
import com.company.lms.service.EmployeeService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/request/pending")
public class PendingLeaveRequestServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(PendingLeaveRequestServlet.class);
    private LeaveRequestDAO leaveRequestDAO;
    private EmployeeService employeeService;
    private DivisionDAO divisionDAO;
    
    @Override
    public void init() throws ServletException {
        leaveRequestDAO = new LeaveRequestDAO();
        employeeService = new EmployeeService();
        divisionDAO = new DivisionDAO();
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
        int employeeID = user.getEmployeeID();
        
        // Kiểm tra quyền
        boolean isHRManager = employeeService.isHRManager(employeeID);
        boolean isDivLeader = employeeService.isDivisionLeader(employeeID);
        boolean isCEO = employeeService.isCEOorAdmin(employeeID);
        
        // Chỉ HR Manager, Division Leader và CEO mới được truy cập
        if (!isHRManager && !isDivLeader && !isCEO) {
            int roleLevel = employeeService.getLowestRoleLevel(employeeID);
            logger.warn("Unauthorized access to pending requests by employee: {} with level: {}", 
                        employeeID, roleLevel);
            session.setAttribute("error", "Bạn không có quyền truy cập trang này!");
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        
        List<LeaveRequest> pendingRequests;
        List<Division> allDivisions = null;
        
        // HR Manager hoặc CEO: Có thể xem tất cả hoặc filter theo phòng ban
        if (isHRManager || isCEO) {
            allDivisions = divisionDAO.getAllDivisions();
            
            // Lấy filter từ request
            String[] selectedDivisionIDs = request.getParameterValues("divisionIDs");
            
            if (selectedDivisionIDs != null && selectedDivisionIDs.length > 0) {
                // Filter theo các phòng ban được chọn
                List<Integer> divisionIDs = Arrays.stream(selectedDivisionIDs)
                    .map(Integer::parseInt)
                    .collect(Collectors.toList());
                pendingRequests = leaveRequestDAO.getPendingLeaveRequestsByDivisions(divisionIDs);
                request.setAttribute("selectedDivisions", selectedDivisionIDs);
            } else {
                // Không filter - lấy tất cả
                pendingRequests = leaveRequestDAO.getPendingLeaveRequests();
            }
            
            request.setAttribute("isHRManager", true);
            request.setAttribute("allDivisions", allDivisions);
            
        } else if (isDivLeader) {
            // Division Leader: Chỉ xem đơn của phòng mình
            int divisionID = user.getDivisionID();
            pendingRequests = leaveRequestDAO.getPendingLeaveRequestsByDivision(divisionID);
            request.setAttribute("isDivisionLeader", true);
            request.setAttribute("userDivisionName", user.getDivisionName());
        } else {
            pendingRequests = new ArrayList<>();
        }
        
        logger.info("User {} (HR:{}, DivLeader:{}, CEO:{}) viewing {} pending requests", 
                   employeeID, isHRManager, isDivLeader, isCEO, pendingRequests.size());
        
        request.setAttribute("pendingRequests", pendingRequests);
        request.getRequestDispatcher("/request/pending.jsp").forward(request, response);
    }
}