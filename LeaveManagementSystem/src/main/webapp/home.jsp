<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Chủ - Leave Management System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
    <style>
        .dashboard-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .welcome-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }
        .stat-number {
            font-size: 2.5em;
            font-weight: bold;
            color: #667eea;
        }
        .stat-label {
            color: #666;
            margin-top: 10px;
        }
        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 30px;
        }
        .action-btn {
            display: block;
            padding: 20px;
            background: white;
            border: 2px solid #667eea;
            border-radius: 10px;
            text-align: center;
            text-decoration: none;
            color: #667eea;
            font-weight: 600;
            transition: all 0.3s;
        }
        .action-btn:hover {
            background: #667eea;
            color: white;
            transform: scale(1.05);
        }
        .action-btn.primary {
            background: #667eea;
            color: white;
        }
        .action-btn.primary:hover {
            background: #5568d3;
        }
        .action-btn.manager-only {
            border-color: #f59e0b;
            color: #f59e0b;
        }
        .action-btn.manager-only:hover {
            background: #f59e0b;
            color: white;
        }
        .permission-badge {
            display: inline-block;
            padding: 5px 15px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            font-size: 0.9em;
            margin-top: 10px;
        }
        .alert {
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/includes/header.jsp" />

    <div class="dashboard-container">
        <!-- Welcome Section -->
        <div class="welcome-section">
            <h1>Xin chào, ${user.fullName}!</h1>
            <p>Chào mừng bạn đến với Hệ thống Quản lý Nghỉ phép</p>
            
            <!-- Hiển thị Level/Role -->
            <c:choose>
                <c:when test="${employeeLevel == 1}">
                    <span class="permission-badge">👑 Cấp Quản Trị (Level 1 - CEO/Admin)</span>
                </c:when>
                <c:when test="${employeeLevel == 2}">
                    <span class="permission-badge">🎯 Quản Lý Cấp Cao (Level 2 - Manager)</span>
                </c:when>
                <c:when test="${employeeLevel == 3}">
                    <span class="permission-badge">📋 Trưởng Nhóm (Level 3 - Team Leader)</span>
                </c:when>
                <c:when test="${employeeLevel == 4}">
                    <span class="permission-badge">👤 Nhân Viên (Level 4 - Employee)</span>
                </c:when>
                <c:otherwise>
                    <span class="permission-badge">⚠️ Chưa phân quyền</span>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Alert Messages -->
        <c:if test="${not empty sessionScope.success}">
            <div class="alert alert-success">
                ${sessionScope.success}
            </div>
            <c:remove var="success" scope="session"/>
        </c:if>

        <c:if test="${not empty sessionScope.error}">
            <div class="alert alert-error">
                ${sessionScope.error}
            </div>
            <c:remove var="error" scope="session"/>
        </c:if>

        <!-- Statistics Grid -->
        <div class="stats-grid">
            <!-- Đơn đã duyệt -->
            <div class="stat-card">
                <div class="stat-number">${approvedCount}</div>
                <div class="stat-label">Đơn Đã Duyệt</div>
            </div>

            <!-- Đơn đang chờ -->
            <div class="stat-card">
                <div class="stat-number">${pendingCount}</div>
                <div class="stat-label">Đơn Đang Chờ</div>
            </div>

            <!-- Ngày phép còn lại -->
            <div class="stat-card">
                <div class="stat-number">${remainingDays}</div>
                <div class="stat-label">Ngày Phép Còn Lại</div>
            </div>

            <!-- Ngày phép đã sử dụng -->
            <div class="stat-card">
                <div class="stat-number">${usedDays}</div>
                <div class="stat-label">Ngày Phép Đã Dùng</div>
            </div>

            <!-- THÊM CARD NÀY CHO MANAGER (LEVEL 1-2) -->
            <c:if test="${canApprove}">
                <div class="stat-card" style="border: 2px solid #f59e0b;">
                    <div class="stat-number" style="color: #f59e0b;">${pendingApprovalCount}</div>
                    <div class="stat-label">🔔 Đơn Cần Duyệt</div>
                </div>
            </c:if>
        </div>

        <!-- Actions Grid -->
        <div class="actions-grid">
            <!-- Tạo đơn nghỉ phép - TẤT CẢ đều được -->
            <a href="${pageContext.request.contextPath}/request/create" class="action-btn primary">
                ➕ Tạo Đơn Nghỉ Phép
            </a>

            <!-- Xem đơn của tôi - TẤT CẢ đều được -->
            <a href="${pageContext.request.contextPath}/request/list" class="action-btn">
                📋 Xem Đơn Của Tôi
            </a>

            <!-- Xem hồ sơ - TẤT CẢ đều được -->
            <a href="${pageContext.request.contextPath}/profile" class="action-btn">
                👤 Hồ Sơ Cá Nhân
            </a>

            <!-- DUYỆT ĐơN - CHỈ LEVEL 1-2 -->
            <c:if test="${canApprove}">
                <a href="${pageContext.request.contextPath}/request/pending" class="action-btn manager-only">
                    ✅ Duyệt Đơn Nghỉ Phép
                </a>
            </c:if>

            <!-- XEM AGENDA - CHỈ LEVEL 1-2 -->
            <c:if test="${canViewAgenda}">
                <a href="${pageContext.request.contextPath}/agenda" class="action-btn manager-only">
                    📅 Xem Lịch Nghỉ Phép
                </a>
            </c:if>

            <!-- QUẢN LÝ NHÂN VIÊN - CHỈ LEVEL 1-2 -->
            <c:if test="${canManageEmployees}">
                <a href="${pageContext.request.contextPath}/employee/manage" class="action-btn manager-only">
                    👥 Quản Lý Nhân Viên
                </a>
            </c:if>

            <!-- XEM BÁO CÁO - CHỈ LEVEL 1-2 -->
            <c:if test="${canViewReports}">
                <a href="${pageContext.request.contextPath}/report/view" class="action-btn manager-only">
                    📊 Xem Báo Cáo
                </a>
            </c:if>
        </div>

        <!-- Thông tin phân quyền (debug - có thể xóa sau) -->
        <div style="margin-top: 30px; padding: 15px; background: #f8f9fa; border-radius: 5px; font-size: 0.9em;">
            <strong>🔒 Thông tin phân quyền:</strong><br>
            Level: ${employeeLevel} |
            Duyệt đơn: ${canApprove ? "✅" : "❌"} |
            Xem agenda: ${canViewAgenda ? "✅" : "❌"} |
            Quản lý NV: ${canManageEmployees ? "✅" : "❌"} |
            Xem báo cáo: ${canViewReports ? "✅" : "❌"}
        </div>
    </div>

    <jsp:include page="/WEB-INF/includes/footer.jsp" />
</body>
</html>