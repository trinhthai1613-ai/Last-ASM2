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
    <title>Chỉnh sửa thông tin</title>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
</head>
<body>
    <div class="container" style="max-width: 800px; margin: 40px auto; padding: 0 30px;">
        <a href="${pageContext.request.contextPath}/profile" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Quay lại
        </a>
        
        <div class="card mt-2">
            <h1 class="gradient-text mb-3"><i class="fas fa-edit"></i> Chỉnh sửa thông tin</h1>
            
            <form action="${pageContext.request.contextPath}/profile/update" method="post" enctype="multipart/form-data">
                <div class="form-group">
                    <label class="form-label">Họ và tên <span style="color: #ef4444;">*</span></label>
                    <input type="text" name="fullName" class="form-control" value="<%= user.getFullName() %>" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Email <span style="color: #ef4444;">*</span></label>
                    <input type="email" name="email" class="form-control" value="<%= user.getEmail() %>" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Số điện thoại</label>
                    <input type="tel" name="phoneNumber" class="form-control" value="<%= user.getPhoneNumber() != null ? user.getPhoneNumber() : "" %>">
                </div>
                
                <div class="form-group">
                    <label class="form-label">Giới tính</label>
                    <select name="gender" class="form-control">
                        <option value="">Chọn giới tính</option>
                        <option value="Nam" <%= "Nam".equals(user.getGender()) ? "selected" : "" %>>Nam</option>
                        <option value="Nữ" <%= "Nữ".equals(user.getGender()) ? "selected" : "" %>>Nữ</option>
                        <option value="Khác" <%= "Khác".equals(user.getGender()) ? "selected" : "" %>>Khác</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Ngày sinh</label>
                    <input type="date" name="dateOfBirth" class="form-control" value="<%= user.getDateOfBirth() != null ? user.getDateOfBirth().toString() : "" %>">
                </div>
                
                <div class="form-group">
                    <label class="form-label">Ảnh đại diện</label>
                    <input type="file" name="avatar" class="form-control" accept="image/*">
                </div>
                
                <button type="submit" class="btn btn-primary" style="width: 100%;">
                    <i class="fas fa-save"></i> Lưu thay đổi
                </button>
            </form>
        </div>
    </div>
</body>
</html>