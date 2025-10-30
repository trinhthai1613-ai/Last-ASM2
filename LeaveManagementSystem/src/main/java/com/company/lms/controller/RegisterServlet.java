package com.company.lms.controller;

import com.company.lms.dao.EmployeeDAO;
import com.company.lms.model.Employee;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(RegisterServlet.class);
    private EmployeeDAO employeeDAO;
    
    @Override
    public void init() throws ServletException {
        employeeDAO = new EmployeeDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String email = request.getParameter("email");
        String fullName = request.getParameter("fullName");
        String phoneNumber = request.getParameter("phoneNumber");
        String gender = request.getParameter("gender");
        String dateOfBirth = request.getParameter("dateOfBirth");
        
        // Validation
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            fullName == null || fullName.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin bắt buộc");
            forwardWithData(request, response);
            return;
        }
        
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp");
            forwardWithData(request, response);
            return;
        }
        
        if (employeeDAO.isUsernameExists(username)) {
            request.setAttribute("error", "Tên đăng nhập đã tồn tại");
            forwardWithData(request, response);
            return;
        }
        
        if (employeeDAO.isEmailExists(email)) {
            request.setAttribute("error", "Email đã được sử dụng");
            forwardWithData(request, response);
            return;
        }
        
        // Create employee
        Employee employee = new Employee();
        employee.setUsername(username.trim());
        employee.setPassword(password); // Không mã hóa theo yêu cầu
        employee.setEmail(email.trim());
        employee.setFullName(fullName.trim());
        employee.setPhoneNumber(phoneNumber);
        employee.setGender(gender);
        
        if (dateOfBirth != null && !dateOfBirth.isEmpty()) {
            try {
                employee.setDateOfBirth(LocalDate.parse(dateOfBirth));
            } catch (Exception e) {
                logger.error("Error parsing date of birth", e);
            }
        }
        
        employee.setDivisionID(1); // Default division
        
        if (employeeDAO.register(employee)) {
            logger.info("New user registered: {}", username);
            request.setAttribute("success", "Đăng ký thành công! Vui lòng đăng nhập");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Đăng ký thất bại. Vui lòng thử lại");
            forwardWithData(request, response);
        }
    }
    
    private void forwardWithData(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("username", request.getParameter("username"));
        request.setAttribute("email", request.getParameter("email"));
        request.setAttribute("fullName", request.getParameter("fullName"));
        request.setAttribute("phoneNumber", request.getParameter("phoneNumber"));
        request.setAttribute("gender", request.getParameter("gender"));
        request.setAttribute("dateOfBirth", request.getParameter("dateOfBirth"));
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }
}