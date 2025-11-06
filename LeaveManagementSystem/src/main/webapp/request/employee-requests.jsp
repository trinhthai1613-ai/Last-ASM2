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
    List<Employee> employees = (List<Employee>) request.getAttribute("employees");
    Integer roleLevel = (Integer) request.getAttribute("roleLevel");
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Đơn nghỉ phép nhân viên</title>
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
        .nav-container { max-width: 1400px; margin: 0 auto; padding: 0 30px; }
        .logo { font-size: 20px; font-weight: 600; color: #000; text-decoration: none; }
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
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
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
            overflow-x: auto;
        }
        table { width: 100%; border-collapse: collapse; min-width: 900px; }
        th, td { padding: 16px; text-align: left; border-bottom: 1px solid rgba(0,0,0,0.1); }
        th { background: #f5f5f7; font-weight: 600; }
        tbody tr { cursor: pointer; }
        tbody tr:hover { background: #f5f5f7; }
        .request-code {
            padding: 6px 14px;
            background: #f5f5f7;
            color: #000;
            font-weight: 600;
            border-radius: 8px;
            text-decoration: none;
        }
        .status {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
        }
        .status-inprogress { background: rgba(255,149,0,0.15); color: #ff9500; }
        .status-approved { background: rgba(52,199,89,0.15); color: #34c759; }
        .status-rejected { background: rgba(255,59,48,0.15); color: #ff3b30; }
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
            <h1>👥 Đơn nghỉ phép nhân viên</h1>
            <a href="${pageContext.request.contextPath}/home" class="btn-back">← Quay lại</a>
        </div>

        <div class="filter-section">
            <form method="get">
                <div class="filter-grid">
                    <% if (roleLevel != null && roleLevel == 1) { %>
                    <div class="form-group">
                        <label>🏢 Phòng ban</label>
                        <select name="divisionId" class="form-control">
                            <option value="">Tất cả</option>
                            <% if (divisions != null) {
                                for (Division div : divisions) { %>
                                <option value="<%= div.getDivisionID() %>">
                                    <%= div.getDivisionName() %>
                                </option>
                            <% }} %>
                        </select>
                    </div>
                    <% } %>
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
                        <label>🔍 Trạng thái</label>
                        <select name="status" class="form-control">
                            <option value="">Tất cả</option>
                            <option value="InProgress">Đang chờ</option>
                            <option value="Approved">Đã duyệt</option>
                            <option value="Rejected">Từ chối</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>🏷️ Loại nghỉ</label>
                        <select name="leaveTypeId" class="form-control">
                            <option value="">Tất cả</option>
                            <% if (leaveTypes != null) {
                                for (LeaveType lt : leaveTypes) { %>
                                <option value="<%= lt.getLeaveTypeID() %>">
                                    <%= lt.getLeaveTypeName() %>
                                </option>
                            <% }} %>
                        </select>
                    </div>
                </div>
                <button type="submit" class="btn-filter">🔍 Lọc</button>
            </form>
        </div>
        
        <div class="table-card">
            <% if (requests != null && !requests.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>Mã đơn</th>
                            <th>Nhân viên</th>
                            <th>Phòng ban</th>
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
                                       class="request-code" onclick="event.stopPropagation()">
                                        <%= req.getRequestCode() %>
                                    </a>
                                </td>
                                <td><%= req.getEmployeeCode() %> - <%= req.getEmployeeName() %></td>
                                <td><%= req.getDivisionName() %></td>
                                <td><%= req.getLeaveTypeName() %></td>
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
                    <div style="font-size: 64px;">📭</div>
                    <h2>Chưa có đơn nào</h2>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>