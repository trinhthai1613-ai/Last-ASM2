<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.Employee" %>
<%@ page import="com.company.lms.model.LeaveRequest" %>
<%@ page import="com.company.lms.model.Division" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%
    Employee user = (Employee) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    @SuppressWarnings("unchecked")
    List<Employee> employees = (List<Employee>) request.getAttribute("employees");
    
    @SuppressWarnings("unchecked")
    List<LeaveRequest> leaveRequests = (List<LeaveRequest>) request.getAttribute("leaveRequests");
    
    @SuppressWarnings("unchecked")
    List<Division> divisions = (List<Division>) request.getAttribute("divisions");
    
    String startDateStr = (String) request.getAttribute("startDate");
    String endDateStr = (String) request.getAttribute("endDate");
    Integer selectedDivisionId = (Integer) request.getAttribute("selectedDivisionId");
    
    LocalDate startDate = startDateStr != null ? LocalDate.parse(startDateStr) : LocalDate.now();
    LocalDate endDate = endDateStr != null ? LocalDate.parse(endDateStr) : LocalDate.now().plusDays(30);
    
    // Build a map for quick lookup: employeeID -> (date -> leaveRequest)
    Map<Integer, Map<LocalDate, LeaveRequest>> leaveMap = new HashMap<>();
    if (leaveRequests != null) {
        for (LeaveRequest lr : leaveRequests) {
            int empId = lr.getEmployeeID();
            if (!leaveMap.containsKey(empId)) {
                leaveMap.put(empId, new HashMap<>());
            }
            
            LocalDate current = lr.getStartDate();
            while (!current.isAfter(lr.getEndDate())) {
                leaveMap.get(empId).put(current, lr);
                current = current.plusDays(1);
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch nghỉ phép - Agenda</title>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Be Vietnam Pro', sans-serif;
            background: linear-gradient(135deg, #0a0e27 0%, #1a1d3e 50%, #2a2d5e 100%);
            min-height: 100vh;
            color: #fff;
            padding: 20px;
        }
        
        .container {
            max-width: 1600px;
            margin: 0 auto;
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        
        .header h1 {
            font-size: 32px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        .btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            border-radius: 10px;
            padding: 10px 20px;
            color: #fff;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }
        
        .btn-secondary {
            background: rgba(99, 102, 241, 0.2);
            border: 1px solid rgba(99, 102, 241, 0.5);
        }
        
        .filter-section {
            background: rgba(10, 14, 39, 0.7);
            backdrop-filter: blur(20px);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 25px;
            border: 1px solid rgba(99, 102, 241, 0.2);
        }
        
        .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        .form-group label {
            margin-bottom: 8px;
            color: #94a3b8;
            font-size: 14px;
        }
        
        .form-control {
            background: rgba(15, 23, 42, 0.5);
            border: 1px solid rgba(99, 102, 241, 0.3);
            border-radius: 8px;
            padding: 10px 15px;
            color: #fff;
            font-size: 14px;
            transition: all 0.3s ease;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .calendar-wrapper {
            background: rgba(10, 14, 39, 0.7);
            backdrop-filter: blur(20px);
            border-radius: 15px;
            padding: 20px;
            border: 1px solid rgba(99, 102, 241, 0.2);
            overflow-x: auto;
            position: relative;
        }
        
        .calendar-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 800px;
        }
        
        .calendar-table th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 12px 8px;
            text-align: center;
            font-weight: 600;
            font-size: 13px;
            border: 1px solid rgba(99, 102, 241, 0.3);
            position: sticky;
            top: 0;
            z-index: 10;
        }
        
        .calendar-table th.employee-col {
            min-width: 150px;
            text-align: left;
            padding-left: 15px;
        }
        
        .calendar-table td {
            padding: 15px 8px;
            text-align: center;
            border: 1px solid rgba(99, 102, 241, 0.2);
            background: rgba(15, 23, 42, 0.3);
            transition: all 0.3s ease;
        }
        
        .calendar-table td.employee-name {
            text-align: left;
            padding-left: 15px;
            font-weight: 500;
            background: rgba(15, 23, 42, 0.5);
        }
        
        .calendar-table td.working {
            background: rgba(16, 185, 129, 0.2);
        }
        
        .calendar-table td.on-leave {
            background: rgba(239, 68, 68, 0.3);
            position: relative;
            cursor: pointer;
        }
        
        .calendar-table td.on-leave:hover {
            background: rgba(239, 68, 68, 0.5);
        }
        
        .calendar-table td.on-leave::after {
            content: '🏖️';
            font-size: 18px;
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 20px;
            margin-top: 25px;
        }
        
        .pagination .page-info {
            color: #94a3b8;
            font-size: 14px;
        }
        
        .btn-nav {
            background: rgba(99, 102, 241, 0.2);
            border: 1px solid rgba(99, 102, 241, 0.5);
            padding: 8px 16px;
            border-radius: 8px;
            color: #fff;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .btn-nav:hover:not(:disabled) {
            background: rgba(99, 102, 241, 0.4);
            transform: translateX(0);
        }
        
        .btn-nav:disabled {
            opacity: 0.3;
            cursor: not-allowed;
        }
        
        .tooltip {
            position: absolute;
            background: rgba(10, 14, 39, 0.95);
            border: 1px solid rgba(99, 102, 241, 0.5);
            border-radius: 8px;
            padding: 10px 15px;
            color: #fff;
            font-size: 12px;
            pointer-events: none;
            z-index: 1000;
            display: none;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
        }
        
        .calendar-slide {
            animation: slideIn 0.4s ease-out;
        }
        
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateX(30px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }
        
        .no-data {
            text-align: center;
            padding: 60px 20px;
            color: #94a3b8;
        }
        
        .no-data i {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.5;
        }
        
        .legend {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        
        .legend-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: #94a3b8;
        }
        
        .legend-box {
            width: 24px;
            height: 24px;
            border-radius: 4px;
            border: 1px solid rgba(99, 102, 241, 0.3);
        }
        
        .legend-box.working {
            background: rgba(16, 185, 129, 0.2);
        }
        
        .legend-box.leave {
            background: rgba(239, 68, 68, 0.3);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1><i class="fas fa-calendar-alt"></i> Lịch nghỉ phép phòng ban</h1>
            <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Quay lại
            </a>
        </div>
        
        <!-- Filter Section -->
        <div class="filter-section">
            <form method="get" action="${pageContext.request.contextPath}/agenda" id="filterForm">
                <div class="filter-grid">
                    <div class="form-group">
                        <label><i class="fas fa-building"></i> Phòng ban</label>
                        <select name="divisionId" class="form-control" id="divisionSelect">
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
                        <label><i class="fas fa-calendar-day"></i> Từ ngày</label>
                        <input type="date" name="startDate" class="form-control" 
                               value="<%= startDateStr %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label><i class="fas fa-calendar-day"></i> Đến ngày</label>
                        <input type="date" name="endDate" class="form-control" 
                               value="<%= endDateStr %>" required>
                    </div>
                </div>
                
                <button type="submit" class="btn">
                    <i class="fas fa-search"></i> Xem lịch
                </button>
            </form>
        </div>
        
        <!-- Legend -->
        <div class="legend">
            <div class="legend-item">
                <div class="legend-box working"></div>
                <span>Đi làm</span>
            </div>
            <div class="legend-item">
                <div class="legend-box leave"></div>
                <span>Nghỉ phép</span>
            </div>
        </div>
        
        <!-- Calendar Table -->
        <div class="calendar-wrapper">
            <% if (employees != null && !employees.isEmpty()) { 
                long daysBetween = ChronoUnit.DAYS.between(startDate, endDate) + 1;
                int currentPage = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 0;
                int daysPerPage = 7;
                int totalPages = (int) Math.ceil((double) daysBetween / daysPerPage);
                
                LocalDate pageStartDate = startDate.plusDays(currentPage * daysPerPage);
                LocalDate pageEndDate = pageStartDate.plusDays(daysPerPage - 1);
                if (pageEndDate.isAfter(endDate)) {
                    pageEndDate = endDate;
                }
            %>
                <div class="calendar-slide" id="calendarTable">
                    <table class="calendar-table">
                        <thead>
                            <tr>
                                <th class="employee-col">Nhân sự</th>
                                <% 
                                LocalDate currentDate = pageStartDate;
                                while (!currentDate.isAfter(pageEndDate)) { 
                                    String dayOfWeek = "";
                                    switch (currentDate.getDayOfWeek().getValue()) {
                                        case 1: dayOfWeek = "T2"; break;
                                        case 2: dayOfWeek = "T3"; break;
                                        case 3: dayOfWeek = "T4"; break;
                                        case 4: dayOfWeek = "T5"; break;
                                        case 5: dayOfWeek = "T6"; break;
                                        case 6: dayOfWeek = "T7"; break;
                                        case 7: dayOfWeek = "CN"; break;
                                    }
                                %>
                                    <th><%= currentDate.getDayOfMonth() %>/<%= currentDate.getMonthValue() %><br><small><%= dayOfWeek %></small></th>
                                <% 
                                    currentDate = currentDate.plusDays(1);
                                } %>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Employee emp : employees) { %>
                                <tr>
                                    <td class="employee-name"><%= emp.getFullName() %></td>
                                    <% 
                                    LocalDate cellDate = pageStartDate;
                                    while (!cellDate.isAfter(pageEndDate)) {
                                        boolean onLeave = false;
                                        LeaveRequest leaveReq = null;
                                        
                                        if (leaveMap.containsKey(emp.getEmployeeID())) {
                                            leaveReq = leaveMap.get(emp.getEmployeeID()).get(cellDate);
                                            onLeave = (leaveReq != null);
                                        }
                                        
                                        String cellClass = onLeave ? "on-leave" : "working";
                                        String tooltipData = "";
                                        if (onLeave && leaveReq != null) {
                                            tooltipData = String.format("data-tooltip='%s: %s<br>%s - %s'", 
                                                leaveReq.getLeaveTypeName() != null ? leaveReq.getLeaveTypeName() : "Nghỉ phép",
                                                leaveReq.getReason() != null ? leaveReq.getReason() : "",
                                                leaveReq.getStartDate(),
                                                leaveReq.getEndDate());
                                        }
                                    %>
                                        <td class="<%= cellClass %>" <%= tooltipData %>></td>
                                    <% 
                                        cellDate = cellDate.plusDays(1);
                                    } %>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                
                <!-- Pagination -->
                <% if (totalPages > 1) { %>
                <div class="pagination">
                    <button class="btn-nav" <%= currentPage == 0 ? "disabled" : "" %>
                            onclick="changePage(<%= currentPage - 1 %>)">
                        <i class="fas fa-chevron-left"></i> Trước đó
                    </button>
                    
                    <div class="page-info">
                        Tuần <%= currentPage + 1 %> / <%= totalPages %>
                        (Từ <%= pageStartDate %> đến <%= pageEndDate %>)
                    </div>
                    
                    <button class="btn-nav" <%= currentPage >= totalPages - 1 ? "disabled" : "" %>
                            onclick="changePage(<%= currentPage + 1 %>)">
                        Tiếp theo <i class="fas fa-chevron-right"></i>
                    </button>
                </div>
                <% } %>
            <% } else { %>
                <div class="no-data">
                    <i class="fas fa-users-slash"></i>
                    <h3>Không có dữ liệu</h3>
                    <p>Không có nhân viên nào trong phòng ban này hoặc chưa chọn thời gian.</p>
                </div>
            <% } %>
        </div>
    </div>
    
    <div class="tooltip" id="tooltip"></div>
    
    <script>
        // Tooltip functionality
        const tooltip = document.getElementById('tooltip');
        const leaveCells = document.querySelectorAll('td.on-leave[data-tooltip]');
        
        leaveCells.forEach(cell => {
            cell.addEventListener('mouseenter', function(e) {
                const tooltipText = this.getAttribute('data-tooltip');
                tooltip.innerHTML = tooltipText;
                tooltip.style.display = 'block';
                positionTooltip(e);
            });
            
            cell.addEventListener('mousemove', positionTooltip);
            
            cell.addEventListener('mouseleave', function() {
                tooltip.style.display = 'none';
            });
        });
        
        function positionTooltip(e) {
            tooltip.style.left = (e.pageX + 15) + 'px';
            tooltip.style.top = (e.pageY + 15) + 'px';
        }
        
        // Pagination with smooth animation
        function changePage(page) {
            const url = new URL(window.location.href);
            url.searchParams.set('page', page);
            
            // Add fade out animation
            const calendarTable = document.getElementById('calendarTable');
            if (calendarTable) {
                calendarTable.style.animation = 'none';
                setTimeout(() => {
                    window.location.href = url.toString();
                }, 100);
            } else {
                window.location.href = url.toString();
            }
        }
        
        // ✅ Form validation and improvements
        const filterForm = document.getElementById('filterForm');
        const startDateInput = document.querySelector('input[name="startDate"]');
        const endDateInput = document.querySelector('input[name="endDate"]');
        const submitBtn = filterForm.querySelector('button[type="submit"]');
        
        // Validate date range
        filterForm.addEventListener('submit', function(e) {
            const startDate = new Date(startDateInput.value);
            const endDate = new Date(endDateInput.value);
            
            // Check if dates are valid
            if (!startDateInput.value || !endDateInput.value) {
                e.preventDefault();
                alert('Vui lòng chọn đầy đủ ngày bắt đầu và ngày kết thúc!');
                return false;
            }
            
            // Check if end date is after start date
            if (endDate < startDate) {
                e.preventDefault();
                alert('Ngày kết thúc phải sau hoặc bằng ngày bắt đầu!');
                endDateInput.focus();
                return false;
            }
            
            // Check if date range is too long (> 90 days)
            const daysDiff = Math.ceil((endDate - startDate) / (1000 * 60 * 60 * 24));
            if (daysDiff > 90) {
                e.preventDefault();
                alert('Khoảng thời gian không được vượt quá 90 ngày!\nHiện tại: ' + daysDiff + ' ngày');
                return false;
            }
            
            // Add loading state
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang tải...';
            
            // Reset page parameter when filter changes
            const currentUrl = new URL(window.location.href);
            if (currentUrl.searchParams.has('page')) {
                const formData = new FormData(filterForm);
                const params = new URLSearchParams(formData);
                params.delete('page');
                filterForm.action = currentUrl.pathname + '?' + params.toString();
            }
        });
        
        // Auto-update end date when start date changes (set to +30 days)
        startDateInput.addEventListener('change', function() {
            if (!endDateInput.value) {
                const startDate = new Date(this.value);
                startDate.setDate(startDate.getDate() + 30);
                endDateInput.value = startDate.toISOString().split('T')[0];
            }
            // Update min attribute for end date
            endDateInput.min = this.value;
        });
        
        // Set initial min for end date
        if (startDateInput.value) {
            endDateInput.min = startDateInput.value;
        }
        
        // Enter key support for quick search
        document.querySelectorAll('.form-control').forEach(input => {
            input.addEventListener('keypress', function(e) {
                if (e.key === 'Enter' && e.target.tagName !== 'SELECT') {
                    e.preventDefault();
                    filterForm.submit();
                }
            });
        });
        
        // Show success message if redirected from another page
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('success')) {
            // Could show a toast notification here
            console.log('Loaded successfully');
        }
    </script>
</body>
</html>
