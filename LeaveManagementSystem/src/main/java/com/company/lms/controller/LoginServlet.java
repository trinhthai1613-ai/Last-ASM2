package com.company.lms.controller;

import com.company.lms.dao.EmployeeDAO;
import com.company.lms.model.Employee;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

// @WebServlet("/login")  <- XÓA DÒNG NÀY
public class LoginServlet extends HttpServlet {
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
        
        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin!");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        Employee employee = employeeDAO.login(username.trim(), password);
        
        if (employee != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", employee);
            session.setMaxInactiveInterval(3600);
            
            response.sendRedirect(request.getContextPath() + "/home");
        } else {
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không chính xác!");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}