<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - Hệ thống quản lý nghỉ phép</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            background: #ffffff;
            color: #1d1d1f;
            overflow: hidden;
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
            padding: 20px;
        }
        
        .form-container {
            background: #ffffff;
            border-radius: 18px;
            padding: 50px 40px;
            width: 100%;
            max-width: 450px;
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
            margin-bottom: 40px;
        }
        
        .logo-icon {
            width: 70px;
            height: 70px;
            margin: 0 auto 20px;
            background: #000000;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
        }
        
        h1 {
            font-size: 28px;
            font-weight: 600;
            color: #1d1d1f;
            margin-bottom: 10px;
            letter-spacing: -0.02em;
        }
        
        .subtitle {
            color: #6e6e73;
            font-size: 14px;
            font-weight: 400;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        label {
            display: block;
            margin-bottom: 8px;
            color: #1d1d1f;
            font-size: 14px;
            font-weight: 500;
        }
        
        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 12px 16px;
            background: #f5f5f7;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 12px;
            color: #1d1d1f;
            font-size: 15px;
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }
        
        input[type="text"]:focus,
        input[type="password"]:focus {
            outline: none;
            border-color: #000000;
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(0, 0, 0, 0.06);
        }
        
        input::placeholder {
            color: #86868b;
        }
        
        .remember-me {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .remember-me input[type="checkbox"] {
            width: 18px;
            height: 18px;
            margin-right: 10px;
            cursor: pointer;
        }
        
        .remember-me label {
            margin: 0;
            cursor: pointer;
            font-size: 14px;
            font-weight: 400;
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
            letter-spacing: -0.01em;
        }
        
        .btn-primary:hover {
            transform: scale(1.02);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        
        /* Google Login Button */
        .google-btn {
            width: 100%;
            padding: 12px;
            background: #ffffff;
            border: 1px solid rgba(0, 0, 0, 0.15);
            border-radius: 980px;
            color: #1d1d1f;
            font-size: 14px;
            font-weight: 500;
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            display: flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            margin-bottom: 20px;
        }
        
        .google-btn:hover {
            background: #f8f8f8;
            transform: scale(1.02);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
        
        .google-icon {
            width: 20px;
            height: 20px;
            margin-right: 12px;
        }
        
        .divider {
            text-align: center;
            margin: 25px 0;
            position: relative;
        }
        
        .divider::before,
        .divider::after {
            content: '';
            position: absolute;
            top: 50%;
            width: 40%;
            height: 1px;
            background: rgba(0, 0, 0, 0.1);
        }
        
        .divider::before {
            left: 0;
        }
        
        .divider::after {
            right: 0;
        }
        
        .divider span {
            color: #86868b;
            font-size: 14px;
            padding: 0 15px;
            background: #ffffff;
        }
        
        .register-link {
            text-align: center;
            margin-top: 25px;
            color: #6e6e73;
            font-size: 14px;
        }
        
        .register-link a {
            color: #000000;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .register-link a:hover {
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
        
        .alert-success {
            background: rgba(52, 199, 89, 0.1);
            border: 1px solid rgba(52, 199, 89, 0.3);
            color: #34c759;
        }
    </style>
</head>
<body>
    <div class="background"></div>

    <div class="main-container">
        <div class="form-container">
            <div class="logo-container">
                <div class="logo-icon">🚀</div>
                <h1>Đăng nhập</h1>
                <p class="subtitle">Hệ thống quản lý nghỉ phép</p>
            </div>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-error">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <% if (request.getAttribute("success") != null) { %>
                <div class="alert alert-success">
                    <%= request.getAttribute("success") %>
                </div>
            <% } %>

            <!-- Google Login Button -->
            <a href="${pageContext.request.contextPath}/google-login" class="google-btn">
                <svg class="google-icon" viewBox="0 0 24 24">
                    <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                    <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                    <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                    <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                </svg>
                Đăng nhập với Google
            </a>

            <div class="divider">
                <span>Hoặc</span>
            </div>

            <form action="${pageContext.request.contextPath}/login" method="post">
                <div class="form-group">
                    <label for="username">Tên đăng nhập</label>
                    <input type="text" 
                           id="username" 
                           name="username" 
                           placeholder="Nhập tên đăng nhập"
                           value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>"
                           required
                           autofocus>
                </div>

                <div class="form-group">
                    <label for="password">Mật khẩu</label>
                    <input type="password" 
                           id="password" 
                           name="password" 
                           placeholder="Nhập mật khẩu"
                           required>
                </div>

                <div class="remember-me">
                    <input type="checkbox" id="remember" name="remember">
                    <label for="remember">Ghi nhớ đăng nhập</label>
                </div>

                <button type="submit" class="btn-primary">Đăng nhập</button>

                <div class="register-link">
                    Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register">Đăng ký ngay</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>