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
            String leaveTypeParam = request.getParameter("leaveTypeID");
            LocalDate startDate = LocalDate.parse(request.getParameter("startDate"));
            LocalDate endDate = LocalDate.parse(request.getParameter("endDate"));
            String customReason = request.getParameter("customReason");
            
            // Validate dates
            if (endDate.isBefore(startDate)) {
                request.setAttribute("error", "Ngày kết thúc phải lớn hơn hoặc bằng ngày bắt đầu!");
                doGet(request, response);
                return;
            }
            
            // Xử lý khi người dùng chọn "Khác"
            int leaveTypeID;
            if ("other".equals(leaveTypeParam)) {
                // Validate: khi chọn "Khác" thì BẮT BUỘC phải có customReason
                if (customReason == null || customReason.trim().isEmpty()) {
                    request.setAttribute("error", "Vui lòng nhập lý do khi chọn loại nghỉ 'Khác'!");
                    doGet(request, response);
                    return;
                }
                
                // Tìm hoặc tạo LeaveType "OTHER" trong database
                // Giả sử có sẵn LeaveType với code "OTHER" trong DB
                LeaveType otherType = leaveTypeDAO.getLeaveTypeByCode("OTHER");
                if (otherType != null) {
                    leaveTypeID = otherType.getLeaveTypeID();
                } else {
                    // Nếu không có, sử dụng loại mặc định (ví dụ: Annual Leave)
                    // Hoặc có thể throw exception yêu cầu admin thêm loại "OTHER" vào DB
                    request.setAttribute("error", "Loại nghỉ 'Khác' chưa được cấu hình trong hệ thống. Vui lòng liên hệ quản trị viên!");
                    doGet(request, response);
                    return;
                }
            } else {
                leaveTypeID = Integer.parseInt(leaveTypeParam);
                
                // Validate: check xem loại nghỉ này có cho phép custom reason không
                LeaveType selectedType = leaveTypeDAO.getLeaveTypeById(leaveTypeID);
                if (selectedType != null && !selectedType.isAllowCustomReason()) {
                    // Nếu không cho phép custom reason nhưng user vẫn gửi lên, clear nó
                    customReason = null;
                }
            }
            
            // Validate: customReason không được quá dài
            if (customReason != null && customReason.length() > 1000) {
                request.setAttribute("error", "Lý do không được vượt quá 1000 ký tự!");
                doGet(request, response);
                return;
            }
            
            // Tạo LeaveRequest object
            LeaveRequest leaveRequest = new LeaveRequest();
            leaveRequest.setEmployeeID(user.getEmployeeID());
            leaveRequest.setLeaveTypeID(leaveTypeID);
            leaveRequest.setStartDate(startDate);
            leaveRequest.setEndDate(endDate);
            
            // Set customReason - đảm bảo không null nếu không có giá trị
            if (customReason != null && !customReason.trim().isEmpty()) {
                leaveRequest.setCustomReason(customReason.trim());
            } else {
                leaveRequest.setCustomReason(null);
            }
            
            // Log để debug
            logger.info("Creating leave request: EmployeeID={}, LeaveTypeID={}, StartDate={}, EndDate={}, CustomReason={}", 
                       user.getEmployeeID(), leaveTypeID, startDate, endDate, customReason);
            
            // Tạo đơn nghỉ phép
            if (leaveRequestDAO.createLeaveRequest(leaveRequest)) {
                logger.info("Leave request created successfully for employee: {}", user.getEmployeeID());
                session.setAttribute("success", "Tạo đơn nghỉ phép thành công!");
                response.sendRedirect(request.getContextPath() + "/request/list");
            } else {
                logger.error("Failed to create leave request for employee: {}", user.getEmployeeID());
                request.setAttribute("error", "Tạo đơn thất bại. Vui lòng thử lại!");
                doGet(request, response);
            }
            
        } catch (NumberFormatException e) {
            logger.error("Invalid leave type ID format", e);
            request.setAttribute("error", "Loại nghỉ phép không hợp lệ!");
            doGet(request, response);
        } catch (Exception e) {
            logger.error("Error creating leave request", e);
            String errorMessage = e.getMessage();
            
            // Xử lý các lỗi SQL thường gặp
            if (errorMessage != null) {
                if (errorMessage.contains("Cannot insert the value NULL")) {
                    request.setAttribute("error", "Thiếu thông tin bắt buộc. Vui lòng điền đầy đủ thông tin!");
                } else if (errorMessage.contains("CHECK constraint")) {
                    request.setAttribute("error", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin!");
                } else {
                    request.setAttribute("error", "Có lỗi xảy ra: " + errorMessage);
                }
            } else {
                request.setAttribute("error", "Có lỗi xảy ra. Vui lòng thử lại!");
            }
            
            doGet(request, response);
        }
    }
}