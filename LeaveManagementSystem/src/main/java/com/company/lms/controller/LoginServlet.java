package com.company.lms.controller;

import com.company.lms.dao.EmployeeDAO;
import com.company.lms.model.Employee;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(LoginServlet.class);
    private EmployeeDAO employeeDAO;
    
    @Override
    public void init() throws ServletException {
        employeeDAO = new EmployeeDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");
        
        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        Employee employee = employeeDAO.login(username.trim(), password);
        
        if (employee != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", employee);
            session.setAttribute("employeeID", employee.getEmployeeID());
            session.setAttribute("username", employee.getUsername());
            session.setAttribute("fullName", employee.getFullName());
            
            // Remember me cookie
            if ("on".equals(remember)) {
                Cookie userCookie = new Cookie("username", username);
                userCookie.setMaxAge(7 * 24 * 60 * 60); // 7 days
                response.addCookie(userCookie);
            }
            
            logger.info("User logged in successfully: {}", username);
            response.sendRedirect(request.getContextPath() + "/home");
        } else {
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
