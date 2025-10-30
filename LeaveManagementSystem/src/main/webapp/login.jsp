<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - Hệ thống quản lý nghỉ phép</title>
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
            overflow: hidden;
            background: #0a0e27;
            color: #fff;
        }
        
        /* Background với GLB */
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
        
        /* Hiệu ứng sao lấp lánh */
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
        
        /* Container chính */
        .main-container {
            position: relative;
            z-index: 10;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }
        
        /* Form container */
        .form-container {
            background: rgba(10, 14, 39, 0.85);
            backdrop-filter: blur(20px);
            border-radius: 30px;
            padding: 50px 40px;
            width: 100%;
            max-width: 450px;
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
            margin-bottom: 40px;
        }
        
        .logo-icon {
            width: 80px;
            height: 80px;
            margin: 0 auto 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }
        
        h1 {
            font-size: 28px;
            font-weight: 700;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 10px;
        }
        
        .subtitle {
            color: #94a3b8;
            font-size: 14px;
            font-weight: 400;
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        label {
            display: block;
            margin-bottom: 8px;
            color: #cbd5e1;
            font-size: 14px;
            font-weight: 500;
        }
        
        .input-wrapper {
            position: relative;
        }
        
        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 15px 20px;
            background: rgba(15, 23, 42, 0.6);
            border: 2px solid rgba(99, 102, 241, 0.3);
            border-radius: 12px;
            color: #fff;
            font-size: 15px;
            font-family: 'Be Vietnam Pro', sans-serif;
            transition: all 0.3s ease;
        }
        
        input[type="text"]:focus,
        input[type="password"]:focus {
            outline: none;
            border-color: #667eea;
            background: rgba(15, 23, 42, 0.8);
            box-shadow: 0 0 20px rgba(102, 126, 234, 0.3);
        }
        
        input::placeholder {
            color: #64748b;
        }
        
        .remember-me {
            display: flex;
            align-items: center;
            margin-bottom: 25px;
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
        }
        
        .btn-primary {
            width: 100%;
            padding: 16px;
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
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 40px rgba(102, 126, 234, 0.5);
        }
        
        .btn-primary:active {
            transform: translateY(0);
        }
        
        .divider {
            text-align: center;
            margin: 30px 0;
            position: relative;
        }
        
        .divider::before,
        .divider::after {
            content: '';
            position: absolute;
            top: 50%;
            width: 40%;
            height: 1px;
            background: rgba(99, 102, 241, 0.3);
        }
        
        .divider::before {
            left: 0;
        }
        
        .divider::after {
            right: 0;
        }
        
        .divider span {
            color: #94a3b8;
            font-size: 14px;
            padding: 0 15px;
            background: rgba(10, 14, 39, 0.85);
        }
        
        .register-link {
            text-align: center;
            margin-top: 25px;
            color: #94a3b8;
            font-size: 14px;
        }
        
        .register-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .register-link a:hover {
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
        
        .alert-success {
            background: rgba(34, 197, 94, 0.2);
            border: 1px solid rgba(34, 197, 94, 0.5);
            color: #86efac;
        }
        
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-10px); }
            75% { transform: translateX(10px); }
        }
        
        /* Loading animation */
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
        
        /* Responsive */
        @media (max-width: 768px) {
            .form-container {
                padding: 40px 30px;
            }
            
            h1 {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>
    <!-- Loading Screen -->
    <div class="loading" id="loading">
        <div class="spinner"></div>
    </div>

    <!-- Background với GLB -->
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

    <!-- Hiệu ứng sao -->
    <div class="stars" id="stars"></div>

    <!-- Form đăng nhập -->
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

            <form action="${pageContext.request.contextPath}/login" method="post">
                <div class="form-group">
                    <label for="username">Tên đăng nhập</label>
                    <div class="input-wrapper">
                        <input type="text" 
                               id="username" 
                               name="username" 
                               placeholder="Nhập tên đăng nhập"
                               value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>"
                               required
                               autofocus>
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Mật khẩu</label>
                    <div class="input-wrapper">
                        <input type="password" 
                               id="password" 
                               name="password" 
                               placeholder="Nhập mật khẩu"
                               required>
                    </div>
                </div>

                <div class="remember-me">
                    <input type="checkbox" id="remember" name="remember">
                    <label for="remember">Ghi nhớ đăng nhập</label>
                </div>

                <button type="submit" class="btn-primary">Đăng nhập</button>

                <div class="divider">
                    <span>Hoặc</span>
                </div>

                <div class="register-link">
                    Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register">Đăng ký ngay</a>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Tạo hiệu ứng sao
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
        
        // Ẩn loading khi trang load xong
        window.addEventListener('load', function() {
            createStars();
            setTimeout(() => {
                document.getElementById('loading').classList.add('hidden');
            }, 500);
        });
        
        // Smooth transition khi submit form
        document.querySelector('form').addEventListener('submit', function() {
            document.getElementById('loading').classList.remove('hidden');
        });
    </script>
</body>
</html>