<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    Employee user = (Employee) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<LeaveRequest> requests = (List<LeaveRequest>) request.getAttribute("requests");
    List<Division> divisions = (List<Division>) request.getAttribute("divisions");
    List<LeaveType> leaveTypes = (List<LeaveType>) request.getAttribute("leaveTypes");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    String selectedDivisionId = (String) request.getAttribute("selectedDivisionId");
    String selectedLeaveTypeId = (String) request.getAttribute("selectedLeaveTypeId");
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách đơn nghỉ phép</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            background: #ffffff;
            color: #1d1d1f;
            min-height: 100vh;
            -webkit-font-smoothing: antialiased;
        }
        .navbar {
            background: #ffffff;
            padding: 16px 0;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
            border-bottom: 1px solid rgba(0, 0, 0, 0.1);
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
            text-decoration: none;
            letter-spacing: -0.02em;
        }
        .main-container { max-width: 1400px; margin: 40px auto; padding: 0 30px; }
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        h1 {
            font-size: 28px;
            font-weight: 600;
            letter-spacing: -0.02em;
        }
        .btn-back {
            display: inline-block;
            padding: 8px 18px;
            background: #f5f5f7;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 980px;
            color: #1d1d1f;
            text-decoration: none;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            font-size: 14px;
            font-weight: 500;
        }
        .btn-back:hover { background: #e8e8ed; }

        .filter-section {
            background: #f5f5f7;
            border-radius: 18px;
            padding: 24px;
            margin-bottom: 24px;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }
        .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
        }
        .form-group { display: flex; flex-direction: column; }
        .form-group label {
            margin-bottom: 8px;
            color: #1d1d1f;
            font-size: 14px;
            font-weight: 500;
        }
        .form-control {
            background: #ffffff;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 12px;
            padding: 10px 14px;
            color: #1d1d1f;
            font-size: 14px;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }
        .form-control:focus {
            outline: none;
            border-color: #000000;
            box-shadow: 0 0 0 4px rgba(0, 0, 0, 0.06);
        }

        .table-card {
            background: #ffffff;
            border-radius: 18px;
            padding: 30px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            box-shadow: 0 2px 16px rgba(0, 0, 0, 0.08);
        }
        table { width: 100%; border-collapse: collapse; }
        th, td {
            padding: 16px;
            text-align: left;
            border-bottom: 1px solid rgba(0, 0, 0, 0.1);
        }
        th {
            background: #f5f5f7;
            color: #1d1d1f;
            font-weight: 600;
            font-size: 13px;
        }
        tbody tr {
            transition: all 0.2s cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }
        tbody tr:hover { 
            background: #f5f5f7;
            cursor: pointer;
        }
        .request-code {
            display: inline-block;
            padding: 6px 14px;
            background: #f5f5f7;
            color: #000000;
            font-weight: 600;
            font-size: 13px;
            border-radius: 8px;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            text-decoration: none;
            letter-spacing: -0.01em;
        }
        .request-code:hover {
            background: #000000;
            color: #ffffff;
            transform: scale(1.05);
        }
        .status {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
        }
        .status-inprogress { background: rgba(255, 149, 0, 0.15); color: #ff9500; }
        .status-approved { background: rgba(52, 199, 89, 0.15); color: #34c759; }
        .status-rejected { background: rgba(255, 59, 48, 0.15); color: #ff3b30; }
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #6e6e73;
        }
        .empty-state i { font-size: 64px; margin-bottom: 20px; opacity: 0.3; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/home" class="logo">
                🚀 Leave System
            </a>
        </div>
    </nav>

    <div class="main-container">
        <div class="page-header">
            <h1>📋 Danh sách đơn nghỉ phép</h1>
            <a href="${pageContext.request.contextPath}/home" class="btn-back">
                ← Quay lại
            </a>
        </div>

        <div class="filter-section">
            <form method="get" action="${pageContext.request.contextPath}/request/list">
                <div class="filter-grid">
                    <div class="form-group">
                        <label>🔍 Trạng thái</label>
                        <select name="status" class="form-control" onchange="this.form.submit()">
                            <option value="">Tất cả</option>
                            <option value="InProgress" <%= "InProgress".equals(selectedStatus) ? "selected" : "" %>>Đang chờ</option>
                            <option value="Approved" <%= "Approved".equals(selectedStatus) ? "selected" : "" %>>Đã duyệt</option>
                            <option value="Rejected" <%= "Rejected".equals(selectedStatus) ? "selected" : "" %>>Từ chối</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>🏷️ Loại nghỉ phép</label>
                        <select name="leaveTypeId" class="form-control" onchange="this.form.submit()">
                            <option value="">Tất cả</option>
                            <% if (leaveTypes != null) {
                                for (LeaveType lt : leaveTypes) { %>
                                <option value="<%= lt.getLeaveTypeID() %>"
                                    <%= String.valueOf(lt.getLeaveTypeID()).equals(selectedLeaveTypeId) ? "selected" : "" %>>
                                    <%= lt.getLeaveTypeName() %>
                                </option>
                            <% }} %>
                        </select>
                    </div>
                </div>
            </form>
        </div>
        
        <div class="table-card">
            <% if (requests != null && !requests.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>Mã đơn</th>
                            <th>Loại nghỉ</th>
                            <th>Từ ngày</th>
                            <th>Đến ngày</th>
                            <th>Số ngày</th>
                            <th>Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (LeaveRequest req : requests) { 
                            String statusClass = "status-inprogress";
                            if ("Approved".equals(req.getStatus())) statusClass = "status-approved";
                            else if ("Rejected".equals(req.getStatus())) statusClass = "status-rejected";
                        %>
                            <tr onclick="window.location.href='${pageContext.request.contextPath}/request/detail?id=<%= req.getRequestID() %>'">
                                <td>
                                    <a href="${pageContext.request.contextPath}/request/detail?id=<%= req.getRequestID() %>" 
                                       class="request-code"
                                       onclick="event.stopPropagation()">
                                        <%= req.getRequestCode() %>
                                    </a>
                                </td>
                                <td><%= req.getLeaveTypeName() != null ? req.getLeaveTypeName() : "N/A" %></td>
                                <td><%= req.getStartDate().format(dateFormatter) %></td>
                                <td><%= req.getEndDate().format(dateFormatter) %></td>
                                <td><%= req.getTotalDays() %></td>
                                <td><span class="status <%= statusClass %>"><%= req.getStatusDisplay() %></span></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <div class="empty-state">
                    <div style="font-size: 64px; margin-bottom: 20px;">📭</div>
                    <h2>Chưa có đơn nghỉ phép nào</h2>
                    <p>Bạn chưa tạo đơn nghỉ phép nào. Hãy tạo đơn mới!</p>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>