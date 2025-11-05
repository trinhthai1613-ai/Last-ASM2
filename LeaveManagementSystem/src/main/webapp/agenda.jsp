<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.*" %>
<%@ page import="com.company.lms.dao.LeaveTypeDAO" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.*" %>
<%
    Employee user = (Employee) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<Employee> employees = (List<Employee>) request.getAttribute("employees");
    List<LeaveRequest> leaveRequests = (List<LeaveRequest>) request.getAttribute("leaveRequests");
    List<Division> divisions = (List<Division>) request.getAttribute("divisions");
    
    LocalDate startDate = (LocalDate) request.getAttribute("startDate");
    LocalDate endDate = (LocalDate) request.getAttribute("endDate");
    Integer selectedDivisionId = (Integer) request.getAttribute("selectedDivisionId");
    Integer selectedEmployeeId = (Integer) request.getAttribute("selectedEmployeeId");
    Integer selectedLeaveTypeId = (Integer) request.getAttribute("selectedLeaveTypeId");
    String currentMonth = (String) request.getAttribute("currentMonth");

    // Lấy danh sách loại nghỉ phép
    LeaveTypeDAO leaveTypeDAO = new LeaveTypeDAO();
    List<LeaveType> leaveTypes = leaveTypeDAO.getAllLeaveTypes();

    // Tạo map để tra cứu nhanh
    Map<Integer, Map<LocalDate, LeaveRequest>> leaveMap = new HashMap<>();
    if (leaveRequests != null) {
        for (LeaveRequest lr : leaveRequests) {
            leaveMap.computeIfAbsent(lr.getEmployeeID(), k -> new HashMap<>());
            LocalDate current = lr.getStartDate();
            while (!current.isAfter(lr.getEndDate())) {
                leaveMap.get(lr.getEmployeeID()).put(current, lr);
                current = current.plusDays(1);
            }
        }
    }

    // Tính số ngày trong tháng và ngày bắt đầu
    YearMonth ym = YearMonth.parse(currentMonth);
    int daysInMonth = ym.lengthOfMonth();
    LocalDate firstDay = ym.atDay(1);
    int firstDayOfWeek = firstDay.getDayOfWeek().getValue(); // 1=Mon, 7=Sun
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch nghỉ phép</title>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Be Vietnam Pro', sans-serif;
            background: linear-gradient(135deg, #0a0e27 0%, #1a1d3e 50%, #2a2d5e 100%);
            min-height: 100vh; color: #fff; padding: 20px;
        }
        .container { max-width: 1600px; margin: 0 auto; }
        .header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 30px;
        }
        .header h1 {
            font-size: 32px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        .btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none; border-radius: 10px; padding: 10px 20px;
            color: #fff; font-weight: 600; cursor: pointer;
            transition: all 0.3s ease; text-decoration: none;
            display: inline-block;
        }
        .btn:hover { transform: translateY(-2px); box-shadow: 0 5px 20px rgba(102,126,234,0.4); }
        .btn-secondary { background: rgba(99,102,241,0.2); border: 1px solid rgba(99,102,241,0.5); }

        .filter-section {
            background: rgba(10,14,39,0.7); backdrop-filter: blur(20px);
            border-radius: 15px; padding: 25px; margin-bottom: 25px;
            border: 1px solid rgba(99,102,241,0.2);
        }
        .filter-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px; margin-bottom: 20px;
        }
        .form-group { display: flex; flex-direction: column; }
        .form-group label { margin-bottom: 8px; color: #94a3b8; font-size: 14px; }
        .form-control {
            background: rgba(15,23,42,0.5); border: 1px solid rgba(99,102,241,0.3);
            border-radius: 8px; padding: 10px 15px; color: #fff; font-size: 14px;
            transition: all 0.3s ease;
        }
        .form-control:focus {
            outline: none; border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102,126,234,0.1);
        }

        .calendar-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 20px; padding: 20px;
            background: rgba(10,14,39,0.7); border-radius: 15px;
            border: 1px solid rgba(99,102,241,0.2);
        }
        .month-title {
            font-size: 24px; font-weight: 700;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        .month-nav { display: flex; gap: 10px; }

        .calendar {
            background: rgba(10,14,39,0.7); backdrop-filter: blur(20px);
            border-radius: 15px; padding: 25px;
            border: 1px solid rgba(99,102,241,0.2);
        }
        .weekdays {
            display: grid; grid-template-columns: repeat(7, 1fr);
            gap: 10px; margin-bottom: 15px;
        }
        .weekday {
            text-align: center; padding: 15px;
            background: rgba(99,102,241,0.2);
            border-radius: 8px; font-weight: 600;
            color: #94a3b8;
        }
        .days {
            display: grid; grid-template-columns: repeat(7, 1fr);
            gap: 10px;
        }
        .day {
            min-height: 120px; padding: 10px;
            background: rgba(15,23,42,0.5);
            border: 1px solid rgba(99,102,241,0.2);
            border-radius: 8px; position: relative;
            transition: all 0.3s ease;
        }
        .day:hover {
            border-color: rgba(99,102,241,0.5);
            transform: translateY(-2px);
        }
        .day-number {
            font-weight: 700; font-size: 16px;
            color: #94a3b8; margin-bottom: 8px;
        }
        .day.today .day-number {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        .leave-item {
            background: rgba(239,68,68,0.15);
            border-left: 3px solid #ef4444;
            padding: 5px 8px; margin-bottom: 5px;
            border-radius: 4px; font-size: 12px;
            cursor: pointer; transition: all 0.3s ease;
        }
        .leave-item:hover {
            background: rgba(239,68,68,0.25);
            transform: translateX(3px);
        }
        .leave-name { font-weight: 600; color: #fff; }
        .leave-type { color: #fca5a5; font-size: 11px; }

        .legend {
            margin-top: 20px; padding: 15px;
            background: rgba(10,14,39,0.5);
            border-radius: 10px; display: flex;
            gap: 20px; flex-wrap: wrap;
        }
        .legend-item {
            display: flex; align-items: center; gap: 8px;
        }
        .legend-box {
            width: 20px; height: 20px; border-radius: 4px;
        }

        option { background: #1a1d3e; color: #fff; }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h1><i class="fas fa-calendar-alt"></i> Lịch nghỉ phép</h1>
        <div style="display: flex; gap: 10px;">
            <a href="${pageContext.request.contextPath}/export" class="btn">
                <i class="fas fa-download"></i> Xuất báo cáo
            </a>
            <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Quay lại
            </a>
        </div>
    </div>

    <!-- Filter Section -->
    <div class="filter-section">
        <form method="get" action="${pageContext.request.contextPath}/agenda">
            <div class="filter-grid">
                <div class="form-group">
                    <label><i class="fas fa-building"></i> Phòng ban</label>
                    <select name="divisionId" class="form-control" onchange="this.form.submit()">
                        <% if (divisions != null) {
                            for (Division div : divisions) { %>
                            <option value="<%= div.getDivisionID() %>"
                                <%= (selectedDivisionId != null && selectedDivisionId == div.getDivisionID()) ? "selected" : "" %>>
                                <%= div.getDivisionName() %>
                            </option>
                        <% }} %>
                    </select>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-user"></i> Nhân viên</label>
                    <select name="employeeId" class="form-control" onchange="this.form.submit()">
                        <option value="">Tất cả</option>
                        <% if (employees != null) {
                            for (Employee emp : employees) { %>
                            <option value="<%= emp.getEmployeeID() %>"
                                <%= (selectedEmployeeId != null && selectedEmployeeId == emp.getEmployeeID()) ? "selected" : "" %>>
                                <%= emp.getFullName() %>
                            </option>
                        <% }} %>
                    </select>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-tag"></i> Loại nghỉ phép</label>
                    <select name="leaveTypeId" class="form-control" onchange="this.form.submit()">
                        <option value="">Tất cả</option>
                        <% if (leaveTypes != null) {
                            for (LeaveType lt : leaveTypes) { %>
                            <option value="<%= lt.getLeaveTypeID() %>"
                                <%= (selectedLeaveTypeId != null && selectedLeaveTypeId == lt.getLeaveTypeID()) ? "selected" : "" %>>
                                <%= lt.getLeaveTypeName() %>
                            </option>
                        <% }} %>
                    </select>
                </div>

                <input type="hidden" name="month" value="<%= currentMonth %>">
            </div>
        </form>
    </div>

    <!-- Calendar Header -->
    <div class="calendar-header">
        <div class="month-title">
            <i class="fas fa-calendar"></i>
            Tháng <%= ym.getMonthValue() %>, <%= ym.getYear() %>
        </div>
        <div class="month-nav">
            <a href="?month=<%= ym.minusMonths(1).toString() %>&divisionId=<%= selectedDivisionId %>" class="btn btn-secondary">
                <i class="fas fa-chevron-left"></i>
            </a>
            <a href="?month=<%= YearMonth.now().toString() %>&divisionId=<%= selectedDivisionId %>" class="btn btn-secondary">
                Hôm nay
            </a>
            <a href="?month=<%= ym.plusMonths(1).toString() %>&divisionId=<%= selectedDivisionId %>" class="btn btn-secondary">
                <i class="fas fa-chevron-right"></i>
            </a>
        </div>
    </div>

    <!-- Calendar -->
    <div class="calendar">
        <div class="weekdays">
            <div class="weekday">Thứ 2</div>
            <div class="weekday">Thứ 3</div>
            <div class="weekday">Thứ 4</div>
            <div class="weekday">Thứ 5</div>
            <div class="weekday">Thứ 6</div>
            <div class="weekday">Thứ 7</div>
            <div class="weekday">Chủ nhật</div>
        </div>

        <div class="days">
            <% 
            // Empty cells trước ngày 1
            for (int i = 1; i < firstDayOfWeek; i++) { %>
                <div class="day" style="opacity: 0.3;"></div>
            <% }
            
            // Các ngày trong tháng
            for (int day = 1; day <= daysInMonth; day++) {
                LocalDate currentDate = ym.atDay(day);
                boolean isToday = currentDate.equals(LocalDate.now());
            %>
                <div class="day <%= isToday ? "today" : "" %>">
                    <div class="day-number"><%= day %></div>
                    <% 
                    // Hiển thị các đơn nghỉ trong ngày này
                    if (employees != null) {
                        for (Employee emp : employees) {
                            Map<LocalDate, LeaveRequest> empLeaves = leaveMap.get(emp.getEmployeeID());
                            if (empLeaves != null && empLeaves.containsKey(currentDate)) {
                                LeaveRequest lr = empLeaves.get(currentDate);
                    %>
                        <div class="leave-item" title="<%= lr.getReason() %>">
                            <div class="leave-name"><%= emp.getFullName() %></div>
                            <div class="leave-type"><%= lr.getLeaveTypeName() %></div>
                        </div>
                    <% 
                            }
                        }
                    }
                    %>
                </div>
            <% } %>
        </div>

        <div class="legend">
            <div class="legend-item">
                <div class="legend-box" style="background: rgba(239,68,68,0.3); border: 2px solid #ef4444;"></div>
                <span>Nghỉ phép</span>
            </div>
            <div class="legend-item">
                <div class="legend-box" style="background: transparent; border: 2px solid rgba(99,102,241,0.5);"></div>
                <span>Ngày làm việc</span>
            </div>
        </div>
    </div>
</div>
</body>
</html>