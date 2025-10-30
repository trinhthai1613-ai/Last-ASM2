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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
    <style>
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
                    <%= user.getFullName().substring(0, 1).toUpperCase() %>
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