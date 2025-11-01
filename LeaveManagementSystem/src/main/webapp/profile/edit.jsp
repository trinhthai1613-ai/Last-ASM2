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
        
        .mb-3 {
            margin-bottom: 30px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 8px;
            color: #cbd5e1;
            font-size: 14px;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 13px 18px;
            background: rgba(15, 23, 42, 0.6);
            border: 2px solid rgba(99, 102, 241, 0.2);
            border-radius: 12px;
            color: white;
            font-size: 14px;
            font-family: 'Be Vietnam Pro', sans-serif;
            transition: all 0.3s ease;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #667eea;
            background: rgba(15, 23, 42, 0.8);
            box-shadow: 0 0 20px rgba(102, 126, 234, 0.3);
        }
        .avatar-preview {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            margin: 15px auto;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            font-weight: 700;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }
        
        .avatar-preview img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
    </style>
</head>
<body>
    <div class="container" style="max-width: 800px; margin: 40px auto; padding: 0 30px;">
        <a href="${pageContext.request.contextPath}/profile" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Quay lại
        </a>
        
        <div class="card mt-2">
            <h1 class="gradient-text mb-3"><i class="fas fa-edit"></i> Chỉnh sửa thông tin</h1>
            
            <!-- Avatar Preview -->
            <div class="avatar-preview" id="avatarPreview">
                <% if (user.getAvatarPath() != null && !user.getAvatarPath().isEmpty()) { %>
                    <img src="${pageContext.request.contextPath}/images/uploads/<%= user.getAvatarPath() %>" alt="Avatar" id="previewImg">
                <% } else { %>
                    <span id="previewText"><%= user.getFullName().substring(0, 1).toUpperCase() %></span>
                <% } %>
            </div>
            
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
                    <input type="file" name="avatar" id="avatarInput" class="form-control" accept="image/*">
                </div>
                
                <button type="submit" class="btn btn-primary" style="width: 100%;">
                    <i class="fas fa-save"></i> Lưu thay đổi
                </button>
            </form>
        </div>
    </div>
    
    <script>
        document.getElementById('avatarInput').addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(event) {
                    const preview = document.getElementById('avatarPreview');
                    const existingImg = preview.querySelector('img');
                    const existingText = preview.querySelector('span');
                    
                    if (existingImg) {
                        existingImg.src = event.target.result;
                    } else {
                        if (existingText) existingText.style.display = 'none';
                        const img = document.createElement('img');
                        img.src = event.target.result;
                        img.id = 'previewImg';
                        preview.appendChild(img);
                    }
                }
                reader.readAsDataURL(file);
            }
        });
    </script>
</body>
</html>