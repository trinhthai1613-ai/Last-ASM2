<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký - Hệ thống quản lý nghỉ phép</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            background: #ffffff;
            color: #1d1d1f;
            overflow-x: hidden;
            -webkit-font-smoothing: antialiased;
        }
        .background {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, #f5f5f7 0%, #e8e8ed 100%);
            z-index: 1;
        }
        .main-container {
            position: relative;
            z-index: 10;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 40px 20px;
        }
        .form-container {
            background: #ffffff;
            border-radius: 18px;
            padding: 50px 40px;
            width: 100%;
            max-width: 550px;
            box-shadow: 0 2px 16px rgba(0, 0, 0, 0.08);
            border: 1px solid rgba(0, 0, 0, 0.1);
            opacity: 0;
            transform: translateY(30px);
            animation: slideIn 0.8s ease forwards;
        }
        @keyframes slideIn {
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        .logo-container {
            text-align: center;
            margin-bottom: 35px;
        }
        .logo-icon {
            width: 64px;
            height: 64px;
            margin: 0 auto 15px;
            background: #000000;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 30px;
        }
        h1 {
            font-size: 26px;
            font-weight: 600;
            color: #1d1d1f;
            margin-bottom: 8px;
            letter-spacing: -0.02em;
        }
        .subtitle {
            color: #6e6e73;
            font-size: 14px;
            font-weight: 400;
        }
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-bottom: 16px;
        }
        .form-group {
            margin-bottom: 16px;
        }
        .form-group.full-width {
            grid-column: 1 / -1;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #1d1d1f;
            font-size: 13px;
            font-weight: 500;
        }
        label .required {
            color: #ff3b30;
        }
        input[type="text"],
        input[type="email"],
        input[type="password"],
        input[type="tel"],
        input[type="date"],
        select {
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
        input:focus,
        select:focus {
            outline: none;
            border-color: #000000;
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(0, 0, 0, 0.06);
        }
        input::placeholder {
            color: #86868b;
        }
        select {
            cursor: pointer;
        }
        .btn-primary {
            width: 100%;
            padding: 12px;
            background: #000000;
            border: none;
            border-radius: 980px;
            color: #ffffff;
            font-size: 14px;
            font-weight: 500;
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            margin-top: 10px;
            letter-spacing: -0.01em;
        }
        .btn-primary:hover {
            transform: scale(1.02);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        .login-link {
            text-align: center;
            margin-top: 25px;
            color: #6e6e73;
            font-size: 14px;
        }
        .login-link a {
            color: #000000;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        .login-link a:hover {
            text-decoration: underline;
        }
        .alert {
            padding: 12px 16px;
            border-radius: 12px;
            margin-bottom: 20px;
            font-size: 14px;
        }
        .alert-error {
            background: rgba(255, 59, 48, 0.1);
            border: 1px solid rgba(255, 59, 48, 0.3);
            color: #ff3b30;
        }
        @media (max-width: 768px) {
            .form-container {
                padding: 40px 30px;
            }
            .form-row {
                grid-template-columns: 1fr;
            }
            h1 {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>
    <div class="background"></div>

    <div class="main-container">
        <div class="form-container">
            <div class="logo-container">
                <div class="logo-icon">✨</div>
                <h1>Đăng ký tài khoản</h1>
                <p class="subtitle">Tạo tài khoản mới để sử dụng hệ thống</p>
            </div>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-error">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/register" method="post">
                <div class="form-group">
                    <label for="fullName">Họ và tên <span class="required">*</span></label>
                    <input type="text" 
                           id="fullName" 
                           name="fullName" 
                           placeholder="Nguyễn Văn A"
                           value="<%= request.getAttribute("fullName") != null ? request.getAttribute("fullName") : "" %>"
                           required
                           autofocus>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="username">Tên đăng nhập <span class="required">*</span></label>
                        <input type="text" 
                               id="username" 
                               name="username" 
                               placeholder="nguyenvana"
                               value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="email">Email <span class="required">*</span></label>
                        <input type="email" 
                               id="email" 
                               name="email" 
                               placeholder="example@company.com"
                               value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>"
                               required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="password">Mật khẩu <span class="required">*</span></label>
                        <input type="password" 
                               id="password" 
                               name="password" 
                               placeholder="Nhập mật khẩu"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="confirmPassword">Xác nhận mật khẩu <span class="required">*</span></label>
                        <input type="password" 
                               id="confirmPassword" 
                               name="confirmPassword" 
                               placeholder="Nhập lại mật khẩu"
                               required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="phoneNumber">Số điện thoại</label>
                        <input type="tel" 
                               id="phoneNumber" 
                               name="phoneNumber" 
                               placeholder="0912345678"
                               value="<%= request.getAttribute("phoneNumber") != null ? request.getAttribute("phoneNumber") : "" %>">
                    </div>

                    <div class="form-group">
                        <label for="gender">Giới tính</label>
                        <select id="gender" name="gender">
                            <option value="">Chọn giới tính</option>
                            <option value="Nam" <%= "Nam".equals(request.getAttribute("gender")) ? "selected" : "" %>>Nam</option>
                            <option value="Nữ" <%= "Nữ".equals(request.getAttribute("gender")) ? "selected" : "" %>>Nữ</option>
                            <option value="Khác" <%= "Khác".equals(request.getAttribute("gender")) ? "selected" : "" %>>Khác</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label for="dateOfBirth">Ngày sinh</label>
                    <input type="date" 
                           id="dateOfBirth" 
                           name="dateOfBirth"
                           value="<%= request.getAttribute("dateOfBirth") != null ? request.getAttribute("dateOfBirth") : "" %>">
                </div>

                <button type="submit" class="btn-primary">Đăng ký</button>

                <div class="login-link">
                    Đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng nhập ngay</a>
                </div>
            </form>
        </div>
    </div>

    <script>
        document.querySelector('form').addEventListener('submit', function(e) {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password !== confirmPassword) {
                e.preventDefault();
                alert('Mật khẩu xác nhận không khớp!');
                return;
            }
        });
    </script>
</body>
</html>