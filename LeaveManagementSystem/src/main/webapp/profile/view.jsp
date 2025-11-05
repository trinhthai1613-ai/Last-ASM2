<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.Employee" %>
<%
    Employee user = (Employee) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin cá nhân</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            background: #ffffff;
            color: #1d1d1f;
            min-height: 100vh;
            -webkit-font-smoothing: antialiased;
        }
        .btn {
            padding: 10px 22px;
            border: none;
            border-radius: 980px;
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            text-decoration: none;
            display: inline-block;
            letter-spacing: -0.01em;
        }
        .btn-secondary {
            background: #f5f5f7;
            border: 1px solid rgba(0, 0, 0, 0.1);
            color: #1d1d1f;
        }
        .btn-secondary:hover {
            background: #e8e8ed;
        }
        .btn-primary {
            background: #000000;
            color: white;
        }
        .btn-primary:hover {
            transform: scale(1.02);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        .card {
            background: #ffffff;
            border-radius: 18px;
            padding: 40px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            box-shadow: 0 2px 16px rgba(0, 0, 0, 0.08);
        }
        .mt-2 {
            margin-top: 20px;
        }
        .profile-container {
            max-width: 900px;
            margin: 40px auto;
            padding: 0 30px;
        }
        .profile-header {
            text-align: center;
            margin-bottom: 40px;
        }
        .profile-avatar {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            margin: 0 auto 20px;
            background: #000000;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            font-weight: 600;
            color: #fff;
            overflow: hidden;
        }
        .profile-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        h1 {
            font-size: 28px;
            font-weight: 600;
            letter-spacing: -0.02em;
            margin-bottom: 8px;
        }
        .profile-info {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }
        .info-item {
            padding: 20px;
            background: #f5f5f7;
            border-radius: 12px;
        }
        .info-label {
            font-size: 12px;
            color: #6e6e73;
            margin-bottom: 6px;
        }
        .info-value {
            font-size: 15px;
            font-weight: 500;
        }
        @media (max-width: 768px) {
            .profile-info {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="profile-container">
        <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary">
            ← Quay lại
        </a>
        
        <div class="card mt-2">
            <div class="profile-header">
                <div class="profile-avatar">
                    <% if (user.getAvatarPath() != null && !user.getAvatarPath().isEmpty()) { %>
                        <img src="${pageContext.request.contextPath}/images/uploads/<%= user.getAvatarPath() %>" alt="Avatar">
                    <% } else { %>
                        <%= user.getFullName().substring(0, 1).toUpperCase() %>
                    <% } %>
                </div>
                <h1><%= user.getFullName() %></h1>
                <p style="color: #6e6e73;"><%= user.getDivisionName() != null ? user.getDivisionName() : "Nhân viên" %></p>
            </div>
            
            <div class="profile-info">
                <div class="info-item">
                    <div class="info-label">👤 Mã nhân viên</div>
                    <div class="info-value"><%= user.getEmployeeCode() %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">📧 Email</div>
                    <div class="info-value"><%= user.getEmail() %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">📱 Số điện thoại</div>
                    <div class="info-value"><%= user.getPhoneNumber() != null ? user.getPhoneNumber() : "Chưa cập nhật" %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">⚥ Giới tính</div>
                    <div class="info-value"><%= user.getGender() != null ? user.getGender() : "Chưa cập nhật" %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">🎂 Ngày sinh</div>
                    <div class="info-value"><%= user.getDateOfBirth() != null ? user.getDateOfBirth().toString() : "Chưa cập nhật" %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">📅 Ngày vào làm</div>
                    <div class="info-value"><%= user.getHireDate() != null ? user.getHireDate().toString() : "Chưa cập nhật" %></div>
                </div>
            </div>
            
            <div style="margin-top: 30px; text-align: center;">
                <a href="${pageContext.request.contextPath}/profile/edit" class="btn btn-primary">
                    ✏️ Chỉnh sửa thông tin
                </a>
            </div>
        </div>
    </div>
</body>
</html>