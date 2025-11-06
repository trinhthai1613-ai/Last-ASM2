package com.company.lms.controller;

import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.company.lms.config.GoogleOAuthConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/google-login")
public class GoogleLoginServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        try {
            // Tạo authorization URL
            GoogleAuthorizationCodeFlow flow = GoogleOAuthConfig.getFlow();
            
            String authorizationUrl = flow.newAuthorizationUrl()
                .setRedirectUri(GoogleOAuthConfig.getRedirectUri())
                .setState(generateState(req)) // CSRF protection
                .build();
            
            // Redirect người dùng đến Google
            resp.sendRedirect(authorizationUrl);
            
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Không thể kết nối với Google. Vui lòng thử lại.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }
    
    private String generateState(HttpServletRequest req) {
        // Tạo random state cho CSRF protection
        String state = java.util.UUID.randomUUID().toString();
        req.getSession().setAttribute("google_oauth_state", state);
        return state;
    }
}