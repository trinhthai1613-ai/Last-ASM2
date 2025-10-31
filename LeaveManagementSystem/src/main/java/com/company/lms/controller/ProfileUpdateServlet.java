package com.company.lms.controller;

import com.company.lms.dao.EmployeeDAO;
import com.company.lms.model.Employee;
import com.company.lms.util.FileUploadUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class ProfileUpdateServlet extends HttpServlet {
    
    private EmployeeDAO employeeDAO;
    
    @Override
    public void init() throws ServletException {
        employeeDAO = new EmployeeDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        Employee user = (Employee) session.getAttribute("user");
        
        try {
            // Get form data
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phoneNumber = request.getParameter("phoneNumber");
            String gender = request.getParameter("gender");
            String dateOfBirthStr = request.getParameter("dateOfBirth");
            
            // Update employee object
            user.setFullName(fullName);
            user.setEmail(email);
            user.setPhoneNumber(phoneNumber);
            user.setGender(gender);
            
            if (dateOfBirthStr != null && !dateOfBirthStr.isEmpty()) {
                user.setDateOfBirth(LocalDate.parse(dateOfBirthStr));
            }
            
            // Handle avatar upload if present
            Part filePart = request.getPart("avatar");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = FileUploadUtil.uploadFile(filePart, getServletContext().getRealPath("/images/uploads"));
                if (fileName != null) {
                    user.setAvatarPath(fileName);
                }
            }
            
            // Update in database
            boolean updated = employeeDAO.updateEmployee(user);
            
            if (updated) {
                // Update session
                session.setAttribute("user", user);
                session.setAttribute("message", "Cập nhật thông tin thành công!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Không thể cập nhật thông tin!");
                session.setAttribute("messageType", "error");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Lỗi: " + e.getMessage());
            session.setAttribute("messageType", "error");
        }
        
        response.sendRedirect(request.getContextPath() + "/profile");
    }
}