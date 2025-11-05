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
        .main-container { max-width: 900px; margin: 40px auto; padding: 0 30px; }
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
            display: inline-block;
            padding: 8px 18px;
            background: #f5f5f7;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 980px;
            color: #1d1d1f;
            text-decoration: none;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            font-size: 14px;
            font-weight: 500;
        }
        .btn-back:hover { background: #e8e8ed; }
        
        .detail-card {
            background: #ffffff;
            border-radius: 18px;
            padding: 40px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            box-shadow: 0 2px 16px rgba(0, 0, 0, 0.08);
        }
        .status-badge {
            display: inline-block;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 30px;
        }
        .status-inprogress { background: rgba(255, 149, 0, 0.15); color: #ff9500; }
        .status-approved { background: rgba(52, 199, 89, 0.15); color: #34c759; }
        .status-rejected { background: rgba(255, 59, 48, 0.15); color: #ff3b30; }
        
        .info-section {
            margin-bottom: 30px;
            padding-bottom: 30px;
            border-bottom: 1px solid rgba(0, 0, 0, 0.1);
        }
        .info-section:last-child { border-bottom: none; }
        .section-title {
            font-size: 17px;
            font-weight: 600;
            color: #000000;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        .info-item { display: flex; flex-direction: column; gap: 6px; }
        .info-label { font-size: 12px; color: #6e6e73; }
        .info-value {
            font-size: 15px;
            font-weight: 500;
            color: #1d1d1f;
        }
        .reason-box {
            background: #f5f5f7;
            border-radius: 12px;
            padding: 20px;
            line-height: 1.8;
        }
        .note-box {
            background: rgba(255, 149, 0, 0.1);
            border: 1px solid rgba(255, 149, 0, 0.3);
            border-radius: 12px;
            padding: 20px;
            line-height: 1.8;
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
        <div class="page-header">
            <h1>📄 Chi tiết đơn nghỉ phép</h1>
            <a href="${pageContext.request.contextPath}/request/list" class="btn-back">
                ← Quay lại
            </a>
        </div>

        <div class="detail-card">
            <% 
                String statusClass = "status-inprogress";
                if ("Approved".equals(req.getStatus())) statusClass = "status-approved";
                else if ("Rejected".equals(req.getStatus())) statusClass = "status-rejected";
            %>
            <span class="status-badge <%= statusClass %>">
                ● <%= req.getStatusDisplay() %>
            </span>

            <div class="info-section">
                <div class="section-title">
                    ℹ️ Thông tin cơ bản
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

            <div class="info-section">
                <div class="section-title">
                    📅 Thời gian nghỉ
                </div>
                <div class="info-grid">
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
                        <span class="info-label">Tổng số ngày</span>
                        <span class="info-value">
                            <%= req.getTotalDays() %> ngày
                        </span>
                    </div>
                </div>
            </div>

            <div class="info-section">
                <div class="section-title">
                    💬 Lý do nghỉ phép
                </div>
                <div class="reason-box">
                    <%= req.getReason() != null ? req.getReason() : "Không có lý do" %>
                </div>
            </div>

            <% if (req.getProcessedBy() != null) { %>
            <div class="info-section">
                <div class="section-title">
                    ✅ Thông tin xử lý
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

            <% if (req.getAttachmentPath() != null && !req.getAttachmentPath().isEmpty()) { %>
            <div class="info-section">
                <div class="section-title">
                    📎 File đính kèm
                </div>
                <a href="${pageContext.request.contextPath}/uploads/<%= req.getAttachmentPath() %>" 
                   target="_blank" class="btn-back" style="display: inline-block;">
                    ⬇️ Tải xuống
                </a>
            </div>
            <% } %>
        </div>
    </div>
</body>
</html>