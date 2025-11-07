<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.*" %>
<%@ page import="java.util.List" %>
<%
    Employee user = (Employee) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<LeaveType> leaveTypes = (List<LeaveType>) request.getAttribute("leaveTypes");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo đơn nghỉ phép</title>
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
        }
        .logo {
            font-size: 20px;
            font-weight: 600;
            color: #000000;
            text-decoration: none;
            letter-spacing: -0.02em;
        }
        .main-container { max-width: 800px; margin: 40px auto; padding: 0 30px; }
        .form-card {
            background: #ffffff;
            border-radius: 18px;
            padding: 40px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            box-shadow: 0 2px 16px rgba(0, 0, 0, 0.08);
        }
        h1 { font-size: 28px; margin-bottom: 30px; font-weight: 600; letter-spacing: -0.02em; }
        .form-group {
            margin-bottom: 24px;
            transition: all 0.3s ease;
        }
        .form-group.hidden { display: none; }
        .form-group.show { animation: slideDown 0.3s ease-out; }
        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #1d1d1f;
            font-size: 14px;
            font-weight: 500;
        }
        .required { color: #ff3b30; }
        .optional { color: #6e6e73; font-size: 12px; font-weight: 400; }
        input, select, textarea {
            width: 100%;
            padding: 12px 16px;
            background: #f5f5f7;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 12px;
            color: #1d1d1f;
            font-size: 14px;
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }
        input:focus, select:focus, textarea:focus {
            outline: none;
            border-color: #000000;
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(0, 0, 0, 0.06);
        }
        textarea { min-height: 120px; resize: vertical; }
        .info-box {
            background: rgba(52, 199, 89, 0.1);
            border: 1px solid rgba(52, 199, 89, 0.3);
            border-radius: 12px;
            padding: 12px 16px;
            margin-top: 8px;
            color: #34c759;
            font-size: 13px;
        }
        .btn-submit {
            width: 100%;
            padding: 12px;
            background: #000000;
            border: none;
            border-radius: 980px;
            color: #fff;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 20px;
        }
        .btn-submit:hover { transform: scale(1.02); box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15); }
        .btn-submit:disabled { background: #e8e8ed; cursor: not-allowed; }
        .btn-back {
            display: inline-block;
            padding: 8px 18px;
            background: #f5f5f7;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 980px;
            color: #1d1d1f;
            text-decoration: none;
            margin-bottom: 20px;
            font-size: 14px;
        }
        .btn-back:hover { background: #e8e8ed; }
        .alert {
            padding: 12px 16px;
            border-radius: 12px;
            margin-bottom: 20px;
        }
        .alert-error {
            background: rgba(255, 59, 48, 0.1);
            border: 1px solid rgba(255, 59, 48, 0.3);
            color: #ff3b30;
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
        <a href="${pageContext.request.contextPath}/home" class="btn-back">← Quay lại</a>
        
        <div class="form-card">
            <h1>➕ Tạo đơn nghỉ phép</h1>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-error"><%= request.getAttribute("error") %></div>
            <% } %>
            
            <form id="leaveRequestForm" action="${pageContext.request.contextPath}/request/create" method="post">
                <div class="form-group">
                    <label for="leaveTypeID">Loại nghỉ phép <span class="required">*</span></label>
                    <select id="leaveTypeID" name="leaveTypeID" required>
                        <option value="">-- Chọn loại nghỉ phép --</option>
                        <% if (leaveTypes != null) {
                            for (LeaveType lt : leaveTypes) { %>
                                <option value="<%= lt.getLeaveTypeID() %>" 
                                        data-allow-custom="<%= lt.isAllowCustomReason() %>">
                                    <%= lt.getLeaveTypeName() %>
                                </option>
                        <%  }} %>
                    </select>
                    <div class="info-box">💡 Chọn loại nghỉ phép để xem template lý do</div>
                </div>
                
                <!-- TEMPLATE REASON DROPDOWN -->
                <div class="form-group hidden" id="templateGroup">
                    <label for="reasonTemplateID">📝 Template lý do <span class="optional">(Tùy chọn)</span></label>
                    <select id="reasonTemplateID" name="reasonTemplateID">
                        <option value="">-- Chọn template hoặc tự nhập --</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="startDate">Từ ngày <span class="required">*</span></label>
                    <input type="date" id="startDate" name="startDate" required>
                </div>
                
                <div class="form-group">
                    <label for="endDate">Đến ngày <span class="required">*</span></label>
                    <input type="date" id="endDate" name="endDate" required>
                </div>
                
                <div class="form-group hidden" id="customReasonGroup">
                    <label for="customReason">
                        Lý do chi tiết <span id="reasonRequired" class="optional">(Tùy chọn)</span>
                    </label>
                    <textarea id="customReason" name="customReason" 
                              placeholder="Nhập lý do chi tiết..."></textarea>
                </div>
                
                <button type="submit" class="btn-submit">Gửi đơn</button>
            </form>
        </div>
    </div>

    <script>
        const leaveTypeSelect = document.getElementById('leaveTypeID');
        const templateGroup = document.getElementById('templateGroup');
        const templateSelect = document.getElementById('reasonTemplateID');
        const customReasonGroup = document.getElementById('customReasonGroup');
        const customReasonTextarea = document.getElementById('customReason');
        const startDateInput = document.getElementById('startDate');
        const endDateInput = document.getElementById('endDate');

        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        startDateInput.min = tomorrow.toISOString().split('T')[0];
        endDateInput.min = tomorrow.toISOString().split('T')[0];

        startDateInput.addEventListener('change', function() {
            endDateInput.min = this.value;
            if (endDateInput.value && endDateInput.value < this.value) {
                endDateInput.value = this.value;
            }
        });

        // Load templates khi chọn loại nghỉ phép
        leaveTypeSelect.addEventListener('change', async function() {
            const leaveTypeId = this.value;
            
            templateGroup.classList.add('hidden');
            customReasonGroup.classList.add('hidden');
            templateSelect.innerHTML = '<option value="">-- Chọn template hoặc tự nhập --</option>';
            customReasonTextarea.value = '';
            
            if (!leaveTypeId) return;
            
            try {
                const response = await fetch('${pageContext.request.contextPath}/api/templates?leaveTypeId=' + leaveTypeId);
                const templates = await response.json();
                
                if (templates && templates.length > 0) {
                    templates.forEach(tmpl => {
                        const option = document.createElement('option');
                        option.value = tmpl.templateID;
                        option.textContent = tmpl.reasonText;
                        templateSelect.appendChild(option);
                    });
                    templateGroup.classList.remove('hidden');
                }
                
                customReasonGroup.classList.remove('hidden');
            } catch (error) {
                console.error('Error loading templates:', error);
                customReasonGroup.classList.remove('hidden');
            }
        });
    </script>
</body>
</html>