<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.*" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    Employee user = (Employee) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    LeaveRequest req = (LeaveRequest) request.getAttribute("leaveRequest");
    if (req == null) {
        response.sendRedirect(request.getContextPath() + "/request/list");
        return;
    }
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết đơn nghỉ phép</title>
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
        .main-container { max-width: 900px; margin: 40px auto; padding: 0 30px; }
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
        
        .detail-card {
            background: rgba(10, 14, 39, 0.7); backdrop-filter: blur(20px);
            border-radius: 20px; padding: 40px;
            border: 1px solid rgba(99, 102, 241, 0.2);
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
        }
        .status-badge {
            display: inline-block; padding: 8px 20px;
            border-radius: 20px; font-size: 14px; font-weight: 600;
            margin-bottom: 30px;
        }
        .status-inprogress { background: rgba(251, 191, 36, 0.2); color: #fbbf24; }
        .status-approved { background: rgba(34, 197, 94, 0.2); color: #22c55e; }
        .status-rejected { background: rgba(239, 68, 68, 0.2); color: #ef4444; }
        
        .info-section {
            margin-bottom: 30px; padding-bottom: 30px;
            border-bottom: 1px solid rgba(99, 102, 241, 0.2);
        }
        .info-section:last-child { border-bottom: none; }
        .section-title {
            font-size: 18px; font-weight: 600; color: #667eea;
            margin-bottom: 20px; display: flex; align-items: center; gap: 10px;
        }
        .info-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        .info-item { display: flex; flex-direction: column; gap: 8px; }
        .info-label { font-size: 13px; color: #94a3b8; }
        .info-value {
            font-size: 16px; font-weight: 600; color: #e2e8f0;
        }
        .reason-box {
            background: rgba(59, 130, 246, 0.1);
            border: 1px solid rgba(59, 130, 246, 0.3);
            border-radius: 12px; padding: 20px; line-height: 1.8;
        }
        .note-box {
            background: rgba(251, 191, 36, 0.1);
            border: 1px solid rgba(251, 191, 36, 0.3);
            border-radius: 12px; padding: 20px; line-height: 1.8;
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
        <div class="page-header">
            <h1><i class="fas fa-file-alt"></i> Chi tiết đơn nghỉ phép</h1>
            <a href="${pageContext.request.contextPath}/request/list" class="btn-back">
                <i class="fas fa-arrow-left"></i> Quay lại
            </a>
        </div>

        <div class="detail-card">
            <!-- Status Badge -->
            <% 
                String statusClass = "status-inprogress";
                if ("Approved".equals(req.getStatus())) statusClass = "status-approved";
                else if ("Rejected".equals(req.getStatus())) statusClass = "status-rejected";
            %>
            <span class="status-badge <%= statusClass %>">
                <i class="fas fa-circle"></i> <%= req.getStatusDisplay() %>
            </span>

            <!-- Thông tin cơ bản -->
            <div class="info-section">
                <div class="section-title">
                    <i class="fas fa-info-circle"></i> Thông tin cơ bản
                </div>
                <div class="info-grid">
                    <div class="info-item">
                        <span class="info-label">Mã đơn</span>
                        <span class="info-value"><%= req.getRequestCode() %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Loại nghỉ phép</span>
                        <span class="info-value"><%= req.getLeaveTypeName() %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Ngày tạo</span>
                        <span class="info-value">
                            <%= req.getCreatedAt() != null ? req.getCreatedAt().format(dateTimeFormatter) : "N/A" %>
                        </span>
                    </div>
                </div>
            </div>

            <!-- Thời gian nghỉ -->
            <div class="info-section">
                <div class="section-title">
                    <i class="fas fa-calendar-alt"></i> Thời gian nghỉ
                </div>
                <div class="info-grid">
                    <div class="info-item">
                        <span class="info-label">Từ ngày</span>
                        <span class="info-value">
                            <i class="fas fa-calendar"></i> <%= req.getStartDate().format(dateFormatter) %>
                        </span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Đến ngày</span>
                        <span class="info-value">
                            <i class="fas fa-calendar"></i> <%= req.getEndDate().format(dateFormatter) %>
                        </span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Tổng số ngày</span>
                        <span class="info-value">
                            <i class="fas fa-hourglass-half"></i> <%= req.getTotalDays() %> ngày
                        </span>
                    </div>
                </div>
            </div>

            <!-- Lý do -->
            <div class="info-section">
                <div class="section-title">
                    <i class="fas fa-comment-dots"></i> Lý do nghỉ phép
                </div>
                <div class="reason-box">
                    <%= req.getReason() != null ? req.getReason() : "Không có lý do" %>
                </div>
            </div>

            <!-- Thông tin xử lý (nếu đã được duyệt/từ chối) -->
            <% if (req.getProcessedBy() != null) { %>
            <div class="info-section">
                <div class="section-title">
                    <i class="fas fa-user-check"></i> Thông tin xử lý
                </div>
                <div class="info-grid">
                    <div class="info-item">
                        <span class="info-label">Người xử lý</span>
                        <span class="info-value"><%= req.getProcessedByName() %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Ngày xử lý</span>
                        <span class="info-value">
                            <%= req.getProcessedDate() != null ? req.getProcessedDate().format(dateTimeFormatter) : "N/A" %>
                        </span>
                    </div>
                </div>
                
                <% if (req.getProcessedNote() != null && !req.getProcessedNote().isEmpty()) { %>
                <div style="margin-top: 20px;">
                    <span class="info-label">Ghi chú từ người duyệt:</span>
                    <div class="note-box">
                        <%= req.getProcessedNote() %>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>

            <!-- File đính kèm (nếu có) -->
            <% if (req.getAttachmentPath() != null && !req.getAttachmentPath().isEmpty()) { %>
            <div class="info-section">
                <div class="section-title">
                    <i class="fas fa-paperclip"></i> File đính kèm
                </div>
                <a href="${pageContext.request.contextPath}/uploads/<%= req.getAttachmentPath() %>" 
                   target="_blank" class="btn-back" style="display: inline-block;">
                    <i class="fas fa-download"></i> Tải xuống
                </a>
            </div>
            <% } %>
        </div>
    </div>
</body>
</html>