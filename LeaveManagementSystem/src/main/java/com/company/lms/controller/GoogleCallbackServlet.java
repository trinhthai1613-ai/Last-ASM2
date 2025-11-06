package com.company.lms.controller;

import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleTokenResponse;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.company.lms.config.GoogleOAuthConfig;
import com.company.lms.dao.EmployeeDAO;
import com.company.lms.model.Employee;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.Collections;

@WebServlet("/google-callback")
public class GoogleCallbackServlet extends HttpServlet {
    
    private static final Logger logger = LoggerFactory.getLogger(GoogleCallbackServlet.class);
    private EmployeeDAO employeeDAO;
    
    @Override
    public void init() throws ServletException {
        employeeDAO = new EmployeeDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        // Kiểm tra state để chống CSRF
        String state = req.getParameter("state");
        String sessionState = (String) req.getSession().getAttribute("google_oauth_state");
        
        if (state == null || !state.equals(sessionState)) {
            logger.warn("Invalid state parameter - CSRF protection");
            req.setAttribute("error", "Phiên đăng nhập không hợp lệ. Vui lòng thử lại.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }
        
        // Lấy authorization code
        String code = req.getParameter("code");
        if (code == null) {
            logger.warn("Missing authorization code");
            req.setAttribute("error", "Thiếu mã xác thực từ Google.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }
        
        try {
            // Exchange code for tokens
            GoogleAuthorizationCodeFlow flow = GoogleOAuthConfig.getFlow();
            GoogleTokenResponse tokenResponse = flow.newTokenRequest(code)
                .setRedirectUri(GoogleOAuthConfig.getRedirectUri())
                .execute();
            
            // Verify ID token
            String idTokenString = tokenResponse.getIdToken();
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                new NetHttpTransport(), 
                GsonFactory.getDefaultInstance()
            )
            .setAudience(Collections.singletonList(GoogleOAuthConfig.getClientId()))
            .build();
            
            GoogleIdToken idToken = verifier.verify(idTokenString);
            
            if (idToken != null) {
                GoogleIdToken.Payload payload = idToken.getPayload();
                
                // Lấy thông tin user từ Google
                String googleId = payload.getSubject();
                String email = payload.getEmail();
                boolean emailVerified = payload.getEmailVerified();
                String name = (String) payload.get("name");
                String pictureUrl = (String) payload.get("picture");
                
                logger.info("Google login attempt for email: {}", email);
                
                // Kiểm tra email đã được verify chưa
                if (!emailVerified) {
                    req.setAttribute("error", "Email chưa được xác thực bởi Google.");
                    req.getRequestDispatcher("/login.jsp").forward(req, resp);
                    return;
                }
                
                // Tìm hoặc tạo employee trong database
                Employee employee = employeeDAO.findByEmail(email);
                
                if (employee == null) {
                    // Nếu chưa có tài khoản, tạo mới
                    employee = new Employee();
                    employee.setEmail(email);
                    employee.setFullName(name != null ? name : email);
                    employee.setUsername(email); // Dùng email làm username
                    
                    // Tạo EmployeeCode tự động
                    String employeeCode = generateEmployeeCode(email);
                    employee.setEmployeeCode(employeeCode);
                    
                    // Set avatar path
                    employee.setAvatarPath(pictureUrl);
                    
                    // Set password hash (đánh dấu là Google OAuth)
                    employee.setPassword("GOOGLE_OAUTH_" + googleId);
                    
                    // Set division mặc định (ID = 1)
                    employee.setDivisionID(1);
                    
                    // Lưu vào database
                    boolean created = employeeDAO.createEmployeeWithGoogleAuth(employee);
                    
                    if (!created) {
                        logger.error("Failed to create employee for email: {}", email);
                        req.setAttribute("error", "Không thể tạo tài khoản. Vui lòng liên hệ quản trị viên.");
                        req.getRequestDispatcher("/login.jsp").forward(req, resp);
                        return;
                    }
                    
                    logger.info("New employee created via Google: {} (ID: {})", email, employee.getEmployeeID());
                    
                    // Lấy lại employee với đầy đủ thông tin
                    employee = employeeDAO.findByEmail(email);
                    
                } else {
                    // Nếu đã có tài khoản, kiểm tra trạng thái
                    if (!employee.isActive()) {
                        req.setAttribute("error", "Tài khoản của bạn đã bị vô hiệu hóa.");
                        req.getRequestDispatcher("/login.jsp").forward(req, resp);
                        return;
                    }
                    
                    logger.info("Existing employee login via Google: {} (ID: {})", email, employee.getEmployeeID());
                    
                    // Cập nhật last login
                    employeeDAO.updateLastLogin(employee.getEmployeeID());
                    
                    // Cập nhật avatar nếu có thay đổi
                    if (pictureUrl != null && !pictureUrl.equals(employee.getAvatarPath())) {
                        employeeDAO.updateAvatar(employee.getEmployeeID(), pictureUrl);
                        employee.setAvatarPath(pictureUrl);
                    }
                }
                
                // Lưu thông tin vào session (giống như đăng nhập thường)
                HttpSession session = req.getSession();
                session.setAttribute("user", employee);
                session.setAttribute("employeeId", employee.getEmployeeID());
                session.setAttribute("employeeName", employee.getFullName());
                session.setAttribute("employeeEmail", employee.getEmail());
                session.setAttribute("loginMethod", "GOOGLE");
                session.setMaxInactiveInterval(3600);
                
                // Xóa state sau khi xử lý xong
                session.removeAttribute("google_oauth_state");
                
                logger.info("Google login successful for: {}", email);
                
                // Redirect về trang home
                resp.sendRedirect(req.getContextPath() + "/home");
                
            } else {
                logger.error("Invalid ID token");
                req.setAttribute("error", "Xác thực Google không hợp lệ.");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
            }
            
        } catch (Exception e) {
            logger.error("Error during Google authentication", e);
            req.setAttribute("error", "Lỗi xác thực Google: " + e.getMessage());
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }
    
    /**
     * Tạo employee code tự động từ email
     */
    private String generateEmployeeCode(String email) {
        String prefix = email.substring(0, Math.min(3, email.indexOf("@"))).toUpperCase();
        String timestamp = String.valueOf(System.currentTimeMillis() % 100000);
        return "GGL" + prefix + timestamp; // GGL = Google Login
    }
}