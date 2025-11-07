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
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn nghỉ phép nhân viên</title>
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
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
            border-bottom: 1px solid rgba(0,0,0,0.1);
            position: sticky;
            top: 0;
            z-index: 100;
            backdrop-filter: blur(20px);
        }
        
        .nav-container { 
            max-width: 1400px; 
            margin: 0 auto; 
            padding: 0 30px; 
        }
        
        .logo { 
            font-size: 20px; 
            font-weight: 600; 
            color: #000000; 
            text-decoration: none; 
            letter-spacing: -0.02em;
        }
        
        .main-container { 
            max-width: 1400px; 
            margin: 40px auto; 
            padding: 0 30px; 
        }
        
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
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 10px 20px;
            background: #f5f5f7;
            border: 1px solid rgba(0,0,0,0.1);
            border-radius: 12px;
            color: #1d1d1f;
            text-decoration: none;
            font-size: 15px;
            font-weight: 500;
            transition: all 0.2s ease;
        }
        
        .btn-back:hover { 
            background: #e8e8ed; 
            transform: translateX(-4px);
        }
        
        .filter-section {
            background: #f5f5f7;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 24px;
            border: 1px solid rgba(0,0,0,0.1);
        }
        
        .filter-wrapper {
            display: flex;
            gap: 16px;
            align-items: flex-end;
        }
        
        .filter-fields {
            display: flex;
            gap: 16px;
            flex: 1;
            flex-wrap: wrap;
        }
        
        .form-group { 
            display: flex; 
            flex-direction: column;
            min-width: 180px;
            flex: 1;
        }
        
        .form-group label {
            margin-bottom: 8px;
            color: #1d1d1f;
            font-size: 14px;
            font-weight: 500;
        }
        
        .form-control {
            background: #ffffff;
            border: 1px solid rgba(0,0,0,0.1);
            border-radius: 12px;
            padding: 10px 14px;
            font-size: 14px;
            color: #1d1d1f;
            transition: all 0.2s ease;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #000000;
            box-shadow: 0 0 0 4px rgba(0, 0, 0, 0.06);
        }
        
        .btn-filter {
            padding: 10px 24px;
            background: #000000;
            color: #ffffff;
            border: none;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            white-space: nowrap;
        }
        
        .btn-filter:hover {
            background: #1d1d1f;
            transform: translateY(-1px);
        }
        
        .table-card {
            background: #ffffff;
            border-radius: 16px;
            padding: 30px;
            border: 1px solid rgba(0,0,0,0.1);
            box-shadow: 0 2px 16px rgba(0,0,0,0.08);
            overflow-x: auto;
        }
        
        table { 
            width: 100%; 
            border-collapse: collapse; 
            min-width: 900px; 
        }
        
        th, td { 
            padding: 16px; 
            text-align: left; 
            border-bottom: 1px solid rgba(0,0,0,0.1); 
        }
        
        th { 
            background: #f5f5f7; 
            font-weight: 600; 
            font-size: 13px;
            color: #1d1d1f;
        }
        
        tbody tr { 
            cursor: pointer; 
            transition: all 0.2s ease;
        }
        
        tbody tr:hover { 
            background: #f5f5f7; 
        }
        
        .request-code {
            display: inline-block;
            padding: 6px 14px;
            background: #f5f5f7;
            color: #000000;
            font-weight: 600;
            font-size: 13px;
            border-radius: 8px;
            text-decoration: none;
            transition: all 0.2s ease;
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
        
        .status-inprogress { 
            background: rgba(255,149,0,0.15); 
            color: #ff9500; 
        }
        
        .status-approved { 
            background: rgba(52,199,89,0.15); 
            color: #34c759; 
        }
        
        .status-rejected { 
            background: rgba(255,59,48,0.15); 
            color: #ff3b30; 
        }
        
        .empty-state { 
            text-align: center; 
            padding: 80px 40px; 
            color: #6e6e73; 
        }
        
        .empty-state-icon {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.3;
        }
        
        .empty-state h2 {
            font-size: 24px;
            font-weight: 600;
            color: #1d1d1f;
            margin-bottom: 8px;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/home" class="logo">
                Leave System
            </a>
        </div>
    </nav>

    <div class="main-container">
        <div class="page-header">
            <h1>👥 Đơn nghỉ phép nhân viên</h1>
            <a href="${pageContext.request.contextPath}/home" class="btn-back">
                ← Quay lại
            </a>
        </div>

        <div class="filter-section">
            <form method="get">
                <div class="filter-wrapper">
                    <div class="filter-fields">
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
                            <label>📋 Trạng thái</label>
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
                </div>
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
                    <div class="empty-state-icon">🔭</div>
                    <h2>Chưa có đơn nào</h2>
                    <p>Không tìm thấy đơn nghỉ phép nào phù hợp với bộ lọc</p>
                </div>
            <% } %>
        </div>
    </div>

    <script>
        // Prevent any accidental double-clicks on links
        document.querySelectorAll('.request-code').forEach(function(link) {
            link.addEventListener('click', function(e) {
                e.stopPropagation();
            });
        });
    </script>
</body>
</html>