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

    LeaveTypeDAO leaveTypeDAO = new LeaveTypeDAO();
    List<LeaveType> leaveTypes = leaveTypeDAO.getAllLeaveTypes();

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

    YearMonth ym = YearMonth.parse(currentMonth);
    int daysInMonth = ym.lengthOfMonth();
    LocalDate firstDay = ym.atDay(1);
    int firstDayOfWeek = firstDay.getDayOfWeek().getValue();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch nghỉ phép</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            background: #ffffff;
            min-height: 100vh;
            color: #1d1d1f;
            padding: 20px;
            -webkit-font-smoothing: antialiased;
        }
        .container { max-width: 1600px; margin: 0 auto; }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        .header h1 {
            font-size: 28px;
            font-weight: 600;
            letter-spacing: -0.02em;
        }
        .btn {
            background: #000000;
            border: none;
            border-radius: 980px;
            padding: 8px 18px;
            color: #fff;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
            letter-spacing: -0.01em;
        }
        .btn:hover {
            transform: scale(1.02);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        .btn-secondary {
            background: #f5f5f7;
            border: 1px solid rgba(0, 0, 0, 0.1);
            color: #1d1d1f;
        }
        .btn-secondary:hover {
            background: #e8e8ed;
            transform: scale(1.02);
        }

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
            margin-bottom: 16px;
        }
        .form-group { display: flex; flex-direction: column; }
        .form-group label {
            margin-bottom: 8px;
            color: #6e6e73;
            font-size: 13px;
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

        .calendar-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding: 20px;
            background: #f5f5f7;
            border-radius: 18px;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }
        .month-title {
            font-size: 22px;
            font-weight: 600;
            letter-spacing: -0.02em;
        }
        .month-nav { display: flex; gap: 10px; }

        .calendar {
            background: #ffffff;
            border-radius: 18px;
            padding: 24px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            box-shadow: 0 2px 16px rgba(0, 0, 0, 0.08);
        }
        .weekdays {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: 10px;
            margin-bottom: 15px;
        }
        .weekday {
            text-align: center;
            padding: 12px;
            background: #f5f5f7;
            border-radius: 12px;
            font-weight: 600;
            color: #6e6e73;
            font-size: 13px;
        }
        .days {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: 10px;
        }
        .day {
            min-height: 120px;
            padding: 10px;
            background: #ffffff;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 12px;
            position: relative;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }
        .day:hover {
            border-color: rgba(0, 0, 0, 0.2);
            transform: translateY(-2px);
        }
        .day-number {
            font-weight: 600;
            font-size: 14px;
            color: #6e6e73;
            margin-bottom: 8px;
        }
        .day.today .day-number {
            color: #000000;
        }
        .leave-item {
            background: rgba(255, 59, 48, 0.1);
            border-left: 3px solid #ff3b30;
            padding: 5px 8px;
            margin-bottom: 5px;
            border-radius: 6px;
            font-size: 11px;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }
        .leave-item:hover {
            background: rgba(255, 59, 48, 0.2);
            transform: translateX(3px);
        }
        .leave-name { font-weight: 600; color: #1d1d1f; }
        .leave-type { color: #ff3b30; font-size: 10px; }

        .legend {
            margin-top: 20px;
            padding: 16px;
            background: #f5f5f7;
            border-radius: 12px;
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
        }
        .legend-item {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .legend-box {
            width: 20px;
            height: 20px;
            border-radius: 6px;
        }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h1>📅 Lịch nghỉ phép</h1>
        <div style="display: flex; gap: 10px;">
            <a href="${pageContext.request.contextPath}/export" class="btn">
                ⬇️ Xuất báo cáo
            </a>
            <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary">
                ← Quay lại
            </a>
        </div>
    </div>

    <div class="filter-section">
        <form method="get" action="${pageContext.request.contextPath}/agenda">
            <div class="filter-grid">
                <div class="form-group">
                    <label>🏢 Phòng ban</label>
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
                    <label>👤 Nhân viên</label>
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
                    <label>🏷️ Loại nghỉ phép</label>
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

    <div class="calendar-header">
        <div class="month-title">
            📆 Tháng <%= ym.getMonthValue() %>, <%= ym.getYear() %>
        </div>
        <div class="month-nav">
            <a href="?month=<%= ym.minusMonths(1).toString() %>&divisionId=<%= selectedDivisionId %>" class="btn btn-secondary">
                ←
            </a>
            <a href="?month=<%= YearMonth.now().toString() %>&divisionId=<%= selectedDivisionId %>" class="btn btn-secondary">
                Hôm nay
            </a>
            <a href="?month=<%= ym.plusMonths(1).toString() %>&divisionId=<%= selectedDivisionId %>" class="btn btn-secondary">
                →
            </a>
        </div>
    </div>

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
            for (int i = 1; i < firstDayOfWeek; i++) { %>
                <div class="day" style="opacity: 0.3;"></div>
            <% }
            
            for (int day = 1; day <= daysInMonth; day++) {
                LocalDate currentDate = ym.atDay(day);
                boolean isToday = currentDate.equals(LocalDate.now());
            %>
                <div class="day <%= isToday ? "today" : "" %>">
                    <div class="day-number"><%= day %></div>
                    <% 
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
                <div class="legend-box" style="background: rgba(255,59,48,0.2); border: 2px solid #ff3b30;"></div>
                <span>Nghỉ phép</span>
            </div>
            <div class="legend-item">
                <div class="legend-box" style="background: transparent; border: 2px solid rgba(0,0,0,0.1);"></div>
                <span>Ngày làm việc</span>
            </div>
        </div>
    </div>
</div>
</body>
</html>