<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.*" %>
<%@ page import="com.company.lms.controller.DashboardServlet.DivisionStat" %>
<%@ page import="java.util.*" %>
<%
    Employee user = (Employee) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    Map<String, Integer> monthlyStats = (Map<String, Integer>) request.getAttribute("monthlyStats");
    List<DivisionStat> topDivisions = (List<DivisionStat>) request.getAttribute("topDivisions");
    Map<String, Integer> statusStats = (Map<String, Integer>) request.getAttribute("statusStats");
    Map<String, Object> trends = (Map<String, Object>) request.getAttribute("trends");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Thống kê</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            background: #ffffff;
            color: #1d1d1f;
            -webkit-font-smoothing: antialiased;
            min-height: 100vh;
        }
        .navbar {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: saturate(180%) blur(20px);
            padding: 16px 0;
            box-shadow: 0 1px 0 rgba(0, 0, 0, 0.1);
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        .nav-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .logo { 
            font-size: 20px; 
            font-weight: 600; 
            color: #000; 
            text-decoration: none;
            letter-spacing: -0.022em;
        }
        .main-container { 
            max-width: 1200px; 
            margin: 0 auto; 
            padding: 40px 30px 80px;
        }
        .page-header {
            margin-bottom: 40px;
        }
        h1 { 
            font-size: 34px; 
            font-weight: 700; 
            letter-spacing: -0.022em;
            margin-bottom: 12px;
        }
        .subtitle {
            font-size: 17px;
            color: #6e6e73;
            font-weight: 400;
        }
        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 9px 20px;
            background: #f5f5f7;
            border: none;
            border-radius: 980px;
            color: #1d1d1f;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.4s cubic-bezier(0.28, 0.11, 0.32, 1);
            cursor: pointer;
        }
        .btn-back:hover { 
            background: #e8e8ed;
            transform: scale(1.02);
        }
        
        /* Trend Card */
        .trend-card {
            background: #000000;
            border-radius: 18px;
            padding: 36px;
            margin-bottom: 30px;
            color: #ffffff;
            box-shadow: 0 4px 24px rgba(0, 0, 0, 0.15);
            transition: all 0.4s cubic-bezier(0.28, 0.11, 0.32, 1);
            position: relative;
            overflow: hidden;
        }
        .trend-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(255,255,255,0) 0%, rgba(255,255,255,0.05) 100%);
            opacity: 0;
            transition: opacity 0.4s cubic-bezier(0.28, 0.11, 0.32, 1);
        }
        .trend-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.2);
        }
        .trend-card:hover::before {
            opacity: 1;
        }
        .trend-title { 
            font-size: 15px; 
            opacity: 0.7; 
            margin-bottom: 12px;
            font-weight: 500;
        }
        .trend-value { 
            font-size: 56px; 
            font-weight: 700; 
            margin-bottom: 16px;
            letter-spacing: -0.022em;
        }
        .trend-change {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(255,255,255,0.15);
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            backdrop-filter: blur(10px);
            transition: all 0.4s cubic-bezier(0.28, 0.11, 0.32, 1);
        }
        .trend-change:hover {
            background: rgba(255,255,255,0.25);
            transform: scale(1.05);
        }
        
        /* Charts Grid */
        .charts-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 24px;
            margin-bottom: 30px;
        }
        .chart-card {
            background: #ffffff;
            border-radius: 18px;
            padding: 30px;
            border: 1px solid rgba(0, 0, 0, 0.06);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            transition: all 0.4s cubic-bezier(0.28, 0.11, 0.32, 1);
            position: relative;
            overflow: hidden;
        }
        .chart-card::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: #000000;
            transform: scaleX(0);
            transform-origin: left;
            transition: transform 0.4s cubic-bezier(0.28, 0.11, 0.32, 1);
        }
        .chart-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.08);
        }
        .chart-card:hover::after {
            transform: scaleX(1);
        }
        .chart-header {
            margin-bottom: 24px;
        }
        .chart-title { 
            font-size: 20px; 
            font-weight: 600;
            letter-spacing: -0.022em;
            margin-bottom: 4px;
        }
        .chart-subtitle { 
            font-size: 13px; 
            color: #6e6e73;
            font-weight: 400;
        }
        .chart-canvas {
            position: relative;
            height: 280px;
        }
        
        /* Top Divisions */
        .division-list { 
            display: flex; 
            flex-direction: column; 
            gap: 12px;
        }
        .division-item {
            background: #f5f5f7;
            border-radius: 14px;
            padding: 18px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: all 0.4s cubic-bezier(0.28, 0.11, 0.32, 1);
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }
        .division-item::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 4px;
            background: #000000;
            transform: scaleY(0);
            transition: transform 0.4s cubic-bezier(0.28, 0.11, 0.32, 1);
        }
        .division-item:hover {
            background: #e8e8ed;
            transform: translateX(8px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
        }
        .division-item:hover::before {
            transform: scaleY(1);
        }
        .division-info { flex: 1; }
        .division-name { 
            font-weight: 600; 
            font-size: 15px; 
            margin-bottom: 4px;
            letter-spacing: -0.022em;
        }
        .division-stats { 
            font-size: 13px; 
            color: #6e6e73;
            font-weight: 400;
        }
        .division-badge {
            background: #000000;
            color: #ffffff;
            padding: 8px 18px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 14px;
            letter-spacing: -0.022em;
            transition: all 0.4s cubic-bezier(0.28, 0.11, 0.32, 1);
        }
        .division-item:hover .division-badge {
            transform: scale(1.1);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #6e6e73;
        }
        .empty-state-icon {
            font-size: 48px;
            margin-bottom: 16px;
            opacity: 0.4;
        }
        
        @media (max-width: 968px) {
            .charts-grid { 
                grid-template-columns: 1fr;
            }
        }
        
        @media (max-width: 734px) {
            .main-container {
                padding: 24px 20px 60px;
            }
            h1 {
                font-size: 28px;
            }
            .trend-value {
                font-size: 44px;
            }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/home" class="logo">🚀 Leave System</a>
            <a href="${pageContext.request.contextPath}/home" class="btn-back">← Quay lại</a>
        </div>
    </nav>

    <div class="main-container">
        <div class="page-header">
            <h1>Dashboard</h1>
            <p class="subtitle">Thống kê tổng quan hệ thống</p>
        </div>

        <!-- Trend Card -->
        <% if (trends != null) { %>
        <div class="trend-card">
            <div class="trend-title">Tổng đơn tháng này</div>
            <div class="trend-value"><%= trends.get("thisMonth") %></div>
            <div class="trend-change">
                <%= (Boolean)trends.get("isIncrease") ? "↑" : "↓" %>
                <%= String.format("%.1f", Math.abs((Double)trends.get("change"))) %>%
                so với tháng trước
            </div>
        </div>
        <% } %>

        <div class="charts-grid">
            <!-- Monthly Chart -->
            <div class="chart-card">
                <div class="chart-header">
                    <div class="chart-title">Đơn nghỉ phép theo tháng</div>
                    <div class="chart-subtitle">12 tháng gần nhất</div>
                </div>
                <div class="chart-canvas">
                    <canvas id="monthlyChart"></canvas>
                </div>
            </div>

            <!-- Status Pie Chart -->
            <div class="chart-card">
                <div class="chart-header">
                    <div class="chart-title">Trạng thái đơn</div>
                    <div class="chart-subtitle">Năm <%= java.time.Year.now().getValue() %></div>
                </div>
                <div class="chart-canvas">
                    <canvas id="statusChart"></canvas>
                </div>
            </div>
        </div>

        <!-- Top Divisions -->
        <div class="chart-card">
            <div class="chart-header">
                <div class="chart-title">Top 5 Phòng Ban</div>
                <div class="chart-subtitle">Nghỉ phép nhiều nhất năm nay</div>
            </div>
            <div class="division-list">
                <% if (topDivisions != null && !topDivisions.isEmpty()) {
                    int rank = 1;
                    for (DivisionStat div : topDivisions) { %>
                    <div class="division-item">
                        <div class="division-info">
                            <div class="division-name">
                                <% if (rank == 1) { %>1<% } else if (rank == 2) { %>2<% } else if (rank == 3) { %>3<% } else { %>#<%= rank %><% } %>
                                <%= div.name %>
                            </div>
                            <div class="division-stats">
                                <%= div.requests %> đơn · <%= String.format("%.1f", div.days) %> ngày
                            </div>
                        </div>
                        <div class="division-badge"><%= String.format("%.0f", div.days) %></div>
                    </div>
                <% rank++; }} else { %>
                    <div class="empty-state">
                        <div class="empty-state-icon">📊</div>
                        <p>Chưa có dữ liệu thống kê</p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        Chart.defaults.font.family = "-apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif";
        Chart.defaults.color = '#1d1d1f';

        // Monthly Chart
        const monthlyCtx = document.getElementById('monthlyChart').getContext('2d');
        new Chart(monthlyCtx, {
            type: 'bar',
            data: {
                labels: <%= monthlyStats != null ? "['" + String.join("','", monthlyStats.keySet()) + "']" : "[]" %>,
                datasets: [{
                    label: 'Số đơn',
                    data: <%= monthlyStats != null ? new java.util.ArrayList<>(monthlyStats.values()) : "[]" %>,
                    backgroundColor: 'rgba(0, 0, 0, 0.9)',
                    borderRadius: 8,
                    barThickness: 32
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.9)',
                        padding: 12,
                        titleFont: { size: 13, weight: '600' },
                        bodyFont: { size: 13 },
                        cornerRadius: 8
                    }
                },
                scales: {
                    y: { 
                        beginAtZero: true,
                        grid: { color: 'rgba(0, 0, 0, 0.04)', drawBorder: false },
                        ticks: { font: { size: 12 } }
                    },
                    x: {
                        grid: { display: false, drawBorder: false },
                        ticks: { font: { size: 12 } }
                    }
                },
                animation: {
                    duration: 1000,
                    easing: 'easeInOutQuart'
                }
            }
        });

        // Status Pie Chart
        const statusCtx = document.getElementById('statusChart').getContext('2d');
        new Chart(statusCtx, {
            type: 'doughnut',
            data: {
                labels: ['Đã duyệt', 'Từ chối', 'Đang chờ'],
                datasets: [{
                    data: [
                        <%= statusStats != null ? statusStats.getOrDefault("Approved", 0) : 0 %>,
                        <%= statusStats != null ? statusStats.getOrDefault("Rejected", 0) : 0 %>,
                        <%= statusStats != null ? statusStats.getOrDefault("InProgress", 0) : 0 %>
                    ],
                    backgroundColor: [
                        'rgba(52, 199, 89, 0.9)',
                        'rgba(255, 59, 48, 0.9)',
                        'rgba(255, 149, 0, 0.9)'
                    ],
                    borderWidth: 0,
                    hoverOffset: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 20,
                            font: { size: 13, weight: '500' },
                            usePointStyle: true,
                            pointStyle: 'circle'
                        }
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.9)',
                        padding: 12,
                        cornerRadius: 8
                    }
                },
                animation: {
                    animateRotate: true,
                    animateScale: true,
                    duration: 1000,
                    easing: 'easeInOutQuart'
                }
            }
        });
    </script>
</body>
</html>