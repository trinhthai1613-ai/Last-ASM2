<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.Employee" %>
<%@ page import="com.company.lms.model.LeaveRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    Employee user = (Employee) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<LeaveRequest> pendingRequests = (List<LeaveRequest>) request.getAttribute("pendingRequests");
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
        .main-container {
            max-width: 1400px;
            margin: 40px auto;
            padding: 0 30px;
        }
        .page-header {
            background: #f5f5f7;
            border-radius: 18px;
            padding: 30px 40px;
            border: 1px solid rgba(0, 0, 0, 0.1);
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
            margin-bottom: 20px;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            font-size: 14px;
            font-weight: 500;
        }
        .btn-back:hover { background: #e8e8ed; }
        .alert {
            padding: 12px 16px;
            border-radius: 12px;
            margin-bottom: 20px;
        }
        .alert-success {
            background: rgba(52, 199, 89, 0.1);
            border: 1px solid rgba(52, 199, 89, 0.3);
            color: #34c759;
        }
        .alert-error {
            background: rgba(255, 59, 48, 0.1);
            border: 1px solid rgba(255, 59, 48, 0.3);
            color: #ff3b30;
        }
        .requests-grid {
            display: grid;
            gap: 20px;
        }
        .request-card {
            background: #ffffff;
            border-radius: 18px;
            padding: 28px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }
        .request-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
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
            gap: 15px;
        }
        .employee-avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: #000000;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 18px;
            color: #fff;
        }
        .employee-details h3 {
            font-size: 17px;
            margin-bottom: 4px;
            font-weight: 600;
        }
        .employee-details p {
            font-size: 14px;
            color: #6e6e73;
        }
        .request-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            background: rgba(255, 149, 0, 0.15);
            color: #ff9500;
        }
        .request-body {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 16px;
            margin-bottom: 20px;
        }
        .info-item {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .info-label {
            font-size: 12px;
            color: #6e6e73;
        }
        .info-value {
            font-size: 14px;
            font-weight: 500;
            color: #1d1d1f;
        }
        .reason-box {
            background: #f5f5f7;
            border-radius: 12px;
            padding: 16px;
            margin-bottom: 20px;
        }
        .reason-box h4 {
            font-size: 13px;
            color: #6e6e73;
            margin-bottom: 8px;
            font-weight: 500;
        }
        .reason-box p {
            font-size: 14px;
            line-height: 1.6;
            color: #1d1d1f;
        }
        .action-buttons {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 980px;
            font-size: 14px;
            font-weight: 500;
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            letter-spacing: -0.01em;
        }
        .btn-approve {
            background: #34c759;
            color: #fff;
        }
        .btn-approve:hover {
            transform: scale(1.02);
            box-shadow: 0 4px 12px rgba(52, 199, 89, 0.3);
        }
        .btn-reject {
            background: #f5f5f7;
            border: 1px solid rgba(0, 0, 0, 0.1);
            color: #1d1d1f;
        }
        .btn-reject:hover {
            background: #e8e8ed;
        }
        .empty-state {
            background: #ffffff;
            border-radius: 18px;
            padding: 60px 40px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        .empty-state i {
            font-size: 64px;
            color: #000000;
            margin-bottom: 20px;
        }
        .empty-state h3 {
            font-size: 22px;
            margin-bottom: 10px;
            color: #1d1d1f;
            font-weight: 600;
        }
        .empty-state p {
            color: #6e6e73;
            font-size: 15px;
        }
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
            padding: 30px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 18px;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .modal-header h2 {
            font-size: 22px;
            font-weight: 600;
            letter-spacing: -0.02em;
        }
        .close {
            font-size: 28px;
            font-weight: bold;
            color: #6e6e73;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .close:hover {
            color: #000000;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #1d1d1f;
            font-size: 14px;
            font-weight: 500;
        }
        .form-group textarea {
            width: 100%;
            padding: 12px 16px;
            background: #f5f5f7;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 12px;
            color: #1d1d1f;
            font-size: 14px;
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
        <a href="${pageContext.request.contextPath}/home" class="btn-back">
            ← Quay lại
        </a>
        
        <div class="page-header">
            <h1>✅ Duyệt đơn nghỉ phép</h1>
            <p style="color: #6e6e73; margin-top: 8px;">Xét duyệt các đơn nghỉ phép đang chờ xử lý</p>
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
                            <div class="request-badge">
                                ⏱ Đang chờ
                            </div>
                        </div>
                        
                        <div class="request-body">
                            <div class="info-item">
                                <span class="info-label">Từ ngày</span>
                                <span class="info-value">
                                    📅 <%= req.getStartDate().format(dateFormatter) %>
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Đến ngày</span>
                                <span class="info-value">
                                    📅 <%= req.getEndDate().format(dateFormatter) %>
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Số ngày</span>
                                <span class="info-value">
                                    ⏳ <%= req.getTotalDays() %> ngày
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Ngày tạo</span>
                                <span class="info-value">
                                    🕐 <%= req.getCreatedAt() != null ? req.getCreatedAt().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) : "N/A" %>
                                </span>
                            </div>
                        </div>
                        
                        <% if (req.getReason() != null && !req.getReason().trim().isEmpty()) { %>
                            <div class="reason-box">
                                <h4>💬 Lý do</h4>
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
                <div style="font-size: 64px; margin-bottom: 20px;">✅</div>
                <h3>Không có đơn nào cần duyệt</h3>
                <p>Tất cả đơn nghỉ phép đã được xử lý xong</p>
            </div>
        <% } %>
    </div>

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
                document.getElementById('modalTitle').innerHTML = '✓ Duyệt đơn';
                document.getElementById('modalSubmitBtn').className = 'btn btn-approve';
                document.getElementById('modalSubmitBtn').innerHTML = '✓ Duyệt đơn';
            } else {
                document.getElementById('modalTitle').innerHTML = '✕ Từ chối đơn';
                document.getElementById('modalSubmitBtn').className = 'btn btn-reject';
                document.getElementById('modalSubmitBtn').innerHTML = '✕ Từ chối đơn';
            }
            
            document.getElementById('processModal').style.display = 'block';
        }
        
        function closeModal() {
            document.getElementById('processModal').style.display = 'none';
            document.getElementById('note').value = '';
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