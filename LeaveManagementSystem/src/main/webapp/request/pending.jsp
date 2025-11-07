<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.Employee" %>
<%@ page import="com.company.lms.model.LeaveRequest" %>
<%@ page import="com.company.lms.model.Division" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    Employee user = (Employee) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<LeaveRequest> pendingRequests = (List<LeaveRequest>) request.getAttribute("pendingRequests");
    List<Division> allDivisions = (List<Division>) request.getAttribute("allDivisions");
    Boolean isHRManager = (Boolean) request.getAttribute("isHRManager");
    Boolean isDivisionLeader = (Boolean) request.getAttribute("isDivisionLeader");
    String userDivisionName = (String) request.getAttribute("userDivisionName");
    String[] selectedDivisions = (String[]) request.getAttribute("selectedDivisions");
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Duyệt đơn nghỉ phép</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
            background: #ffffff;
            color: #1d1d1f;
            min-height: 100vh;
            -webkit-font-smoothing: antialiased;
        }
        
        .navbar {
            background: #ffffff;
            padding: 16px 0;
            border-bottom: 1px solid rgba(0, 0, 0, 0.1);
            position: sticky;
            top: 0;
            z-index: 100;
            backdrop-filter: blur(20px);
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
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
            margin-bottom: 30px;
        }
        
        .page-header h1 {
            font-size: 36px;
            font-weight: 700;
            letter-spacing: -0.03em;
            margin-bottom: 8px;
        }
        
        .page-header p {
            font-size: 17px;
            color: #6e6e73;
            font-weight: 400;
        }
        
        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 10px 20px;
            background: #f5f5f7;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 12px;
            color: #1d1d1f;
            text-decoration: none;
            margin-bottom: 24px;
            transition: all 0.2s ease;
            font-size: 15px;
            font-weight: 500;
        }
        
        .btn-back:hover {
            background: #e8e8ed;
            transform: translateX(-4px);
        }
        
        /* Filter Section - HR Only */
        .filter-section {
            background: #f5f5f7;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 30px;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }
        
        .filter-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .filter-header h3 {
            font-size: 18px;
            font-weight: 600;
        }
        
        .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 12px;
        }
        
        .filter-checkbox {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 12px 16px;
            background: #ffffff;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .filter-checkbox:hover {
            border-color: #000000;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        }
        
        .filter-checkbox input[type="checkbox"] {
            width: 20px;
            height: 20px;
            cursor: pointer;
            accent-color: #000000;
        }
        
        .filter-checkbox label {
            cursor: pointer;
            font-size: 15px;
            flex: 1;
            color: #1d1d1f;
        }
        
        .filter-actions {
            display: flex;
            gap: 12px;
            margin-top: 20px;
        }
        
        .btn-filter {
            padding: 12px 24px;
            border: none;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .btn-apply {
            background: #000000;
            color: #ffffff;
        }
        
        .btn-apply:hover {
            transform: scale(1.02);
            background: #1d1d1f;
        }
        
        .btn-reset {
            background: transparent;
            color: #6e6e73;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }
        
        .btn-reset:hover {
            border-color: #000000;
            color: #1d1d1f;
        }
        
        /* Division Badge - For Division Leaders */
        .division-badge {
            display: inline-block;
            background: #f5f5f7;
            border: 1px solid rgba(0, 0, 0, 0.1);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            margin-bottom: 20px;
            color: #6e6e73;
        }
        
        .division-badge strong {
            color: #1d1d1f;
        }
        
        /* Alert Messages */
        .alert {
            padding: 16px 20px;
            border-radius: 12px;
            margin-bottom: 24px;
            font-size: 15px;
        }
        
        .alert-success {
            background: rgba(52, 199, 89, 0.15);
            border: 1px solid rgba(52, 199, 89, 0.3);
            color: #30d158;
        }
        
        .alert-error {
            background: rgba(255, 69, 58, 0.15);
            border: 1px solid rgba(255, 69, 58, 0.3);
            color: #ff453a;
        }
        
        /* Requests Grid */
        .requests-grid {
            display: grid;
            gap: 20px;
        }
        
        .request-card {
            background: #ffffff;
            border-radius: 16px;
            padding: 24px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
        }
        
        .request-card:hover {
            transform: translateY(-4px);
            border-color: rgba(0, 0, 0, 0.2);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.12);
        }
        
        .request-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 20px;
            padding-bottom: 16px;
            border-bottom: 1px solid rgba(0, 0, 0, 0.1);
        }
        
        .employee-info {
            display: flex;
            align-items: center;
            gap: 16px;
        }
        
        .employee-avatar {
            width: 52px;
            height: 52px;
            border-radius: 50%;
            background: linear-gradient(135deg, #000000 0%, #3a3a3c 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 20px;
            color: #ffffff;
        }
        
        .employee-details h3 {
            font-size: 18px;
            margin-bottom: 4px;
            font-weight: 600;
        }
        
        .employee-details p {
            font-size: 14px;
            color: #6e6e73;
        }
        
        .request-badges {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 8px;
        }
        
        .request-badge {
            padding: 6px 12px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 600;
            background: rgba(255, 159, 10, 0.15);
            color: #ff9f0a;
            border: 1px solid rgba(255, 159, 10, 0.3);
        }
        
        .division-label {
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 500;
            background: #f5f5f7;
            color: #6e6e73;
        }
        
        .request-body {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .info-item {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        
        .info-label {
            font-size: 12px;
            color: #6e6e73;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: 600;
        }
        
        .info-value {
            font-size: 15px;
            font-weight: 500;
            color: #1d1d1f;
        }
        
        .reason-box {
            background: #f5f5f7;
            border-radius: 12px;
            padding: 16px;
            margin-bottom: 20px;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }
        
        .reason-box h4 {
            font-size: 12px;
            color: #6e6e73;
            margin-bottom: 10px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .reason-box p {
            font-size: 15px;
            line-height: 1.5;
            color: #1d1d1f;
        }
        
        .action-buttons {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }
        
        .btn {
            padding: 14px 20px;
            border: none;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        
        .btn-approve {
            background: #000000;
            color: #ffffff;
        }
        
        .btn-approve:hover {
            transform: scale(1.02);
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
            background: #1d1d1f;
        }
        
        .btn-reject {
            background: transparent;
            border: 1px solid rgba(0, 0, 0, 0.1);
            color: #6e6e73;
        }
        
        .btn-reject:hover {
            border-color: #000000;
            color: #1d1d1f;
        }
        
        /* Empty State */
        .empty-state {
            background: #ffffff;
            border-radius: 16px;
            padding: 80px 40px;
            text-align: center;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }
        
        .empty-state-icon {
            font-size: 72px;
            margin-bottom: 24px;
            opacity: 0.3;
        }
        
        .empty-state h3 {
            font-size: 24px;
            margin-bottom: 12px;
            font-weight: 600;
            color: #1d1d1f;
        }
        
        .empty-state p {
            color: #6e6e73;
            font-size: 16px;
        }
        
        /* Modal */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(10px);
        }
        
        .modal-content {
            background: #ffffff;
            margin: 10% auto;
            padding: 32px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 20px;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }
        
        .modal-header h2 {
            font-size: 24px;
            font-weight: 700;
            color: #1d1d1f;
        }
        
        .close {
            font-size: 32px;
            font-weight: 300;
            color: #6e6e73;
            cursor: pointer;
            transition: all 0.2s ease;
            line-height: 1;
        }
        
        .close:hover {
            color: #1d1d1f;
        }
        
        .form-group {
            margin-bottom: 24px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 10px;
            color: #1d1d1f;
            font-size: 15px;
            font-weight: 600;
        }
        
        .form-group textarea {
            width: 100%;
            padding: 14px 16px;
            background: #f5f5f7;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 12px;
            color: #1d1d1f;
            font-size: 15px;
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            min-height: 120px;
            resize: vertical;
        }
        
        .form-group textarea:focus {
            outline: none;
            border-color: #000000;
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(0, 0, 0, 0.06);
        }
        
        .form-group textarea::placeholder {
            color: #6e6e73;
        }
        
        /* Stats - For HR */
        .stats-bar {
            display: flex;
            gap: 16px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            flex: 1;
            background: #ffffff;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
        }
        
        .stat-number {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 4px;
            color: #1d1d1f;
        }
        
        .stat-label {
            font-size: 13px;
            color: #6e6e73;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: 600;
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
        <a href="${pageContext.request.contextPath}/home" class="btn-back">
            ← Quay lại
        </a>
        
        <div class="page-header">
            <h1>Duyệt đơn nghỉ phép</h1>
            <% if (isHRManager != null && isHRManager) { %>
                <p>Quản lý tất cả đơn nghỉ phép đang chờ xét duyệt</p>
            <% } else if (isDivisionLeader != null && isDivisionLeader) { %>
                <p>Xét duyệt đơn nghỉ phép của phòng ban <%= userDivisionName %></p>
            <% } else { %>
                <p>Xét duyệt các đơn nghỉ phép đang chờ xử lý</p>
            <% } %>
        </div>
        
        <% 
        String success = (String) session.getAttribute("success");
        String error = (String) session.getAttribute("error");
        if (success != null) { 
            session.removeAttribute("success");
        %>
            <div class="alert alert-success">
                ✓ <%= success %>
            </div>
        <% } %>
        
        <% if (error != null) { 
            session.removeAttribute("error");
        %>
            <div class="alert alert-error">
                ✕ <%= error %>
            </div>
        <% } %>
        
        <% if (isDivisionLeader != null && isDivisionLeader) { %>
            <div class="division-badge">
                🏢 Phòng ban: <strong><%= userDivisionName %></strong>
            </div>
        <% } %>
        
        <% if (isHRManager != null && isHRManager && allDivisions != null) { %>
            <!-- HR Manager Filter Section -->
            <form method="get" action="${pageContext.request.contextPath}/request/pending" id="filterForm">
                <div class="filter-section">
                    <div class="filter-header">
                        <h3>Lọc theo phòng ban</h3>
                    </div>
                    
                    <div class="filter-grid">
                        <% for (Division div : allDivisions) { 
                            boolean isSelected = false;
                            if (selectedDivisions != null) {
                                for (String selId : selectedDivisions) {
                                    if (String.valueOf(div.getDivisionID()).equals(selId)) {
                                        isSelected = true;
                                        break;
                                    }
                                }
                            }
                        %>
                            <div class="filter-checkbox">
                                <input type="checkbox" 
                                       name="divisionIDs" 
                                       value="<%= div.getDivisionID() %>" 
                                       id="div<%= div.getDivisionID() %>"
                                       <%= isSelected ? "checked" : "" %>>
                                <label for="div<%= div.getDivisionID() %>">
                                    <%= div.getDivisionName() %>
                                </label>
                            </div>
                        <% } %>
                    </div>
                    
                    <div class="filter-actions">
                        <button type="submit" class="btn-filter btn-apply">Áp dụng</button>
                        <button type="button" class="btn-filter btn-reset" onclick="resetFilter()">
                            Xóa bộ lọc
                        </button>
                    </div>
                </div>
            </form>
            
            <!-- Stats Bar -->
            <div class="stats-bar">
                <div class="stat-card">
                    <div class="stat-number"><%= pendingRequests != null ? pendingRequests.size() : 0 %></div>
                    <div class="stat-label">Đơn chờ duyệt</div>
                </div>
            </div>
        <% } %>
        
        <% if (pendingRequests != null && !pendingRequests.isEmpty()) { %>
            <div class="requests-grid">
                <% for (LeaveRequest req : pendingRequests) { %>
                    <div class="request-card">
                        <div class="request-header">
                            <div class="employee-info">
                                <div class="employee-avatar">
                                    <%= req.getEmployeeName() != null ? req.getEmployeeName().substring(0, 1).toUpperCase() : "?" %>
                                </div>
                                <div class="employee-details">
                                    <h3><%= req.getEmployeeName() %></h3>
                                    <p><%= req.getLeaveTypeName() %></p>
                                </div>
                            </div>
                            <div class="request-badges">
                                <div class="request-badge">
                                    ⏱ Đang chờ
                                </div>
                                <% if (req.getDivisionName() != null && isHRManager != null && isHRManager) { %>
                                    <div class="division-label">
                                        <%= req.getDivisionName() %>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                        
                        <div class="request-body">
                            <div class="info-item">
                                <span class="info-label">Từ ngày</span>
                                <span class="info-value">
                                    <%= req.getStartDate().format(dateFormatter) %>
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Đến ngày</span>
                                <span class="info-value">
                                    <%= req.getEndDate().format(dateFormatter) %>
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Số ngày</span>
                                <span class="info-value">
                                    <%= req.getTotalDays() %> ngày
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Ngày tạo</span>
                                <span class="info-value">
                                    <%= req.getCreatedAt() != null ? req.getCreatedAt().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")) : "N/A" %>
                                </span>
                            </div>
                        </div>
                        
                        <% if (req.getReason() != null && !req.getReason().trim().isEmpty()) { %>
                            <div class="reason-box">
                                <h4>Lý do</h4>
                                <p><%= req.getReason() %></p>
                            </div>
                        <% } %>
                        
                        <div class="action-buttons">
                            <button class="btn btn-approve" onclick="showModal(<%= req.getRequestID() %>, 'APPROVE')">
                                ✓ Duyệt
                            </button>
                            <button class="btn btn-reject" onclick="showModal(<%= req.getRequestID() %>, 'REJECT')">
                                ✕ Từ chối
                            </button>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="empty-state">
                <div class="empty-state-icon">✓</div>
                <h3>Không có đơn nào cần duyệt</h3>
                <p>Tất cả đơn nghỉ phép đã được xử lý xong</p>
            </div>
        <% } %>
    </div>

    <!-- Modal -->
    <div id="processModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="modalTitle">Xác nhận</h2>
                <span class="close" onclick="closeModal()">&times;</span>
            </div>
            <form id="processForm" method="post" action="${pageContext.request.contextPath}/request/process">
                <input type="hidden" name="requestID" id="modalRequestID">
                <input type="hidden" name="action" id="modalAction">
                
                <div class="form-group">
                    <label for="note">Ghi chú</label>
                    <textarea name="note" id="note" placeholder="Nhập ghi chú (không bắt buộc)..."></textarea>
                </div>
                
                <div class="action-buttons">
                    <button type="submit" class="btn btn-approve" id="modalSubmitBtn">
                        ✓ Xác nhận
                    </button>
                    <button type="button" class="btn btn-reject" onclick="closeModal()">
                        ✕ Hủy
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function showModal(requestID, action) {
            document.getElementById('modalRequestID').value = requestID;
            document.getElementById('modalAction').value = action;
            
            if (action === 'APPROVE') {
                document.getElementById('modalTitle').innerHTML = 'Duyệt đơn';
                document.getElementById('modalSubmitBtn').className = 'btn btn-approve';
                document.getElementById('modalSubmitBtn').innerHTML = '✓ Duyệt đơn';
            } else {
                document.getElementById('modalTitle').innerHTML = 'Từ chối đơn';
                document.getElementById('modalSubmitBtn').className = 'btn btn-reject';
                document.getElementById('modalSubmitBtn').innerHTML = '✕ Từ chối đơn';
            }
            
            document.getElementById('processModal').style.display = 'block';
        }
        
        function closeModal() {
            document.getElementById('processModal').style.display = 'none';
            document.getElementById('note').value = '';
        }
        
        function resetFilter() {
            window.location.href = '${pageContext.request.contextPath}/request/pending';
        }
        
        window.onclick = function(event) {
            const modal = document.getElementById('processModal');
            if (event.target == modal) {
                closeModal();
            }
        }
    </script>
</body>
</html>