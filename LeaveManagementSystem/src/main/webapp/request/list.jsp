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
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Be Vietnam Pro', sans-serif;
            background: linear-gradient(135deg, #0a0e27 0%, #1a1d3e 50%, #2a2d5e 100%);
            min-height: 100vh; color: #fff;
        }
        .navbar {
            background: rgba(10, 14, 39, 0.95); backdrop-filter: blur(20px);
            padding: 20px 0; box-shadow: 0 4px 30px rgba(0, 0, 0, 0.3);
            border-bottom: 1px solid rgba(99, 102, 241, 0.2);
        }
        .nav-container {
            max-width: 1400px; margin: 0 auto; padding: 0 30px;
            display: flex; justify-content: space-between; align-items: center;
        }
        .logo {
            display: flex; align-items: center; gap: 15px;
            font-size: 24px; font-weight: 700;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            text-decoration: none;
        }
        .main-container { max-width: 1400px; margin: 40px auto; padding: 0 30px; }
        .page-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 30px;
        }
        h1 {
            font-size: 32px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        .btn-back {
            display: inline-block; padding: 10px 20px;
            background: rgba(99, 102, 241, 0.2);
            border: 1px solid rgba(99, 102, 241, 0.3);
            border-radius: 10px; color: #cbd5e1;
            text-decoration: none; transition: all 0.3s ease;
        }
        .btn-back:hover { background: rgba(99, 102, 241, 0.3); }

        .filter-section {
            background: rgba(10, 14, 39, 0.7); backdrop-filter: blur(20px);
            border-radius: 15px; padding: 25px; margin-bottom: 25px;
            border: 1px solid rgba(99, 102, 241, 0.2);
        }
        .filter-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }
        .form-group { display: flex; flex-direction: column; }
        .form-group label {
            margin-bottom: 8px; color: #94a3b8;
            font-size: 14px; font-weight: 500;
        }
        .form-control {
            background: rgba(15, 23, 42, 0.5);
            border: 1px solid rgba(99, 102, 241, 0.3);
            border-radius: 8px; padding: 10px 15px;
            color: #fff; font-size: 14px;
            transition: all 0.3s ease;
        }
        .form-control:focus {
            outline: none; border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .table-card {
            background: rgba(10, 14, 39, 0.7); backdrop-filter: blur(20px);
            border-radius: 20px; padding: 30px;
            border: 1px solid rgba(99, 102, 241, 0.2);
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
        }
        table { width: 100%; border-collapse: collapse; }
        th, td {
            padding: 15px; text-align: left;
            border-bottom: 1px solid rgba(99, 102, 241, 0.2);
        }
        th {
            background: rgba(99, 102, 241, 0.1);
            color: #667eea; font-weight: 600;
        }
        tr:hover { background: rgba(99, 102, 241, 0.05); }
        .request-code {
            color: #667eea; font-weight: 600;
            cursor: pointer; transition: all 0.3s ease;
        }
        .request-code:hover {
            color: #764ba2; text-decoration: underline;
        }
        .status {
            display: inline-block; padding: 5px 15px;
            border-radius: 20px; font-size: 13px; font-weight: 500;
        }
        .status-inprogress { background: rgba(251, 191, 36, 0.2); color: #fbbf24; }
        .status-approved { background: rgba(34, 197, 94, 0.2); color: #22c55e; }
        .status-rejected { background: rgba(239, 68, 68, 0.2); color: #ef4444; }
        .empty-state {
            text-align: center; padding: 60px 20px; color: #94a3b8;
        }
        .empty-state i { font-size: 64px; margin-bottom: 20px; opacity: 0.5; }
        option { background: #1a1d3e; color: #fff; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/home" class="logo">
                <i class="fas fa-rocket"></i>
                <span>Leave System</span>
            </a>
        </div>
    </nav>

    <div class="main-container">
        <div class="page-header">
            <h1><i class="fas fa-list"></i> Danh sách đơn nghỉ phép</h1>
            <a href="${pageContext.request.contextPath}/home" class="btn-back">
                <i class="fas fa-arrow-left"></i> Quay lại
            </a>
        </div>

        <!-- Filter Section -->
        <div class="filter-section">
            <form method="get" action="${pageContext.request.contextPath}/request/list">
                <div class="filter-grid">
                    <div class="form-group">
                        <label><i class="fas fa-filter"></i> Trạng thái</label>
                        <select name="status" class="form-control" onchange="this.form.submit()">
                            <option value="">Tất cả</option>
                            <option value="InProgress" <%= "InProgress".equals(selectedStatus) ? "selected" : "" %>>Đang chờ</option>
                            <option value="Approved" <%= "Approved".equals(selectedStatus) ? "selected" : "" %>>Đã duyệt</option>
                            <option value="Rejected" <%= "Rejected".equals(selectedStatus) ? "selected" : "" %>>Từ chối</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label><i class="fas fa-tag"></i> Loại nghỉ phép</label>
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
                            <tr>
                                <td>
                                    <a href="${pageContext.request.contextPath}/request/detail?id=<%= req.getRequestID() %>" 
                                       class="request-code">
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
                    <i class="fas fa-inbox"></i>
                    <h2>Chưa có đơn nghỉ phép nào</h2>
                    <p>Bạn chưa tạo đơn nghỉ phép nào. Hãy tạo đơn mới!</p>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>