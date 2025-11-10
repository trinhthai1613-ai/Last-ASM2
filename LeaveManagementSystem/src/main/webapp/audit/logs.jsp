<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="com.company.lms.model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%!
    String analyzeChange(String oldValue, String newValue, String action) {
        if (action.equals("APPROVE") || action.equals("REJECT")) {
            return "Thay đổi quyết định";
        }
        if (oldValue == null || newValue == null) {
            return "Cập nhật";
        }
        if (oldValue.contains("StartDate:") || oldValue.contains("EndDate:")) {
            boolean dateChanged = false;
            String[] oldParts = oldValue.split(",");
            String[] newParts = newValue.split(",");
            for (int i = 0; i < oldParts.length && i < newParts.length; i++) {
                if ((oldParts[i].contains("StartDate:") || oldParts[i].contains("EndDate:")) 
                    && !oldParts[i].equals(newParts[i])) {
                    dateChanged = true;
                    break;
                }
            }
            if (dateChanged) return "Điều chỉnh thời gian";
        }
        if (oldValue.contains("Reason:") && newValue.contains("Reason:")) {
            String oldReason = "";
            String newReason = "";
            if (oldValue.contains("Reason:")) {
                oldReason = oldValue.substring(oldValue.indexOf("Reason:") + 7).trim();
            }
            if (newValue.contains("Reason:")) {
                newReason = newValue.substring(newValue.indexOf("Reason:") + 7).trim();
            }
            if (!oldReason.equals(newReason)) {
                return "Điều chỉnh lý do";
            }
        }
        return "Cập nhật thông tin";
    }
%>
<%
    Employee user = (Employee) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<AuditLog> logs = (List<AuditLog>) request.getAttribute("logs");
    List<Division> divisions = (List<Division>) request.getAttribute("divisions");
    List<Employee> employees = (List<Employee>) request.getAttribute("employees");
    SimpleDateFormat dateFormatter = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat timeFormatter = new SimpleDateFormat("HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Activity Logs - Leave System</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap&subset=vietnamese" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', 'Noto Sans', Arial, sans-serif;
            background: #ffffff;
            color: #1d1d1f;
            min-height: 100vh;
            -webkit-font-smoothing: antialiased;
        }
        .navbar { background: #ffffff; padding: 16px 0; box-shadow: 0 1px 3px rgba(0,0,0,0.08); border-bottom: 1px solid rgba(0,0,0,0.1); }
        .nav-container { max-width: 1400px; margin: 0 auto; padding: 0 30px; display: flex; justify-content: space-between; align-items: center; }
        .logo { display: flex; align-items: center; gap: 12px; font-size: 20px; font-weight: 600; color: #000; text-decoration: none; letter-spacing: -0.02em; }
        .main-container { max-width: 1400px; margin: 40px auto; padding: 0 30px; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        h1 { font-size: 28px; font-weight: 600; letter-spacing: -0.02em; }
        .btn-back { padding: 8px 18px; background: #f5f5f7; border: 1px solid rgba(0,0,0,0.1); border-radius: 980px; color: #1d1d1f; text-decoration: none; transition: 0.3s; font-size: 14px; font-weight: 500; cursor: pointer; }
        .btn-back:hover { background: #e8e8ed; }
        .filter-section { background: #f5f5f7; border-radius: 18px; padding: 24px; margin-bottom: 24px; border: 1px solid rgba(0,0,0,0.1); }
        .filter-grid { display: flex; gap: 16px; align-items: flex-end; }
        .form-group { display: flex; flex-direction: column; min-width: 180px; flex: 1; }
        .form-group label { margin-bottom: 8px; color: #6e6e73; font-size: 13px; font-weight: 500; }
        .form-control { background: #fff; border: 1px solid rgba(0,0,0,0.1); border-radius: 12px; padding: 10px 14px; color: #1d1d1f; font-size: 14px; }
        .btn-filter { display: none; }
        .results-info { margin-bottom: 16px; color: #6e6e73; font-size: 14px; }
        .results-info strong { color: #1d1d1f; font-weight: 600; }
        .table-card { background: #fff; border-radius: 18px; padding: 30px; border: 1px solid rgba(0,0,0,0.1); box-shadow: 0 2px 16px rgba(0,0,0,0.08); }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 16px; text-align: left; border-bottom: 1px solid rgba(0,0,0,0.1); }
        th { background: #f5f5f7; color: #1d1d1f; font-weight: 600; font-size: 13px; text-transform: uppercase; }
        tbody tr:hover { background: #f5f5f7; }
        .status { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 500; }
        .status-approve { background: rgba(52,199,89,0.15); color: #34c759; }
        .status-reject { background: rgba(255,59,48,0.15); color: #ff3b30; }
        .status-update { background: rgba(0,122,255,0.15); color: #007aff; }
        .division-badge { display: inline-block; padding: 4px 12px; background: #f5f5f7; border-radius: 8px; font-size: 13px; font-weight: 500; color: #1d1d1f; }
        .employee-info { display: flex; flex-direction: column; gap: 2px; }
        .employee-name { font-weight: 600; color: #1d1d1f; font-size: 14px; }
        .employee-code { font-size: 13px; color: #86868b; }
        .change-type { font-size: 14px; color: #1d1d1f; }
        .note-text { font-size: 14px; color: #6e6e73; font-style: italic; }
        .empty-state { text-align: center; padding: 60px 20px; color: #6e6e73; }
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
            <h1>📊 Activity Logs</h1>
            <a href="${pageContext.request.contextPath}/home" class="btn-back">← Quay lại</a>
        </div>
        <% if (logs != null) { %>
        <div class="results-info">Tìm thấy <strong><%= logs.size() %></strong> bản ghi</div>
        <% } %>
        <div class="table-card">
            <% if (logs != null && !logs.isEmpty()) { %>
            <table>
                <thead>
                    <tr><th>Thời gian</th><th>Hành động</th><th>Phòng ban</th><th>Nhân viên</th><th>Thay đổi</th><th>Ghi chú</th></tr>
                </thead>
                <tbody>
                <% for (AuditLog log : logs) {
                    String changeType = analyzeChange(log.getOldValue(), log.getNewValue(), log.getAction());
                    String statusClass = "status-update";
                    if ("APPROVE".equals(log.getAction())) statusClass = "status-approve";
                    else if ("REJECT".equals(log.getAction())) statusClass = "status-reject";
                %>
                    <tr>
                        <td><%= dateFormatter.format(log.getCreatedAt()) %> <br><small><%= timeFormatter.format(log.getCreatedAt()) %></small></td>
                        <td><span class="status <%= statusClass %>"><%= log.getActionDisplay() %></span></td>
                        <td><span class="division-badge"><%= log.getDivisionName() != null ? log.getDivisionName() : "N/A" %></span></td>
                        <td><div class="employee-info"><span class="employee-name"><%= log.getEmployeeName() != null ? log.getEmployeeName() : "N/A" %></span><span class="employee-code"><%= log.getEmployeeCode() != null ? log.getEmployeeCode() : "" %></span></div></td>
                        <td><span class="change-type"><%= changeType %></span></td>
                        <td><span class="note-text"><%= log.getNote() != null && !log.getNote().isEmpty() && !log.getNote().equals("Trống") ? log.getNote() : "—" %></span></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
            <% } else { %>
            <div class="empty-state"><div>🔍</div><h2>Không có dữ liệu</h2><p>Thử điều chỉnh bộ lọc để xem kết quả</p></div>
            <% } %>
        </div>
    </div>
</body>
</html>
