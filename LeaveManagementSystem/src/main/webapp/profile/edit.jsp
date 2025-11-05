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
        .mt-2 { margin-top: 20px; }
        h1 {
            font-size: 28px;
            margin-bottom: 30px;
            font-weight: 600;
            letter-spacing: -0.02em;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-label {
            display: block;
            margin-bottom: 8px;
            color: #1d1d1f;
            font-size: 14px;
            font-weight: 500;
        }
        .form-control {
            width: 100%;
            padding: 12px 16px;
            background: #f5f5f7;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 12px;
            color: #1d1d1f;
            font-size: 14px;
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }
        .form-control:focus {
            outline: none;
            border-color: #000000;
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(0, 0, 0, 0.06);
        }
        .avatar-preview {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            margin: 15px auto;
            background: #000000;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            font-weight: 600;
            color: #fff;
            overflow: hidden;
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
            ← Quay lại
        </a>
        
        <div class="card mt-2">
            <h1>✏️ Chỉnh sửa thông tin</h1>
            
            <div class="avatar-preview" id="avatarPreview">
                <% if (user.getAvatarPath() != null && !user.getAvatarPath().isEmpty()) { %>
                    <img src="${pageContext.request.contextPath}/images/uploads/<%= user.getAvatarPath() %>" alt="Avatar" id="previewImg">
                <% } else { %>
                    <span id="previewText"><%= user.getFullName().substring(0, 1).toUpperCase() %></span>
                <% } %>
            </div>
            
            <form action="${pageContext.request.contextPath}/profile/update" method="post" enctype="multipart/form-data">
                <div class="form-group">
                    <label class="form-label">Họ và tên <span style="color: #ff3b30;">*</span></label>
                    <input type="text" name="fullName" class="form-control" value="<%= user.getFullName() %>" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Email <span style="color: #ff3b30;">*</span></label>
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
                    💾 Lưu thay đổi
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