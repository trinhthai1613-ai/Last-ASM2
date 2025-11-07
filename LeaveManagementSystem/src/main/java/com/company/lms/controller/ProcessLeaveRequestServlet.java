package com.company.lms.controller;

import com.company.lms.dao.LeaveRequestDAO;
import com.company.lms.model.Employee;
import com.company.lms.model.LeaveRequest;
import com.company.lms.service.EmployeeService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

@WebServlet("/request/process")
public class ProcessLeaveRequestServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(ProcessLeaveRequestServlet.class);
    private LeaveRequestDAO leaveRequestDAO;
    private EmployeeService employeeService;
    
    @Override
    public void init() throws ServletException {
        leaveRequestDAO = new LeaveRequestDAO();
        employeeService = new EmployeeService();
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
        int employeeID = user.getEmployeeID();
        
        // Kiểm tra quyền
        boolean isHRManager = employeeService.isHRManager(employeeID);
        boolean isDivLeader = employeeService.isDivisionLeader(employeeID);
        boolean isCEO = employeeService.isCEOorAdmin(employeeID);
        
        if (!isHRManager && !isDivLeader && !isCEO) {
            logger.warn("Unauthorized process attempt by employee: {}", employeeID);
            session.setAttribute("error", "Bạn không có quyền duyệt đơn!");
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        
        try {
            int requestID = Integer.parseInt(request.getParameter("requestID"));
            String action = request.getParameter("action"); // APPROVE or REJECT
            String note = request.getParameter("note");
            
            // Validate action
            if (!"APPROVE".equals(action) && !"REJECT".equals(action)) {
                session.setAttribute("error", "Hành động không hợp lệ!");
                response.sendRedirect(request.getContextPath() + "/request/pending");
                return;
            }
            
            // Lấy thông tin đơn để kiểm tra phòng ban
            LeaveRequest leaveRequest = leaveRequestDAO.getLeaveRequestById(requestID);
            
            if (leaveRequest == null) {
                session.setAttribute("error", "Không tìm thấy đơn nghỉ phép!");
                response.sendRedirect(request.getContextPath() + "/request/pending");
                return;
            }
            
            // Division Leader chỉ được duyệt đơn của phòng mình
            if (isDivLeader && !isHRManager && !isCEO) {
                // Lấy divisionID của nhân viên gửi đơn
                int requestDivisionID = leaveRequest.getEmployeeID(); // Cần lấy từ employee
                Employee requestEmployee = new com.company.lms.dao.EmployeeDAO()
                    .getEmployeeById(leaveRequest.getEmployeeID());
                
                if (requestEmployee == null || requestEmployee.getDivisionID() != user.getDivisionID()) {
                    logger.warn("Division Leader {} tried to process request from different division", 
                               employeeID);
                    session.setAttribute("error", 
                        "Bạn chỉ có thể duyệt đơn của nhân viên trong phòng ban của mình!");
                    response.sendRedirect(request.getContextPath() + "/request/pending");
                    return;
                }
            }
            
            // Process leave request
            boolean success = leaveRequestDAO.processLeaveRequest(
                requestID, 
                employeeID, 
                action, 
                note
            );
            
            if (success) {
                String message = "APPROVE".equals(action) ? 
                    "Đã duyệt đơn nghỉ phép thành công!" : 
                    "Đã từ chối đơn nghỉ phép!";
                session.setAttribute("success", message);
                logger.info("Leave request {} processed by user {}: {}", 
                           requestID, employeeID, action);
            } else {
                session.setAttribute("error", "Xử lý đơn thất bại. Vui lòng thử lại!");
                logger.error("Failed to process leave request {}", requestID);
            }
            
        } catch (NumberFormatException e) {
            logger.error("Invalid request ID format", e);
            session.setAttribute("error", "ID đơn không hợp lệ!");
        } catch (Exception e) {
            logger.error("Error processing leave request", e);
            session.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/request/pending");
    }
}