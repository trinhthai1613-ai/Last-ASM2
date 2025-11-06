<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Employee user = (Employee) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<AuditLog> logs = (List<AuditLog>) request.getAttribute("logs");
    List<Employee> employees = (List<Employee>) request.getAttribute("employees");
    SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Audit Logs</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            background: #fff;
            color: #1d1d1f;
        }
        .navbar {
            background: #fff;
            padding: 16px 0;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
            border-bottom: 1px solid rgba(0,0,0,0.1);
        }
        .nav-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 30px;
        }
        .logo {
            font-size: 20px;
            font-weight: 600;
            color: #000;
            text-decoration: none;
        }
        .main-container { max-width: 1400px; margin: 40px auto; padding: 0 30px; }
        .page-header { display: flex; justify-content: space-between; margin-bottom: 30px; }
        h1 { font-size: 28px; font-weight: 600; }
        .btn-back {
            padding: 8px 18px;
            background: #f5f5f7;
            border: 1px solid rgba(0,0,0,0.1);
            border-radius: 980px;
            color: #1d1d1f;
            text-decoration: none;
            font-size: 14px;
        }
        .filter-section {
            background: #f5f5f7;
            border-radius: 18px;
            padding: 24px;
            margin-bottom: 24px;
        }
        .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 16px;
        }
        .form-group { display: flex; flex-direction: column; }
        label { margin-bottom: 8px; font-size: 14px; font-weight: 500; }
        .form-control {
            background: #fff;
            border: 1px solid rgba(0,0,0,0.1);
            border-radius: 12px;
            padding: 10px 14px;
            font-size: 14px;
        }
        .btn-filter {
            padding: 10px 24px;
            background: #000;
            color: #fff;
            border: none;
            border-radius: 12px;
            font-size: 14px;
            cursor: pointer;
        }
        .table-card {
            background: #fff;
            border-radius: 18px;
            padding: 30px;
            border: 1px solid rgba(0,0,0,0.1);
            box-shadow: 0 2px 16px rgba(0,0,0,0.08);
        }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid rgba(0,0,0,0.1); }
        th { background: #f5f5f7; font-weight: 600; font-size: 12px; }
        .action-badge {
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 600;
        }
        .action-insert { background: rgba(52,199,89,0.15); color: #34c759; }
        .action-update { background: rgba(255,149,0,0.15); color: #ff9500; }
        .action-delete { background: rgba(255,59,48,0.15); color: #ff3b30; }
        .empty-state { text-align: center; padding: 60px; color: #6e6e73; }
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
            <h1>📊 Audit Logs</h1>
            <a href="${pageContext.request.contextPath}/home" class="btn-back">← Quay lại</a>
        </div>

        <div class="filter-section">
            <form method="get">
                <div class="filter-grid">
                    <div class="form-group">
                        <label>📋 Bảng</label>
                        <select name="tableName" class="form-control">
                            <option value="">Tất cả</option>
                            <option value="LeaveRequests">Đơn nghỉ phép</option>
                            <option value="Employees">Nhân viên</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>👤 Nhân viên</label>
                        <select name="employeeId" class="form-control">
                            <option value="">Tất cả</option>
                            <% if (employees != null) {
                                for (Employee emp : employees) { %>
                                <option value="<%= emp.getEmployeeID() %>">
                                    <%= emp.getEmployeeCode() %> - <%= emp.getFullName() %>
                                </option>
                            <% }} %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>📅 Từ ngày</label>
                        <input type="date" name="fromDate" class="form-control">
                    </div>
                    <div class="form-group">
                        <label>📅 Đến ngày</label>
                        <input type="date" name="toDate" class="form-control">
                    </div>
                </div>
                <button type="submit" class="btn-filter">🔍 Lọc</button>
            </form>
        </div>
        
        <div class="table-card">
            <% if (logs != null && !logs.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>Thời gian</th>
                            <th>Bảng</th>
                            <th>Hành động</th>
                            <th>Record ID</th>
                            <th>Nhân viên</th>
                            <th>Giá trị cũ</th>
                            <th>Giá trị mới</th>
                            <th>Ghi chú</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (AuditLog log : logs) { 
                            String actionClass = "action-insert";
                            if ("UPDATE".equals(log.getAction())) actionClass = "action-update";
                            else if ("DELETE".equals(log.getAction())) actionClass = "action-delete";
                        %>
                            <tr>
                                <td><%= dateTimeFormatter.format(log.getCreatedAt()) %></td>
                                <td><%= log.getTableName() %></td>
                                <td><span class="action-badge <%= actionClass %>"><%= log.getActionDisplay() %></span></td>
                                <td>#<%= log.getRecordID() %></td>
                                <td>
                                    <% if (log.getEmployeeName() != null) { %>
                                        <%= log.getEmployeeCode() %> - <%= log.getEmployeeName() %>
                                    <% } else { %>
                                        N/A
                                    <% } %>
                                </td>
                                <td><%= log.getOldValue() != null ? log.getOldValue() : "-" %></td>
                                <td><%= log.getNewValue() != null ? log.getNewValue() : "-" %></td>
                                <td><%= log.getNote() != null ? log.getNote() : "Trống" %></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <div class="empty-state">
                    <div style="font-size: 64px;">📭</div>
                    <h2>Không có log nào</h2>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>