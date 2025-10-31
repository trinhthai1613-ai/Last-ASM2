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
        }
        
        .navbar {
            background: rgba(10, 14, 39, 0.95);
            backdrop-filter: blur(20px);
            padding: 20px 0;
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.3);
            border-bottom: 1px solid rgba(99, 102, 241, 0.2);
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
            gap: 15px;
            font-size: 24px;
            font-weight: 700;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-decoration: none;
        }
        
        .main-container {
            max-width: 1400px;
            margin: 40px auto;
            padding: 0 30px;
        }
        
        .page-header {
            background: rgba(10, 14, 39, 0.7);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 30px 40px;
            border: 1px solid rgba(99, 102, 241, 0.2);
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
            margin-bottom: 30px;
        }
        
        h1 {
            font-size: 32px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        .btn-back {
            display: inline-block;
            padding: 10px 20px;
            background: rgba(99, 102, 241, 0.2);
            border: 1px solid rgba(99, 102, 241, 0.3);
            border-radius: 10px;
            color: #cbd5e1;
            text-decoration: none;
            margin-bottom: 20px;
            transition: all 0.3s ease;
        }
        
        .btn-back:hover {
            background: rgba(99, 102, 241, 0.3);
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 20px;
        }
        
        .alert-success {
            background: rgba(34, 197, 94, 0.2);
            border: 1px solid rgba(34, 197, 94, 0.5);
            color: #86efac;
        }
        
        .alert-error {
            background: rgba(239, 68, 68, 0.2);
            border: 1px solid rgba(239, 68, 68, 0.5);
            color: #fca5a5;
        }
        
        .requests-grid {
            display: grid;
            gap: 20px;
        }
        
        .request-card {
            background: rgba(10, 14, 39, 0.7);
            backdrop-filter: blur(20px);
            border-radius: 15px;
            padding: 25px;
            border: 1px solid rgba(99, 102, 241, 0.2);
            transition: all 0.3s ease;
        }
        
        .request-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
        }
        
        .request-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid rgba(99, 102, 241, 0.2);
        }
        
        .employee-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .employee-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 20px;
        }
        
        .employee-details h3 {
            font-size: 18px;
            margin-bottom: 5px;
        }
        
        .employee-details p {
            font-size: 14px;
            color: #94a3b8;
        }
        
        .request-badge {
            padding: 6px 12px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 600;
            background: rgba(251, 191, 36, 0.2);
            color: #fbbf24;
            border: 1px solid rgba(251, 191, 36, 0.3);
        }
        
        .request-body {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .info-item {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        
        .info-label {
            font-size: 13px;
            color: #94a3b8;
        }
        
        .info-value {
            font-size: 15px;
            font-weight: 600;
            color: #e2e8f0;
        }
        
        .reason-box {
            background: rgba(59, 130, 246, 0.1);
            border: 1px solid rgba(59, 130, 246, 0.3);
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 20px;
        }
        
        .reason-box h4 {
            font-size: 14px;
            color: #93c5fd;
            margin-bottom: 8px;
        }
        
        .reason-box p {
            font-size: 14px;
            line-height: 1.6;
            color: #cbd5e1;
        }
        
        .action-buttons {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }
        
        .btn {
            padding: 12px 20px;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            font-family: 'Be Vietnam Pro', sans-serif;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        
        .btn-approve {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: #fff;
            box-shadow: 0 5px 15px rgba(16, 185, 129, 0.3);
        }
        
        .btn-approve:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(16, 185, 129, 0.4);
        }
        
        .btn-reject {
            background: rgba(239, 68, 68, 0.2);
            border: 1px solid rgba(239, 68, 68, 0.5);
            color: #fca5a5;
        }
        
        .btn-reject:hover {
            background: rgba(239, 68, 68, 0.3);
            transform: translateY(-2px);
        }
        
        .btn-view {
            background: rgba(99, 102, 241, 0.2);
            border: 1px solid rgba(99, 102, 241, 0.5);
            color: #a5b4fc;
        }
        
        .btn-view:hover {
            background: rgba(99, 102, 241, 0.3);
        }
        
        .empty-state {
            background: rgba(10, 14, 39, 0.7);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 60px 40px;
            border: 1px solid rgba(99, 102, 241, 0.2);
            text-align: center;
        }
        
        .empty-state i {
            font-size: 64px;
            color: #667eea;
            margin-bottom: 20px;
        }
        
        .empty-state h3 {
            font-size: 24px;
            margin-bottom: 10px;
            color: #e2e8f0;
        }
        
        .empty-state p {
            color: #94a3b8;
            font-size: 16px;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.7);
            backdrop-filter: blur(5px);
        }
        
        .modal-content {
            background: rgba(10, 14, 39, 0.95);
            margin: 10% auto;
            padding: 30px;
            border: 1px solid rgba(99, 102, 241, 0.3);
            border-radius: 20px;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
        }
        
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .modal-header h2 {
            font-size: 24px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        .close {
            font-size: 28px;
            font-weight: bold;
            color: #94a3b8;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .close:hover {
            color: #667eea;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #cbd5e1;
            font-size: 14px;
            font-weight: 500;
        }
        
        .form-group textarea {
            width: 100%;
            padding: 13px 18px;
            background: rgba(15, 23, 42, 0.6);
            border: 2px solid rgba(99, 102, 241, 0.3);
            border-radius: 12px;
            color: #fff;
            font-size: 14px;
            font-family: 'Be Vietnam Pro', sans-serif;
            min-height: 120px;
            resize: vertical;
        }
        
        .form-group textarea:focus {
            outline: none;
            border-color: #667eea;
            background: rgba(15, 23, 42, 0.8);
        }
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
        <a href="${pageContext.request.contextPath}/home" class="btn-back">
            <i class="fas fa-arrow-left"></i> Quay lại
        </a>
        
        <div class="page-header">
            <h1><i class="fas fa-tasks"></i> Duyệt đơn nghỉ phép</h1>
            <p style="color: #94a3b8; margin-top: 10px;">Xét duyệt các đơn nghỉ phép đang chờ xử lý</p>
        </div>
        
        <% 
        String success = (String) session.getAttribute("success");
        String error = (String) session.getAttribute("error");
        if (success != null) { 
            session.removeAttribute("success");
        %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <%= success %>
            </div>
        <% } %>
        
        <% if (error != null) { 
            session.removeAttribute("error");
        %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <%= error %>
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
                                <i class="fas fa-clock"></i> Đang chờ
                            </div>
                        </div>
                        
                        <div class="request-body">
                            <div class="info-item">
                                <span class="info-label">Từ ngày</span>
                                <span class="info-value">
                                    <i class="fas fa-calendar"></i> 
                                    <%= req.getStartDate().format(dateFormatter) %>
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Đến ngày</span>
                                <span class="info-value">
                                    <i class="fas fa-calendar"></i> 
                                    <%= req.getEndDate().format(dateFormatter) %>
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Số ngày</span>
                                <span class="info-value">
                                    <i class="fas fa-hourglass-half"></i> 
                                    <%= req.getTotalDays() %> ngày
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Ngày tạo</span>
                                <span class="info-value">
                                    <i class="fas fa-clock"></i> 
                                    <%= req.getCreatedAt() != null ? req.getCreatedAt().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) : "N/A" %>
                                </span>
                            </div>
                        </div>
                        
                        <% if (req.getReason() != null && !req.getReason().trim().isEmpty()) { %>
                            <div class="reason-box">
                                <h4><i class="fas fa-comment-dots"></i> Lý do</h4>
                                <p><%= req.getReason() %></p>
                            </div>
                        <% } %>
                        
                        <div class="action-buttons">
                            <button class="btn btn-approve" onclick="showModal(<%= req.getRequestID() %>, 'APPROVE')">
                                <i class="fas fa-check"></i> Duyệt
                            </button>
                            <button class="btn btn-reject" onclick="showModal(<%= req.getRequestID() %>, 'REJECT')">
                                <i class="fas fa-times"></i> Từ chối
                            </button>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="empty-state">
                <i class="fas fa-check-double"></i>
                <h3>Không có đơn nào cần duyệt</h3>
                <p>Tất cả đơn nghỉ phép đã được xử lý xong</p>
            </div>
        <% } %>
    </div>

    <!-- Modal for confirmation -->
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
                        <i class="fas fa-check"></i> Xác nhận
                    </button>
                    <button type="button" class="btn btn-reject" onclick="closeModal()">
                        <i class="fas fa-times"></i> Hủy
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
                document.getElementById('modalTitle').innerHTML = '<i class="fas fa-check-circle"></i> Duyệt đơn';
                document.getElementById('modalSubmitBtn').className = 'btn btn-approve';
                document.getElementById('modalSubmitBtn').innerHTML = '<i class="fas fa-check"></i> Duyệt đơn';
            } else {
                document.getElementById('modalTitle').innerHTML = '<i class="fas fa-times-circle"></i> Từ chối đơn';
                document.getElementById('modalSubmitBtn').className = 'btn btn-reject';
                document.getElementById('modalSubmitBtn').innerHTML = '<i class="fas fa-times"></i> Từ chối đơn';
            }
            
            document.getElementById('processModal').style.display = 'block';
        }
        
        function closeModal() {
            document.getElementById('processModal').style.display = 'none';
            document.getElementById('note').value = '';
        }
        
        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('processModal');
            if (event.target == modal) {
                closeModal();
            }
        }
    </script>
</body>
</html>
