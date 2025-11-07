<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.Employee" %>
<%@ page import="com.company.lms.service.EmployeeService" %>
<%
Employee user = (Employee) session.getAttribute("user");
if (user == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}

EmployeeService employeeService = new EmployeeService();
int roleLevel = employeeService.getLowestRoleLevel(user.getEmployeeID());
boolean isCEO = (roleLevel == 1);
boolean isSeniorManagement = (roleLevel == 1 || roleLevel == 2);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang chủ - Leave Management System</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            background: #ffffff;
            color: #1d1d1f;
            -webkit-font-smoothing: antialiased;
        }
        .navbar {
            background: #ffffff;
            padding: 16px 0;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
            border-bottom: 1px solid rgba(0, 0, 0, 0.1);
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
            gap: 12px;
            font-size: 20px;
            font-weight: 600;
            color: #000000;
            letter-spacing: -0.02em;
        }
        .user-menu { display: flex; align-items: center; gap: 15px; }
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: #000000;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 16px;
            color: #fff;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            overflow: hidden;
        }
        .user-avatar img { width: 100%; height: 100%; object-fit: cover; }
        .user-avatar:hover { transform: scale(1.05); }
        .user-info { display: flex; flex-direction: column; }
        .user-name { font-weight: 500; font-size: 14px; }
        .user-role { font-size: 12px; color: #6e6e73; }
        .main-container { max-width: 1400px; margin: 0 auto; padding: 40px 30px; }
        .welcome-section {
            background: #f5f5f7;
            border-radius: 18px;
            padding: 40px;
            margin-bottom: 40px;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }
        .welcome-section h1 {
            font-size: 32px;
            margin-bottom: 12px;
            font-weight: 600;
            letter-spacing: -0.02em;
        }
        .welcome-section p { font-size: 16px; color: #6e6e73; }
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        .dashboard-card {
            background: #ffffff;
            border-radius: 18px;
            padding: 28px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            cursor: pointer;
        }
        .dashboard-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
        }
        .card-icon {
            width: 56px;
            height: 56px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            margin-bottom: 20px;
            background: #000000;
        }
        .card-title { font-size: 17px; font-weight: 500; margin-bottom: 8px; }
        .card-description { color: #6e6e73; font-size: 13px; line-height: 1.5; }
        .card-value {
            font-size: 32px;
            font-weight: 600;
            margin: 12px 0;
            letter-spacing: -0.02em;
        }
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 16px;
        }
        .action-btn {
            background: #000000;
            border: none;
            border-radius: 980px;
            padding: 14px 24px;
            color: #fff;
            font-size: 14px;
            font-weight: 500;
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            letter-spacing: -0.01em;
        }
        .action-btn:hover {
            transform: scale(1.02);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        .action-btn-primary {
            background: #34c759;
        }
        .action-btn-warning {
            background: #ff9500;
        }
        .btn-logout {
            background: #f5f5f7;
            border: 1px solid rgba(0, 0, 0, 0.1);
            color: #1d1d1f;
            padding: 8px 16px;
            border-radius: 980px;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            font-weight: 500;
            font-size: 13px;
        }
        .btn-logout:hover {
            background: #e8e8ed;
        }
        @media (max-width: 768px) {
            .dashboard-grid, .quick-actions { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="logo">
                🚀 Leave System
            </div>
            <div class="user-menu">
                <div class="user-info">
                    <div class="user-name"><%= user.getFullName() %></div>
                    <div class="user-role"><%= user.getDivisionName() != null ? user.getDivisionName() : "Nhân viên" %></div>
                </div>
                <div class="user-avatar">
                    <% if (user.getAvatarPath() != null && !user.getAvatarPath().isEmpty()) { %>
                        <img src="${pageContext.request.contextPath}/images/uploads/<%= user.getAvatarPath() %>" alt="Avatar">
                    <% } else { %>
                        <%= user.getFullName().substring(0, 1).toUpperCase() %>
                    <% } %>
                </div>
                <button class="btn-logout" onclick="logout()">
                    Đăng xuất
                </button>
            </div>
        </div>
    </nav>

    <div class="main-container">
        <div class="welcome-section">
            <h1>👋 Xin chào, <%= user.getFullName() %>!</h1>
            <p>Chúc bạn một ngày tốt lành!</p>
        </div>

        <div class="dashboard-grid">
            <% if (isCEO) { %>
            <div class="dashboard-card">
        <div class="card-icon">✓</div>
        <div class="card-title">Đơn đã duyệt</div>
        <div class="card-value"><%= request.getAttribute("approvedCount") != null ? request.getAttribute("approvedCount") : 0 %></div>
        <div class="card-description">Tổng số đơn đã được duyệt trong hệ thống</div>
    </div>
    
    <!-- ✅ THÊM DASHBOARD BUTTON -->
    <a href="${pageContext.request.contextPath}/dashboard" style="text-decoration: none;">
        <div class="dashboard-card" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff;">
            <div class="card-icon" style="background: rgba(255,255,255,0.2);">📊</div>
            <div class="card-title">Dashboard</div>
            <div class="card-value">Xem ngay</div>
            <div class="card-description" style="color: rgba(255,255,255,0.8);">Thống kê chi tiết toàn hệ thống</div>
        </div>
    </a>
    
    <div class="dashboard-card">
        <div class="card-icon">📊</div>
        <div class="card-title">Audit Logs</div>
        <div class="card-value"><%= request.getAttribute("remainingDays") != null ? request.getAttribute("remainingDays") : 0 %></div>
        <div class="card-description">Tổng số bản ghi hệ thống</div>
    </div>
    <div class="dashboard-card">
        <div class="card-icon">📄</div>
        <div class="card-title">Hôm nay</div>
        <div class="card-value"><%= request.getAttribute("usedDays") != null ? request.getAttribute("usedDays") : 0 %></div>
        <div class="card-description">Số bản ghi audit hôm nay</div>
    </div>
            <% } else { %>
            <div class="dashboard-card">
                <div class="card-icon">✓</div>
                <div class="card-title">Đơn đã duyệt</div>
                <div class="card-value"><%= request.getAttribute("approvedCount") != null ? request.getAttribute("approvedCount") : 0 %></div>
                <div class="card-description">Tổng số đơn nghỉ phép đã được duyệt</div>
            </div>
            <div class="dashboard-card">
                <div class="card-icon">⏱</div>
                <div class="card-title">Đang chờ</div>
                <div class="card-value"><%= request.getAttribute("pendingCount") != null ? request.getAttribute("pendingCount") : 0 %></div>
                <div class="card-description">Đơn đang chờ xét duyệt</div>
            </div>
            <div class="dashboard-card">
                <div class="card-icon">🖐</div>
                <div class="card-title">Ngày phép còn lại</div>
                <div class="card-value"><%= request.getAttribute("remainingDays") != null ? request.getAttribute("remainingDays") : 0 %></div>
                <div class="card-description">Số ngày phép bạn có thể sử dụng</div>
            </div>
            <div class="dashboard-card">
                <div class="card-icon">📊</div>
                <div class="card-title">Đã sử dụng</div>
                <div class="card-value"><%= request.getAttribute("usedDays") != null ? request.getAttribute("usedDays") : 0 %></div>
                <div class="card-description">Số ngày phép đã sử dụng năm nay</div>
            </div>
            <% } %>
        </div>

        <div class="quick-actions">
            <% if (isSeniorManagement) { %>
            <a href="${pageContext.request.contextPath}/request/pending" class="action-btn action-btn-primary">
                Duyệt đơn nghỉ phép
            </a>
            <% } %>
            
            
            <% if (isCEO) { %>
            <a href="${pageContext.request.contextPath}/audit/logs" class="action-btn action-btn-warning">
                📊 Xem Audit Logs
            </a>
            <% } %>
            
            <% if (isSeniorManagement) { %>
            <a href="${pageContext.request.contextPath}/request/employee-requests" class="action-btn">
                👥 Xem đơn nhân viên
            </a>
            <% } %>
            
            <% if (!isCEO) { %>
            <a href="${pageContext.request.contextPath}/request/create" class="action-btn">
                Tạo đơn nghỉ phép
            </a>
            <a href="${pageContext.request.contextPath}/request/list" class="action-btn">
                Xem đơn của tôi
            </a>
            <% } %>
            
            <a href="${pageContext.request.contextPath}/profile" class="action-btn">
                Thông tin cá nhân
            </a>
            
            <% if (isCEO) { %>
            <a href="${pageContext.request.contextPath}/agenda" class="action-btn">
                Lịch nghỉ phép
            </a>
            <% } %>
        </div>
    </div>

    <script>
        function logout() {
            if (confirm('Bạn có chắc chắn muốn đăng xuất?')) {
                window.location.href = '${pageContext.request.contextPath}/logout';
            }
        }
    </script>
</body>
</html>