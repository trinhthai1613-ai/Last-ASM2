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
    
    // Kiểm tra 1h limit
    long minutesPassed = Duration.between(req.getCreatedAt(), java.time.LocalDateTime.now()).toMinutes();
    boolean canEditTime = minutesPassed <= 60;
    
    // Kiểm tra quyền
    RoleDAO roleDAO = new RoleDAO();
    int roleLevel = roleDAO.getHighestRoleLevel(user.getEmployeeID());
    
    boolean isManager = (roleLevel <= 2);
    boolean isOwner = (req.getEmployeeID() == user.getEmployeeID());
    boolean canEditAsEmployee = (isOwner && "InProgress".equals(req.getStatus()) && canEditTime);
    boolean canEditAsManager = (isManager && canEditTime);
    
    // Lấy templates nếu là employee
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
    <title>Chi tiết đơn nghỉ phép</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            background: #ffffff;
            color: #1d1d1f;
        }
        .navbar {
            background: #ffffff;
            padding: 16px 0;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
            border-bottom: 1px solid rgba(0, 0, 0, 0.1);
        }
        .nav-container { max-width: 1400px; margin: 0 auto; padding: 0 30px; }
        .logo { font-size: 20px; font-weight: 600; color: #000; text-decoration: none; }
        .main-container { max-width: 900px; margin: 40px auto; padding: 0 30px; }
        .page-header { display: flex; justify-content: space-between; margin-bottom: 30px; align-items: center; }
        h1 { font-size: 28px; font-weight: 600; }
        .btn-back, .btn-edit {
            padding: 8px 18px;
            background: #f5f5f7;
            border: 1px solid rgba(0,0,0,0.1);
            border-radius: 980px;
            color: #1d1d1f;
            text-decoration: none;
            font-size: 14px;
            cursor: pointer;
            margin-left: 10px;
        }
        .btn-edit { background: #007aff; color: #fff; border: none; }
        .btn-edit:hover { background: #0051d5; }
        .detail-card, .edit-card {
            background: #ffffff;
            border-radius: 18px;
            padding: 40px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            box-shadow: 0 2px 16px rgba(0, 0, 0, 0.08);
            margin-bottom: 24px;
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
        .section-title { font-size: 17px; font-weight: 600; margin-bottom: 20px; }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        .info-item { display: flex; flex-direction: column; gap: 6px; }
        .info-label { font-size: 12px; color: #6e6e73; }
        .info-value { font-size: 15px; font-weight: 500; color: #1d1d1f; }
        .reason-box {
            background: #f5f5f7;
            border-radius: 12px;
            padding: 20px;
            line-height: 1.8;
        }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 500; }
        .form-control, .form-select {
            width: 100%;
            padding: 12px;
            border: 1px solid rgba(0,0,0,0.1);
            border-radius: 12px;
            font-size: 14px;
        }
        .form-control:focus, .form-select:focus {
            outline: none;
            border-color: #000;
            box-shadow: 0 0 0 4px rgba(0,0,0,0.06);
        }
        textarea.form-control { min-height: 100px; resize: vertical; }
        .btn-primary {
            padding: 12px 24px;
            background: #000;
            color: #fff;
            border: none;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
        }
        .btn-primary:hover { background: #1d1d1f; }
        #editFormEmployee, #editFormManager { display: none; }
        .alert {
            padding: 12px 16px;
            border-radius: 12px;
            margin-bottom: 20px;
        }
        .alert-success { background: rgba(52,199,89,0.1); border: 1px solid rgba(52,199,89,0.3); color: #34c759; }
        .alert-error { background: rgba(255,59,48,0.1); border: 1px solid rgba(255,59,48,0.3); color: #ff3b30; }
        .time-warning {
            background: rgba(255,149,0,0.1);
            border: 1px solid rgba(255,149,0,0.3);
            border-radius: 12px;
            padding: 12px 16px;
            color: #ff9500;
            font-size: 13px;
            margin-bottom: 20px;
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
            <div>
                <a href="javascript:history.back()" class="btn-back">← Quay lại</a>
                <% if (canEditAsEmployee) { %>
                    <button onclick="toggleEmployeeEdit()" class="btn-edit" id="btnEditEmployee">✏️ Sửa đơn</button>
                <% } else if (canEditAsManager && !isOwner) { %>
                    <button onclick="toggleManagerEdit()" class="btn-edit" id="btnEditManager">🔄 Đổi trạng thái</button>
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
        <div class="edit-card" id="editFormEmployee">
            <h2 style="margin-bottom: 24px;">✏️ Sửa đơn nghỉ phép</h2>
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
                
                <button type="submit" class="btn-primary">💾 Lưu thay đổi</button>
                <button type="button" onclick="toggleEmployeeEdit()" class="btn-back" style="margin-left: 10px;">❌ Hủy</button>
            </form>
        </div>
        <% } %>

        <!-- FORM SỬA CHO CẤP TRÊN -->
        <% if (canEditAsManager && !isOwner) { %>
        <div class="edit-card" id="editFormManager">
            <h2 style="margin-bottom: 24px;">🔄 Đổi trạng thái đơn</h2>
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
                
                <button type="submit" class="btn-primary">💾 Cập nhật</button>
                <button type="button" onclick="toggleManagerEdit()" class="btn-back" style="margin-left: 10px;">❌ Hủy</button>
            </form>
        </div>
        <% } %>

        <!-- THÔNG TIN ĐƠN -->
        <div class="detail-card" id="detailView">
            <% 
                String statusClass = "status-inprogress";
                if ("Approved".equals(req.getStatus())) statusClass = "status-approved";
                else if ("Rejected".equals(req.getStatus())) statusClass = "status-rejected";
            %>
            <span class="status-badge <%= statusClass %>">● <%= req.getStatusDisplay() %></span>

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
                    <div class="reason-box"><%= req.getProcessedNote() %></div>
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