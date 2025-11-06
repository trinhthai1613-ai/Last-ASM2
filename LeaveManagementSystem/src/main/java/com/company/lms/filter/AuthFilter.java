package com.company.lms.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class AuthFilter implements Filter {
    
    private static final String[] PUBLIC_URLS = {
    "/login",
    "/register",
    "/google-login",
    "/google-callback",
    "/assets/",
    "/css/",
    "/js/",
    "/images/"
};

    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());
        
        // Allow public resources
        boolean isPublicResource = false;
        for (String publicUrl : PUBLIC_URLS) {
            if (path.startsWith(publicUrl) || path.equals("/") || path.equals("/index.jsp")) {
                isPublicResource = true;
                break;
            }
        }
        
        if (isPublicResource) {
            chain.doFilter(request, response);
            return;
        }
        
        // Check if user is logged in
        HttpSession session = httpRequest.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);
        
        if (isLoggedIn) {
            chain.doFilter(request, response);
        } else {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
        }
    }
}