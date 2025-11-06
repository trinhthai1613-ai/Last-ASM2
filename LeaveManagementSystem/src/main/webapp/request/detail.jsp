<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.*" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
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
    
    // Kiểm tra quyền sửa
    RoleDAO roleDAO = new RoleDAO();
    int roleLevel = roleDAO.getHighestRoleLevel(user.getEmployeeID());
    boolean canEdit = false;
    
    if (roleLevel <= 2) {
        canEdit = true; // CEO/Manager
    } else if (roleLevel == 3) {
        EmployeeDAO empDAO = new EmployeeDAO();
        Employee requestEmployee = empDAO.getEmployeeById(req.getEmployeeID());
        canEdit = (requestEmployee != null && requestEmployee.getManagerID() != null && 
                  requestEmployee.getManagerID() == user.getEmployeeID());
    } else {
        canEdit = (req.getEmployeeID() == user.getEmployeeID() && "InProgress".equals(req.getStatus()));
    }
    
    // Lấy templates nếu có quyền sửa
    List<LeaveReasonTemplate> templates = null;
    if (canEdit) {
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
        .page-header { display: flex; justify-content: space-between; margin-bottom: 30px; }
        h1 { font-size: 28px; font-weight: 600; }
        .btn-back {
            padding: 8px 18px;
            background: #f5f5f7;
            border: 1px solid rgba(0,0,0,0.1);
            border-radius: 980px;
            color: #1d1d1f;
            text-decoration: none;
            font-size: 14px;
        }
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
        .reason-box, .note-box {
            background: #f5f5f7;
            border-radius: 12px;
            padding: 20px;
            line-height: 1.8;
        }
        
        /* Form Styles */
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
        .btn-edit {
            padding: 8px 18px;
            background: #007aff;
            color: #fff;
            border: none;
            border-radius: 980px;
            font-size: 14px;
            cursor: pointer;
            margin-left: 10px;
        }
        #editForm { display: none; }
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
                <% if (canEdit) { %>
                    <button onclick="toggleEdit()" class="btn-edit" id="btnEdit">✏️ Sửa đơn</button>
                <% } %>
            </div>
        </div>

        <!-- FORM SỬA ĐƠN -->
        <% if (canEdit) { %>
        <div class="edit-card" id="editForm">
            <h2 style="margin-bottom: 24px;">✏️ Sửa đơn nghỉ phép</h2>
            <form method="post" action="${pageContext.request.contextPath}/request/update">
                <input type="hidden" name="requestId" value="<%= req.getRequestID() %>">
                
                <div class="form-group">
                    <label>📅 Từ ngày</label>
                    <input type="date" name="startDate" class="form-control" 
                           value="<%= req.getStartDate() %>" <%= roleLevel >= 4 ? "" : "disabled" %>>
                </div>
                
                <div class="form-group">
                    <label>📅 Đến ngày</label>
                    <input type="date" name="endDate" class="form-control" 
                           value="<%= req.getEndDate() %>" <%= roleLevel >= 4 ? "" : "disabled" %>>
                </div>
                
                <% if (templates != null && !templates.isEmpty()) { %>
                <div class="form-group">
                    <label>📝 Template lý do</label>
                    <select name="reasonTemplateId" class="form-select" id="templateSelect">
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
                    <label>💬 Lý do chi tiết (tùy chọn)</label>
                    <textarea name="customReason" class="form-control"><%= req.getCustomReason() != null ? req.getCustomReason() : "" %></textarea>
                </div>
                
                <% if (roleLevel <= 2) { %>
                <div class="form-group">
                    <label>🔄 Trạng thái mới</label>
                    <select name="newStatus" class="form-select">
                        <option value="">-- Không thay đổi --</option>
                        <option value="InProgress">Đang chờ</option>
                        <option value="Approved">Đã duyệt</option>
                        <option value="Rejected">Từ chối</option>
                    </select>
                </div>
                <% } %>
                
                <div class="form-group">
                    <label>📌 Ghi chú cập nhật</label>
                    <textarea name="updateNote" class="form-control" placeholder="Lý do sửa đơn..."></textarea>
                </div>
                
                <button type="submit" class="btn-primary">💾 Lưu thay đổi</button>
                <button type="button" onclick="toggleEdit()" class="btn-back" style="margin-left: 10px;">❌ Hủy</button>
            </form>
        </div>
        <% } %>

        <!-- THÔNG TIN ĐƠN (code cũ giữ nguyên) -->
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
                    <div class="note-box"><%= req.getProcessedNote() %></div>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>
    </div>

    <script>
        function toggleEdit() {
            const form = document.getElementById('editForm');
            const detail = document.getElementById('detailView');
            const btn = document.getElementById('btnEdit');
            
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
    </script>
</body>
</html>