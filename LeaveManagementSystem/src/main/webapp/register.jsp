<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký - Hệ thống quản lý nghỉ phép</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/3.3.0/model-viewer.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Be Vietnam Pro', sans-serif;
            overflow-x: hidden;
            background: #0a0e27;
            color: #fff;
        }
        
        #background-container {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 1;
        }
        
        model-viewer {
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, #0a0e27 0%, #1a1d3e 50%, #2a2d5e 100%);
        }
        
        .stars {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 2;
            pointer-events: none;
        }
        
        .star {
            position: absolute;
            background: white;
            border-radius: 50%;
            animation: twinkle 3s infinite;
        }
        
        @keyframes twinkle {
            0%, 100% { opacity: 0.3; transform: scale(1); }
            50% { opacity: 1; transform: scale(1.2); }
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
            background: rgba(10, 14, 39, 0.85);
            backdrop-filter: blur(20px);
            border-radius: 30px;
            padding: 50px 40px;
            width: 100%;
            max-width: 550px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5),
                        0 0 100px rgba(99, 102, 241, 0.3);
            border: 1px solid rgba(99, 102, 241, 0.2);
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
            width: 70px;
            height: 70px;
            margin: 0 auto 15px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 35px;
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }
        
        h1 {
            font-size: 26px;
            font-weight: 700;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 8px;
        }
        
        .subtitle {
            color: #94a3b8;
            font-size: 14px;
            font-weight: 400;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group.full-width {
            grid-column: 1 / -1;
        }
        
        label {
            display: block;
            margin-bottom: 8px;
            color: #cbd5e1;
            font-size: 13px;
            font-weight: 500;
        }
        
        label .required {
            color: #f87171;
        }
        
        input[type="text"],
        input[type="email"],
        input[type="password"],
        input[type="tel"],
        input[type="date"],
        select {
            width: 100%;
            padding: 13px 18px;
            background: rgba(15, 23, 42, 0.6);
            border: 2px solid rgba(99, 102, 241, 0.3);
            border-radius: 12px;
            color: #fff;
            font-size: 14px;
            font-family: 'Be Vietnam Pro', sans-serif;
            transition: all 0.3s ease;
        }
        
        input:focus,
        select:focus {
            outline: none;
            border-color: #667eea;
            background: rgba(15, 23, 42, 0.8);
            box-shadow: 0 0 20px rgba(102, 126, 234, 0.3);
        }
        
        input::placeholder {
            color: #64748b;
        }
        
        select {
            cursor: pointer;
        }
        
        select option {
            background: #0f172a;
            color: #fff;
        }
        
        .btn-primary {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            border-radius: 12px;
            color: #fff;
            font-size: 16px;
            font-weight: 600;
            font-family: 'Be Vietnam Pro', sans-serif;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
            margin-top: 10px;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 40px rgba(102, 126, 234, 0.5);
        }
        
        .btn-primary:active {
            transform: translateY(0);
        }
        
        .login-link {
            text-align: center;
            margin-top: 25px;
            color: #94a3b8;
            font-size: 14px;
        }
        
        .login-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .login-link a:hover {
            color: #764ba2;
            text-decoration: underline;
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            font-size: 14px;
            animation: shake 0.5s ease;
        }
        
        .alert-error {
            background: rgba(239, 68, 68, 0.2);
            border: 1px solid rgba(239, 68, 68, 0.5);
            color: #fca5a5;
        }
        
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-10px); }
            75% { transform: translateX(10px); }
        }
        
        .loading {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(10, 14, 39, 0.95);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 9999;
            opacity: 1;
            transition: opacity 0.5s ease;
        }
        
        .loading.hidden {
            opacity: 0;
            pointer-events: none;
        }
        
        .spinner {
            width: 60px;
            height: 60px;
            border: 4px solid rgba(99, 102, 241, 0.2);
            border-top-color: #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
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
    <div class="loading" id="loading">
        <div class="spinner"></div>
    </div>

    <div id="background-container">
        <model-viewer
            src="${pageContext.request.contextPath}/assets/space.glb"
            alt="Space Scene"
            auto-rotate
            camera-controls
            disable-zoom
            rotation-per-second="20deg"
            interpolation-decay="200">
        </model-viewer>
    </div>

    <div class="stars" id="stars"></div>

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
        function createStars() {
            const starsContainer = document.getElementById('stars');
            const numberOfStars = 100;
            
            for (let i = 0; i < numberOfStars; i++) {
                const star = document.createElement('div');
                star.className = 'star';
                star.style.left = Math.random() * 100 + '%';
                star.style.top = Math.random() * 100 + '%';
                star.style.width = Math.random() * 3 + 'px';
                star.style.height = star.style.width;
                star.style.animationDelay = Math.random() * 3 + 's';
                starsContainer.appendChild(star);
            }
        }
        
        window.addEventListener('load', function() {
            createStars();
            setTimeout(() => {
                document.getElementById('loading').classList.add('hidden');
            }, 500);
        });
        
        document.querySelector('form').addEventListener('submit', function(e) {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password !== confirmPassword) {
                e.preventDefault();
                alert('Mật khẩu xác nhận không khớp!');
                return;
            }
            
            document.getElementById('loading').classList.remove('hidden');
        });
    </script>
</body>
</html>