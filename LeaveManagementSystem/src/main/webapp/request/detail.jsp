<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.*" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.Duration" %>
<%@ page import="java.util.List" %>
<%@ page import="com.company.lms.dao.*" %>
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
    
    long minutesPassed = Duration.between(req.getCreatedAt(), java.time.LocalDateTime.now()).toMinutes();
    boolean canEditTime = minutesPassed <= 60;
    
    RoleDAO roleDAO = new RoleDAO();
    int roleLevel = roleDAO.getHighestRoleLevel(user.getEmployeeID());
    
    boolean isManager = (roleLevel <= 2);
    boolean isOwner = (req.getEmployeeID() == user.getEmployeeID());
    boolean canEditAsEmployee = (isOwner && "InProgress".equals(req.getStatus()) && canEditTime);
    boolean canEditAsManager = (isManager && canEditTime);
    
    List<LeaveReasonTemplate> templates = null;
    if (canEditAsEmployee) {
        LeaveRequestDAO lrDAO = new LeaveRequestDAO();
        templates = lrDAO.getTemplatesByLeaveType(req.getLeaveTypeID());
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
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
            background: #ffffff;
            color: #1d1d1f;
            -webkit-font-smoothing: antialiased;
        }
        .navbar {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(20px);
            padding: 16px 0;
            box-shadow: 0 1px 0 rgba(0, 0, 0, 0.05);
            position: sticky;
            top: 0;
            z-index: 100;
        }
        .nav-container { max-width: 1000px; margin: 0 auto; padding: 0 30px; }
        .logo { 
            font-size: 22px; 
            font-weight: 600; 
            color: #000; 
            text-decoration: none;
            letter-spacing: -0.5px;
        }
        .main-container { max-width: 800px; margin: 40px auto; padding: 0 30px; }
        .page-header { 
            margin-bottom: 32px;
        }
        h1 { 
            font-size: 34px; 
            font-weight: 700;
            letter-spacing: -0.5px;
            margin-bottom: 16px;
        }
        .header-actions {
            display: flex;
            gap: 12px;
        }
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
            border: none;
        }
        .btn-back {
            background: #f5f5f7;
            color: #1d1d1f;
        }
        .btn-back:hover { background: #e8e8ed; transform: translateY(-1px); }
        .btn-edit {
            background: #007aff;
            color: #fff;
        }
        .btn-edit:hover { background: #0051d5; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3); }
        .btn-primary {
            background: #000;
            color: #fff;
            padding: 12px 24px;
            font-size: 16px;
        }
        .btn-primary:hover { background: #1d1d1f; transform: translateY(-1px); }
        
        .card {
            background: #fff;
            border-radius: 20px;
            padding: 32px;
            margin-bottom: 24px;
            border: 1px solid rgba(0, 0, 0, 0.06);
            box-shadow: 0 2px 20px rgba(0, 0, 0, 0.04);
        }
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 16px;
            border-radius: 24px;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 24px;
        }
        .status-inprogress { background: rgba(255, 149, 0, 0.12); color: #ff9500; }
        .status-approved { background: rgba(52, 199, 89, 0.12); color: #34c759; }
        .status-rejected { background: rgba(255, 59, 48, 0.12); color: #ff3b30; }
        
        .info-section {
            margin-bottom: 32px;
            padding-bottom: 32px;
            border-bottom: 1px solid rgba(0, 0, 0, 0.06);
        }
        .info-section:last-child { border-bottom: none; }
        .section-title { 
            font-size: 20px; 
            font-weight: 600; 
            margin-bottom: 20px;
            letter-spacing: -0.3px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 24px;
        }
        .info-item { display: flex; flex-direction: column; gap: 8px; }
        .info-label { font-size: 13px; color: #86868b; font-weight: 500; }
        .info-value { font-size: 17px; font-weight: 600; color: #1d1d1f; }
        .reason-box {
            background: #f5f5f7;
            border-radius: 16px;
            padding: 20px;
            line-height: 1.6;
            font-size: 15px;
        }
        
        .form-group { margin-bottom: 24px; }
        .form-group label { 
            display: block; 
            margin-bottom: 10px; 
            font-weight: 600;
            font-size: 15px;
        }
        .form-control, .form-select {
            width: 100%;
            padding: 14px 16px;
            border: 1px solid rgba(0,0,0,0.1);
            border-radius: 12px;
            font-size: 15px;
            transition: all 0.2s ease;
            background: #fff;
        }
        .form-control:focus, .form-select:focus {
            outline: none;
            border-color: #007aff;
            box-shadow: 0 0 0 4px rgba(0, 122, 255, 0.1);
        }
        textarea.form-control { 
            min-height: 120px; 
            resize: vertical;
            font-family: inherit;
        }
        
        .alert {
            padding: 16px 20px;
            border-radius: 12px;
            margin-bottom: 24px;
            font-weight: 500;
        }
        .alert-success { 
            background: rgba(52,199,89,0.1); 
            border: 1px solid rgba(52,199,89,0.2); 
            color: #34c759; 
        }
        .alert-error { 
            background: rgba(255,59,48,0.1); 
            border: 1px solid rgba(255,59,48,0.2); 
            color: #ff3b30; 
        }
        .time-warning {
            background: rgba(255,149,0,0.1);
            border: 1px solid rgba(255,149,0,0.2);
            border-radius: 12px;
            padding: 16px 20px;
            color: #ff9500;
            font-size: 14px;
            margin-bottom: 24px;
            font-weight: 500;
        }
        
        #editFormEmployee, #editFormManager { display: none; }
        
        .form-actions {
            display: flex;
            gap: 12px;
            margin-top: 32px;
        }
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
            <h1>📄 Chi tiết đơn nghỉ phép</h1>
            <div class="header-actions">
                <a href="javascript:history.back()" class="btn btn-back">← Quay lại</a>
                <% if (canEditAsEmployee) { %>
                    <button onclick="toggleEmployeeEdit()" class="btn btn-edit" id="btnEditEmployee">✏️ Sửa đơn</button>
                <% } else if (canEditAsManager && !isOwner) { %>
                    <button onclick="toggleManagerEdit()" class="btn btn-edit" id="btnEditManager">🔄 Đổi trạng thái</button>
                <% } %>
            </div>
        </div>

        <% if (session.getAttribute("success") != null) { %>
            <div class="alert alert-success"><%= session.getAttribute("success") %></div>
            <% session.removeAttribute("success"); %>
        <% } %>
        <% if (session.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= session.getAttribute("error") %></div>
            <% session.removeAttribute("error"); %>
        <% } %>

        <% if (!canEditTime) { %>
            <div class="time-warning">⏰ Đã quá 1 giờ kể từ lúc tạo đơn. Không thể chỉnh sửa!</div>
        <% } %>

        <!-- FORM SỬA CHO NHÂN VIÊN -->
        <% if (canEditAsEmployee) { %>
        <div class="card" id="editFormEmployee">
            <h2 style="margin-bottom: 24px; font-size: 24px;">✏️ Sửa đơn nghỉ phép</h2>
            <form method="post" action="${pageContext.request.contextPath}/request/update">
                <input type="hidden" name="requestId" value="<%= req.getRequestID() %>">
                <input type="hidden" name="actionType" value="employee">
                
                <div class="form-group">
                    <label>📅 Từ ngày</label>
                    <input type="date" name="startDate" class="form-control" value="<%= req.getStartDate() %>">
                </div>
                
                <div class="form-group">
                    <label>📅 Đến ngày</label>
                    <input type="date" name="endDate" class="form-control" value="<%= req.getEndDate() %>">
                </div>
                
                <% if (templates != null && !templates.isEmpty()) { %>
                <div class="form-group">
                    <label>📝 Template lý do</label>
                    <select name="reasonTemplateId" class="form-select">
                        <option value="0">-- Tự nhập lý do --</option>
                        <% for (LeaveReasonTemplate tmpl : templates) { %>
                            <option value="<%= tmpl.getTemplateID() %>" 
                                <%= (req.getReasonTemplateID() != null && req.getReasonTemplateID() == tmpl.getTemplateID()) ? "selected" : "" %>>
                                <%= tmpl.getReasonText() %>
                            </option>
                        <% } %>
                    </select>
                </div>
                <% } %>
                
                <div class="form-group">
                    <label>💬 Lý do chi tiết</label>
                    <textarea name="customReason" class="form-control"><%= req.getCustomReason() != null ? req.getCustomReason() : "" %></textarea>
                </div>
                
                <div class="form-group">
                    <label>📌 Ghi chú cập nhật</label>
                    <textarea name="updateNote" class="form-control" placeholder="Lý do sửa đơn..."></textarea>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">💾 Lưu thay đổi</button>
                    <button type="button" onclick="toggleEmployeeEdit()" class="btn btn-back">❌ Hủy</button>
                </div>
            </form>
        </div>
        <% } %>

        <!-- FORM SỬA CHO CẤP TRÊN -->
        <% if (canEditAsManager && !isOwner) { %>
        <div class="card" id="editFormManager">
            <h2 style="margin-bottom: 24px; font-size: 24px;">🔄 Đổi trạng thái đơn</h2>
            <form method="post" action="${pageContext.request.contextPath}/request/update">
                <input type="hidden" name="requestId" value="<%= req.getRequestID() %>">
                <input type="hidden" name="actionType" value="manager">
                
                <div class="form-group">
                    <label>📊 Trạng thái mới</label>
                    <select name="newStatus" class="form-select" required>
                        <option value="">-- Chọn trạng thái --</option>
                        <option value="InProgress">Đang chờ</option>
                        <option value="Approved">Đã duyệt</option>
                        <option value="Rejected">Từ chối</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>📌 Ghi chú</label>
                    <textarea name="updateNote" class="form-control" placeholder="Lý do thay đổi trạng thái..."></textarea>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">💾 Cập nhật</button>
                    <button type="button" onclick="toggleManagerEdit()" class="btn btn-back">❌ Hủy</button>
                </div>
            </form>
        </div>
        <% } %>

        <!-- THÔNG TIN ĐƠN -->
        <div class="card" id="detailView">
            <% 
                String statusClass = "status-inprogress";
                String statusIcon = "⏳";
                if ("Approved".equals(req.getStatus())) {
                    statusClass = "status-approved";
                    statusIcon = "✅";
                } else if ("Rejected".equals(req.getStatus())) {
                    statusClass = "status-rejected";
                    statusIcon = "❌";
                }
            %>
            <span class="status-badge <%= statusClass %>"><%= statusIcon %> <%= req.getStatusDisplay() %></span>

            <div class="info-section">
                <div class="section-title">ℹ️ Thông tin cơ bản</div>
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
                <div class="section-title">📅 Thời gian nghỉ</div>
                <div class="info-grid">
                    <div class="info-item">
                        <span class="info-label">Từ ngày</span>
                        <span class="info-value"><%= req.getStartDate().format(dateFormatter) %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Đến ngày</span>
                        <span class="info-value"><%= req.getEndDate().format(dateFormatter) %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Tổng số ngày</span>
                        <span class="info-value"><%= req.getTotalDays() %> ngày</span>
                    </div>
                </div>
            </div>

            <div class="info-section">
                <div class="section-title">💬 Lý do nghỉ phép</div>
                <div class="reason-box">
                    <%= req.getReason() != null ? req.getReason() : "Không có lý do" %>
                </div>
            </div>

            <% if (req.getProcessedBy() != null) { %>
            <div class="info-section">
                <div class="section-title">✅ Thông tin xử lý</div>
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
                    <div class="reason-box" style="margin-top: 12px;"><%= req.getProcessedNote() %></div>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>
    </div>

    <script>
        function toggleEmployeeEdit() {
            const form = document.getElementById('editFormEmployee');
            const detail = document.getElementById('detailView');
            const btn = document.getElementById('btnEditEmployee');
            
            if (form.style.display === 'none' || form.style.display === '') {
                form.style.display = 'block';
                detail.style.display = 'none';
                btn.textContent = '👁️ Xem chi tiết';
            } else {
                form.style.display = 'none';
                detail.style.display = 'block';
                btn.textContent = '✏️ Sửa đơn';
            }
        }
        
        function toggleManagerEdit() {
            const form = document.getElementById('editFormManager');
            const detail = document.getElementById('detailView');
            const btn = document.getElementById('btnEditManager');
            
            if (form.style.display === 'none' || form.style.display === '') {
                form.style.display = 'block';
                detail.style.display = 'none';
                btn.textContent = '👁️ Xem chi tiết';
            } else {
                form.style.display = 'none';
                detail.style.display = 'block';
                btn.textContent = '🔄 Đổi trạng thái';
            }
        }
    </script>
</body>
</html>