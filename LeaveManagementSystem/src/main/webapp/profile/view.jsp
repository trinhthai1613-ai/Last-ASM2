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
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Be Vietnam Pro', sans-serif;
            background: linear-gradient(135deg, #0a0e27 0%, #1a1d3e 50%, #2a2d5e 100%);
            color: #fff;
            min-height: 100vh;
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 12px;
            font-family: 'Be Vietnam Pro', sans-serif;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-secondary {
            background: rgba(99, 102, 241, 0.2);
            border: 1px solid rgba(99, 102, 241, 0.5);
            color: #cbd5e1;
        }
        
        .btn-secondary:hover {
            background: rgba(99, 102, 241, 0.3);
            transform: translateY(-2px);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 40px rgba(102, 126, 234, 0.5);
        }
        
        .card {
            background: rgba(10, 14, 39, 0.7);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 40px;
            border: 1px solid rgba(99, 102, 241, 0.2);
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
        }
        
        .mt-2 {
            margin-top: 20px;
        }
        
        .gradient-text {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            font-weight: 700;
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
            overflow: hidden;
        }
        
        .profile-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .profile-info {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }
        
        .info-item {
            padding: 20px;
            background: rgba(99, 102, 241, 0.1);
            border-radius: 12px;
        }
        
        .info-label {
            font-size: 13px;
            color: #94a3b8;
            margin-bottom: 5px;
        }
        
        .info-value {
            font-size: 16px;
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
            <i class="fas fa-arrow-left"></i> Quay lại
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
                <h1 class="gradient-text"><%= user.getFullName() %></h1>
                <p style="color: #94a3b8;"><%= user.getDivisionName() != null ? user.getDivisionName() : "Nhân viên" %></p>
            </div>
            
            <div class="profile-info">
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-user"></i> Mã nhân viên</div>
                    <div class="info-value"><%= user.getEmployeeCode() %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-envelope"></i> Email</div>
                    <div class="info-value"><%= user.getEmail() %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-phone"></i> Số điện thoại</div>
                    <div class="info-value"><%= user.getPhoneNumber() != null ? user.getPhoneNumber() : "Chưa cập nhật" %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-venus-mars"></i> Giới tính</div>
                    <div class="info-value"><%= user.getGender() != null ? user.getGender() : "Chưa cập nhật" %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-birthday-cake"></i> Ngày sinh</div>
                    <div class="info-value"><%= user.getDateOfBirth() != null ? user.getDateOfBirth().toString() : "Chưa cập nhật" %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-calendar-alt"></i> Ngày vào làm</div>
                    <div class="info-value"><%= user.getHireDate() != null ? user.getHireDate().toString() : "Chưa cập nhật" %></div>
                </div>
            </div>
            
            <div style="margin-top: 30px; text-align: center;">
                <a href="${pageContext.request.contextPath}/profile/edit" class="btn btn-primary">
                    <i class="fas fa-edit"></i> Chỉnh sửa thông tin
                </a>
            </div>
        </div>
    </div>
</body>
</html>