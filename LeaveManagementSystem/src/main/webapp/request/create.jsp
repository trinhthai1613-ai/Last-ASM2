<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.Employee" %>
<%@ page import="com.company.lms.model.LeaveType" %>
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
            max-width: 800px;
            margin: 40px auto;
            padding: 0 30px;
        }
        .form-card {
            background: #ffffff;
            border-radius: 18px;
            padding: 40px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            box-shadow: 0 2px 16px rgba(0, 0, 0, 0.08);
        }
        h1 {
            font-size: 28px;
            margin-bottom: 30px;
            font-weight: 600;
            letter-spacing: -0.02em;
        }
        .form-group {
            margin-bottom: 24px;
            transition: all 0.3s ease;
        }
        .form-group.hidden {
            display: none;
        }
        .form-group.show {
            animation: slideDown 0.3s ease-out;
        }
        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #1d1d1f;
            font-size: 14px;
            font-weight: 500;
        }
        .required {
            color: #ff3b30;
        }
        .optional {
            color: #6e6e73;
            font-size: 12px;
            font-weight: 400;
        }
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
        textarea {
            min-height: 120px;
            resize: vertical;
        }
        .info-box {
            background: rgba(52, 199, 89, 0.1);
            border: 1px solid rgba(52, 199, 89, 0.3);
            border-radius: 12px;
            padding: 12px 16px;
            margin-top: 8px;
            color: #34c759;
            font-size: 13px;
            display: flex;
            align-items: start;
            gap: 10px;
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
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            margin-top: 20px;
            letter-spacing: -0.01em;
        }
        .btn-submit:hover {
            transform: scale(1.02);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        .btn-submit:disabled {
            background: #e8e8ed;
            cursor: not-allowed;
            transform: none;
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
        .btn-back:hover {
            background: #e8e8ed;
        }
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
            <a href="${pageContext.request.contextPath}/home" class="logo">
                🚀 Leave System
            </a>
        </div>
    </nav>

    <div class="main-container">
        <a href="${pageContext.request.contextPath}/home" class="btn-back">
            ← Quay lại
        </a>
        
        <div class="form-card">
            <h1>➕ Tạo đơn nghỉ phép</h1>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-error">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <form id="leaveRequestForm" action="${pageContext.request.contextPath}/request/create" method="post">
                <div class="form-group">
                    <label for="leaveTypeID">Loại nghỉ phép <span class="required">*</span></label>
                    <select id="leaveTypeID" name="leaveTypeID" required>
                        <option value="">-- Chọn loại nghỉ phép --</option>
                        <% if (leaveTypes != null) {
                            for (LeaveType lt : leaveTypes) { %>
                                <option value="<%= lt.getLeaveTypeID() %>">
                                    <%= lt.getLeaveTypeName() %>
                                </option>
                        <%  }
                        } %>
                        <option value="other">Khác (Nhập lý do tùy chỉnh)</option>
                    </select>
                    <div class="info-box">
                        <span>ℹ️</span>
                        <span id="leaveTypeInfo">Chọn loại nghỉ phép để xem thông tin chi tiết</span>
                    </div>
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
                        Lý do <span id="reasonRequired" class="required">*</span>
                        <span id="reasonOptional" class="optional hidden">(Tùy chọn)</span>
                    </label>
                    <textarea id="customReason" name="customReason" 
                              placeholder="Nhập lý do nghỉ phép của bạn..."></textarea>
                    <div class="info-box">
                        <span>💡</span>
                        <span>Hãy mô tả chi tiết lý do nghỉ phép để quản lý dễ dàng xét duyệt đơn của bạn.</span>
                    </div>
                </div>
                
                <button type="submit" class="btn-submit" id="submitBtn">
                    Gửi đơn
                </button>
            </form>
        </div>
    </div>

    <script>
        const leaveTypeSelect = document.getElementById('leaveTypeID');
        const customReasonGroup = document.getElementById('customReasonGroup');
        const customReasonTextarea = document.getElementById('customReason');
        const leaveTypeInfo = document.getElementById('leaveTypeInfo');
        const reasonRequired = document.getElementById('reasonRequired');
        const reasonOptional = document.getElementById('reasonOptional');
        const form = document.getElementById('leaveRequestForm');
        const startDateInput = document.getElementById('startDate');
        const endDateInput = document.getElementById('endDate');

        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        const minDate = tomorrow.toISOString().split('T')[0];
        startDateInput.min = minDate;
        endDateInput.min = minDate;

        startDateInput.addEventListener('change', function() {
            endDateInput.min = this.value;
            if (endDateInput.value && endDateInput.value < this.value) {
                endDateInput.value = this.value;
            }
        });

        leaveTypeSelect.addEventListener('change', function() {
            const selectedOption = this.options[this.selectedIndex];
            const selectedValue = this.value;

            customReasonTextarea.value = '';
            
            if (selectedValue === '') {
                customReasonGroup.classList.add('hidden');
                customReasonGroup.classList.remove('show');
                customReasonTextarea.removeAttribute('required');
                leaveTypeInfo.textContent = 'Chọn loại nghỉ phép để xem thông tin chi tiết';
            } 
            else if (selectedValue === 'other') {
                customReasonGroup.classList.remove('hidden');
                customReasonGroup.classList.add('show');
                customReasonTextarea.setAttribute('required', 'required');
                reasonRequired.classList.remove('hidden');
                reasonOptional.classList.add('hidden');
                leaveTypeInfo.innerHTML = '<strong>Lưu ý:</strong> Bạn cần nhập lý do chi tiết khi chọn loại nghỉ "Khác"';
            }
            else {
                customReasonGroup.classList.add('hidden');
                customReasonGroup.classList.remove('show');
                customReasonTextarea.removeAttribute('required');
                leaveTypeInfo.innerHTML = '<strong>' + selectedOption.text + '</strong> - Không cần nhập lý do thêm';
            }
        });

        form.addEventListener('submit', function(e) {
            const leaveType = leaveTypeSelect.value;
            const customReason = customReasonTextarea.value.trim();
            const startDate = new Date(startDateInput.value);
            const endDate = new Date(endDateInput.value);

            if (!leaveType) {
                e.preventDefault();
                alert('Vui lòng chọn loại nghỉ phép!');
                leaveTypeSelect.focus();
                return;
            }

            if (endDate < startDate) {
                e.preventDefault();
                alert('Ngày kết thúc phải lớn hơn hoặc bằng ngày bắt đầu!');
                endDateInput.focus();
                return;
            }

            if (leaveType === 'other' && !customReason) {
                e.preventDefault();
                alert('Vui lòng nhập lý do khi chọn loại nghỉ "Khác"!');
                customReasonTextarea.focus();
                return;
            }

            return true;
        });
    </script>
</body>
</html>