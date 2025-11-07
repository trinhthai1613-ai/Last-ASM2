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
    <title>Dashboard - Thống kê</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
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
        .logo { font-size: 20px; font-weight: 600; color: #000; text-decoration: none; }
        .main-container { max-width: 1400px; margin: 40px auto; padding: 0 30px; }
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        h1 { font-size: 28px; font-weight: 600; letter-spacing: -0.02em; }
        .btn-back {
            padding: 8px 18px;
            background: #f5f5f7;
            border: 1px solid rgba(0,0,0,0.1);
            border-radius: 980px;
            color: #1d1d1f;
            text-decoration: none;
            font-size: 14px;
            transition: all 0.3s;
        }
        .btn-back:hover { background: #e8e8ed; }
        
        /* Trend Card */
        .trend-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 18px;
            padding: 30px;
            margin-bottom: 30px;
            color: #fff;
            box-shadow: 0 4px 24px rgba(102, 126, 234, 0.3);
        }
        .trend-title { font-size: 15px; opacity: 0.9; margin-bottom: 10px; }
        .trend-value { font-size: 48px; font-weight: 700; margin-bottom: 10px; }
        .trend-change {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background: rgba(255,255,255,0.2);
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
        }
        .trend-change.up { background: rgba(52,199,89,0.2); }
        .trend-change.down { background: rgba(255,59,48,0.2); }
        
        /* Charts Grid */
        .charts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 24px;
            margin-bottom: 30px;
        }
        .chart-card {
            background: #ffffff;
            border-radius: 18px;
            padding: 30px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            box-shadow: 0 2px 16px rgba(0, 0, 0, 0.08);
        }
        .chart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .chart-title { font-size: 20px; font-weight: 600; }
        .chart-subtitle { font-size: 13px; color: #6e6e73; margin-top: 5px; }
        
        /* Top Divisions */
        .division-list { display: flex; flex-direction: column; gap: 16px; }
        .division-item {
            background: #f5f5f7;
            border-radius: 12px;
            padding: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: all 0.3s;
        }
        .division-item:hover {
            background: #e8e8ed;
            transform: translateX(4px);
        }
        .division-info { flex: 1; }
        .division-name { font-weight: 600; font-size: 15px; margin-bottom: 4px; }
        .division-stats { font-size: 13px; color: #6e6e73; }
        .division-badge {
            background: #000;
            color: #fff;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 14px;
        }
        
        @media (max-width: 768px) {
            .charts-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/home" class="logo">🚀 Leave System</a>
        </div>
    </nav>

    <div class="main-container">
        <div class="page-header">
            <h1>📊 Dashboard Thống Kê</h1>
            <a href="${pageContext.request.contextPath}/home" class="btn-back">← Quay lại</a>
        </div>

        <!-- Trend Card -->
        <% if (trends != null) { %>
        <div class="trend-card">
            <div class="trend-title">📈 Tổng đơn tháng này</div>
            <div class="trend-value"><%= trends.get("thisMonth") %></div>
            <div class="trend-change <%= (Boolean)trends.get("isIncrease") ? "up" : "down" %>">
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
                    <div>
                        <div class="chart-title">Đơn nghỉ phép theo tháng</div>
                        <div class="chart-subtitle">12 tháng gần nhất</div>
                    </div>
                </div>
                <canvas id="monthlyChart" height="300"></canvas>
            </div>

            <!-- Status Pie Chart -->
            <div class="chart-card">
                <div class="chart-header">
                    <div>
                        <div class="chart-title">Trạng thái đơn</div>
                        <div class="chart-subtitle">Năm <%= java.time.Year.now().getValue() %></div>
                    </div>
                </div>
                <canvas id="statusChart" height="300"></canvas>
            </div>
        </div>

        <!-- Top Divisions -->
        <div class="chart-card">
            <div class="chart-header">
                <div class="chart-title">🏆 Top 5 Phòng Ban Nghỉ Nhiều Nhất</div>
            </div>
            <div class="division-list">
                <% if (topDivisions != null && !topDivisions.isEmpty()) {
                    int rank = 1;
                    for (DivisionStat div : topDivisions) { %>
                    <div class="division-item">
                        <div class="division-info">
                            <div class="division-name">
                                <% if (rank == 1) { %>🥇<% } else if (rank == 2) { %>🥈<% } else if (rank == 3) { %>🥉<% } %>
                                <%= div.name %>
                            </div>
                            <div class="division-stats">
                                <%= div.requests %> đơn - <%= String.format("%.1f", div.days) %> ngày
                            </div>
                        </div>
                        <div class="division-badge"><%= String.format("%.0f", div.days) %> ngày</div>
                    </div>
                <% rank++; }} else { %>
                    <div style="text-align: center; padding: 40px; color: #6e6e73;">
                        Chưa có dữ liệu
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        // Monthly Chart
        const monthlyCtx = document.getElementById('monthlyChart').getContext('2d');
        new Chart(monthlyCtx, {
            type: 'bar',
            data: {
                labels: <%= monthlyStats != null ? "['" + String.join("','", monthlyStats.keySet()) + "']" : "[]" %>,
                datasets: [{
                    label: 'Số đơn',
                    data: <%= monthlyStats != null ? new java.util.ArrayList<>(monthlyStats.values()) : "[]" %>,
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    borderRadius: 8,
                    barThickness: 40
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: { 
                        beginAtZero: true,
                        grid: { color: 'rgba(0,0,0,0.05)' }
                    },
                    x: {
                        grid: { display: false }
                    }
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
                        'rgba(52, 199, 89, 0.8)',
                        'rgba(255, 59, 48, 0.8)',
                        'rgba(255, 149, 0, 0.8)'
                    ],
                    borderWidth: 0
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
                            font: { size: 13, weight: '500' }
                        }
                    }
                }
            }
        });
    </script>
</body>
</html>