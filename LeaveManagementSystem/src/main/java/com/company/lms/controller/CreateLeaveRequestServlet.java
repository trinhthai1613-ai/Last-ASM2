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
            
            // Xử lý logic tạo đơn nghỉ phép
            int leaveTypeID;
            String finalReason = null; // Lý do cuối cùng để lưu vào DB
            
            if ("other".equals(leaveTypeParam)) {
                // KHI CHỌN "KHÁC": BẮT BUỘC phải nhập lý do tùy chỉnh
                if (customReason == null || customReason.trim().isEmpty()) {
                    request.setAttribute("error", "Vui lòng nhập lý do khi chọn loại nghỉ 'Khác'!");
                    doGet(request, response);
                    return;
                }
                
                // Tìm LeaveType "OTHER" trong database
                LeaveType otherType = leaveTypeDAO.getLeaveTypeByCode("OTHER");
                if (otherType != null) {
                    leaveTypeID = otherType.getLeaveTypeID();
                    finalReason = customReason.trim(); // Sử dụng lý do người dùng nhập
                } else {
                    request.setAttribute("error", "Loại nghỉ 'Khác' chưa được cấu hình trong hệ thống. Vui lòng liên hệ quản trị viên!");
                    doGet(request, response);
                    return;
                }
            } else {
                // KHI CHỌN CÁC LOẠI NGHỈ PHÉP TEMPLATE
                leaveTypeID = Integer.parseInt(leaveTypeParam);
                
                // Lấy thông tin loại nghỉ phép đã chọn
                LeaveType selectedType = leaveTypeDAO.getLeaveTypeById(leaveTypeID);
                if (selectedType == null) {
                    request.setAttribute("error", "Loại nghỉ phép không hợp lệ!");
                    doGet(request, response);
                    return;
                }
                
                // **FIX CHÍNH**: Tự động lấy tên loại nghỉ phép làm reason
                // Điều này đảm bảo stored procedure luôn nhận được giá trị @CustomReason
                finalReason = selectedType.getLeaveTypeName();
                
                // Nếu loại nghỉ phép cho phép custom reason và user có nhập thêm
                if (selectedType.isAllowCustomReason() && 
                    customReason != null && !customReason.trim().isEmpty()) {
                    // Kết hợp: tên loại + lý do tùy chỉnh
                    finalReason = selectedType.getLeaveTypeName() + " - " + customReason.trim();
                }
            }
            
            // Validate: customReason không được quá dài
            if (finalReason != null && finalReason.length() > 1000) {
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
            
            // Set customReason với giá trị finalReason (luôn có giá trị)
            // Điều này đảm bảo stored procedure nhận được @CustomReason không phải NULL
            leaveRequest.setCustomReason(finalReason);
            
            // Log để debug
            logger.info("Creating leave request: EmployeeID={}, LeaveTypeID={}, StartDate={}, EndDate={}, CustomReason={}", 
                       user.getEmployeeID(), leaveTypeID, startDate, endDate, finalReason);
            
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