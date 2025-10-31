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
    <title>Trang chủ - Leave Management System</title>
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
            min-height: 100vh;
            color: #fff;
        }
        
        /* Navigation */
        .navbar {
            background: rgba(10, 14, 39, 0.95);
            backdrop-filter: blur(20px);
            padding: 20px 0;
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.3);
            border-bottom: 1px solid rgba(99, 102, 241, 0.2);
            position: sticky;
            top: 0;
            z-index: 100;
        }
        
        .nav-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .logo {
            display: flex;
            align-items: center;
            gap: 15px;
            font-size: 24px;
            font-weight: 700;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        .logo i {
            font-size: 32px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        .nav-menu {
            display: flex;
            gap: 30px;
            align-items: center;
        }
        
        .nav-menu a {
            color: #cbd5e1;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            padding: 8px 16px;
            border-radius: 8px;
        }
        
        .nav-menu a:hover {
            color: #667eea;
            background: rgba(102, 126, 234, 0.1);
        }
        
        .user-menu {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .user-avatar {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 18px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .user-avatar:hover {
            transform: scale(1.1);
            box-shadow: 0 0 20px rgba(102, 126, 234, 0.5);
        }
        
        .user-info {
            display: flex;
            flex-direction: column;
        }
        
        .user-name {
            font-weight: 600;
            font-size: 16px;
        }
        
        .user-role {
            font-size: 13px;
            color: #94a3b8;
        }
        
        /* Main Container */
        .main-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 40px 30px;
        }
        
        .welcome-section {
            background: rgba(10, 14, 39, 0.7);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 40px;
            margin-bottom: 40px;
            border: 1px solid rgba(99, 102, 241, 0.2);
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
        }
        
        .welcome-section h1 {
            font-size: 36px;
            margin-bottom: 15px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        .welcome-section p {
            font-size: 18px;
            color: #94a3b8;
        }
        
        /* Dashboard Cards */
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            margin-bottom: 40px;
        }
        
        .dashboard-card {
            background: rgba(10, 14, 39, 0.7);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 30px;
            border: 1px solid rgba(99, 102, 241, 0.2);
            transition: all 0.3s ease;
            cursor: pointer;
        }
        
        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 50px rgba(102, 126, 234, 0.3);
            border-color: rgba(99, 102, 241, 0.5);
        }
        
        .card-icon {
            width: 60px;
            height: 60px;
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            margin-bottom: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .card-title {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 10px;
        }
        
        .card-description {
            color: #94a3b8;
            font-size: 14px;
            line-height: 1.6;
        }
        
        .card-value {
            font-size: 32px;
            font-weight: 700;
            margin: 15px 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        /* Quick Actions */
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
        }
        
        .action-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            border-radius: 15px;
            padding: 20px 30px;
            color: #fff;
            font-size: 16px;
            font-weight: 600;
            font-family: 'Be Vietnam Pro', sans-serif;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }
        
        .action-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 40px rgba(102, 126, 234, 0.5);
        }
        
        .action-btn i {
            font-size: 20px;
        }
        
        .action-btn-primary {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            box-shadow: 0 10px 30px rgba(16, 185, 129, 0.4);
        }
        
        .action-btn-primary:hover {
            box-shadow: 0 15px 40px rgba(16, 185, 129, 0.5);
        }
        
        /* Logout button */
        .btn-logout {
            background: rgba(239, 68, 68, 0.2);
            border: 1px solid rgba(239, 68, 68, 0.5);
            color: #fca5a5;
            padding: 10px 20px;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-family: 'Be Vietnam Pro', sans-serif;
            font-weight: 500;
        }
        
        .btn-logout:hover {
            background: rgba(239, 68, 68, 0.3);
            transform: translateY(-2px);
        }
        
        /* Animation */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .dashboard-card {
            animation: fadeInUp 0.6s ease forwards;
        }
        
        .dashboard-card:nth-child(1) { animation-delay: 0.1s; }
        .dashboard-card:nth-child(2) { animation-delay: 0.2s; }
        .dashboard-card:nth-child(3) { animation-delay: 0.3s; }
        .dashboard-card:nth-child(4) { animation-delay: 0.4s; }
        
        /* Responsive */
        @media (max-width: 768px) {
            .nav-menu {
                display: none;
            }
            
            .dashboard-grid {
                grid-template-columns: 1fr;
            }
            
            .quick-actions {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar">
        <div class="nav-container">
            <div class="logo">
                <i class="fas fa-rocket"></i>
                <span>Leave System</span>
            </div>
            
            <div class="nav-menu">
                <a href="${pageContext.request.contextPath}/home"><i class="fas fa-home"></i> Trang chủ</a>
                <a href="${pageContext.request.contextPath}/request/create"><i class="fas fa-plus-circle"></i> Tạo đơn</a>
                <a href="${pageContext.request.contextPath}/request/list"><i class="fas fa-list"></i> Đơn của tôi</a>
                <a href="${pageContext.request.contextPath}/request/pending"><i class="fas fa-tasks"></i> Duyệt đơn</a>
            </div>
            
            <div class="user-menu">
                <div class="user-info">
                    <div class="user-name"><%= user.getFullName() %></div>
                    <div class="user-role"><%= user.getDivisionName() != null ? user.getDivisionName() : "Nhân viên" %></div>
                </div>
                <div class="user-avatar">
                    <%= user.getFullName().substring(0, 1).toUpperCase() %>
                </div>
                <button class="btn-logout" onclick="logout()">
                    <i class="fas fa-sign-out-alt"></i> Đăng xuất
                </button>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="main-container">
        <!-- Welcome Section -->
        <div class="welcome-section">
            <h1>👋 Xin chào, <%= user.getFullName() %>!</h1>
            <p>Chào mừng bạn đến với Hệ thống quản lý nghỉ phép. Hãy bắt đầu quản lý đơn nghỉ phép của bạn ngay hôm nay.</p>
        </div>

        <!-- Dashboard Cards -->
        <div class="dashboard-grid">
            <div class="dashboard-card">
                <div class="card-icon">
                    <i class="fas fa-calendar-check"></i>
                </div>
                <div class="card-title">Đơn đã duyệt</div>
                <div class="card-value">0</div>
                <div class="card-description">Tổng số đơn nghỉ phép đã được duyệt</div>
            </div>

            <div class="dashboard-card">
                <div class="card-icon">
                    <i class="fas fa-clock"></i>
                </div>
                <div class="card-title">Đang chờ</div>
                <div class="card-value">0</div>
                <div class="card-description">Đơn đang chờ xét duyệt</div>
            </div>

            <div class="dashboard-card">
                <div class="card-icon">
                    <i class="fas fa-umbrella-beach"></i>
                </div>
                <div class="card-title">Ngày phép còn lại</div>
                <div class="card-value">12</div>
                <div class="card-description">Số ngày phép bạn có thể sử dụng</div>
            </div>

            <div class="dashboard-card">
                <div class="card-icon">
                    <i class="fas fa-chart-line"></i>
                </div>
                <div class="card-title">Đã sử dụng</div>
                <div class="card-value">0</div>
                <div class="card-description">Số ngày phép đã sử dụng năm nay</div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="quick-actions">
            <a href="${pageContext.request.contextPath}/request/pending" class="action-btn action-btn-primary">
                <i class="fas fa-tasks"></i>
                Duyệt đơn nghỉ phép
            </a>
            
            <a href="${pageContext.request.contextPath}/request/create" class="action-btn">
                <i class="fas fa-plus-circle"></i>
                Tạo đơn nghỉ phép
            </a>
            
            <a href="${pageContext.request.contextPath}/request/list" class="action-btn">
                <i class="fas fa-list-ul"></i>
                Xem đơn của tôi
            </a>
            
            <a href="${pageContext.request.contextPath}/profile" class="action-btn">
                <i class="fas fa-user-circle"></i>
                Thông tin cá nhân
            </a>
            
            <a href="${pageContext.request.contextPath}/agenda" class="action-btn">
                <i class="fas fa-calendar-alt"></i>
                Lịch nghỉ phép
            </a>
        </div>
    </div>

    <script>
        function logout() {
            if (confirm('Bạn có chắc chắn muốn đăng xuất?')) {
                window.location.href = '${pageContext.request.contextPath}/logout';
            }
        }
        
        // Smooth scroll
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                document.querySelector(this.getAttribute('href')).scrollIntoView({
                    behavior: 'smooth'
                });
            });
        });
    </script>
</body>
</html>
