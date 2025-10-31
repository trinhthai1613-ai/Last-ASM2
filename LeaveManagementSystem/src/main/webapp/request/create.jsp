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
            max-width: 800px;
            margin: 40px auto;
            padding: 0 30px;
        }
        
        .form-card {
            background: rgba(10, 14, 39, 0.7);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 40px;
            border: 1px solid rgba(99, 102, 241, 0.2);
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
        }
        
        h1 {
            font-size: 32px;
            margin-bottom: 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        .form-group {
            margin-bottom: 25px;
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
            color: #cbd5e1;
            font-size: 14px;
            font-weight: 500;
        }
        
        .required {
            color: #f87171;
        }
        
        .optional {
            color: #94a3b8;
            font-size: 12px;
            font-weight: 400;
        }
        
        input, select, textarea {
            width: 100%;
            padding: 13px 18px;
            background: rgba(15, 23, 42, 0.6);
            border: 2px solid rgba(99, 102, 241, 0.3);
            border-radius: 12px;
            color: #fff;
            font-size: 14px;
            font-family: 'Be Vietnam Pro', sans-serif;
            transition: all 0.3s ease;
        }
        
        input:focus, select:focus, textarea:focus {
            outline: none;
            border-color: #667eea;
            background: rgba(15, 23, 42, 0.8);
            box-shadow: 0 0 20px rgba(102, 126, 234, 0.3);
        }
        
        textarea {
            min-height: 120px;
            resize: vertical;
        }
        
        .info-box {
            background: rgba(59, 130, 246, 0.1);
            border: 1px solid rgba(59, 130, 246, 0.3);
            border-radius: 10px;
            padding: 12px 15px;
            margin-top: 8px;
            color: #93c5fd;
            font-size: 13px;
            display: flex;
            align-items: start;
            gap: 10px;
        }
        
        .info-box i {
            margin-top: 2px;
        }
        
        .btn-submit {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            border-radius: 12px;
            color: #fff;
            font-size: 16px;
            font-weight: 600;
            font-family: 'Be Vietnam Pro', sans-serif;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
            margin-top: 20px;
        }
        
        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 40px rgba(102, 126, 234, 0.5);
        }
        
        .btn-submit:disabled {
            background: rgba(99, 102, 241, 0.3);
            cursor: not-allowed;
            transform: none;
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
        
        .alert-error {
            background: rgba(239, 68, 68, 0.2);
            border: 1px solid rgba(239, 68, 68, 0.5);
            color: #fca5a5;
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
        
        <div class="form-card">
            <h1><i class="fas fa-plus-circle"></i> Tạo đơn nghỉ phép</h1>
            
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
                        <i class="fas fa-info-circle"></i>
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
                        <i class="fas fa-lightbulb"></i>
                        <span>Hãy mô tả chi tiết lý do nghỉ phép để quản lý dễ dàng xét duyệt đơn của bạn.</span>
                    </div>
                </div>
                
                <button type="submit" class="btn-submit" id="submitBtn">
                    <i class="fas fa-paper-plane"></i> Gửi đơn
                </button>
            </form>
        </div>
    </div>

    <script>
        // Lấy các elements
        const leaveTypeSelect = document.getElementById('leaveTypeID');
        const customReasonGroup = document.getElementById('customReasonGroup');
        const customReasonTextarea = document.getElementById('customReason');
        const leaveTypeInfo = document.getElementById('leaveTypeInfo');
        const reasonRequired = document.getElementById('reasonRequired');
        const reasonOptional = document.getElementById('reasonOptional');
        const form = document.getElementById('leaveRequestForm');
        const startDateInput = document.getElementById('startDate');
        const endDateInput = document.getElementById('endDate');

        // Set ngày tối thiểu là ngày mai
        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        const minDate = tomorrow.toISOString().split('T')[0];
        startDateInput.min = minDate;
        endDateInput.min = minDate;

        // Validate end date phải >= start date
        startDateInput.addEventListener('change', function() {
            endDateInput.min = this.value;
            if (endDateInput.value && endDateInput.value < this.value) {
                endDateInput.value = this.value;
            }
        });

        // Xử lý khi thay đổi loại nghỉ phép
        leaveTypeSelect.addEventListener('change', function() {
            const selectedOption = this.options[this.selectedIndex];
            const selectedValue = this.value;

            // Reset textarea
            customReasonTextarea.value = '';
            
            if (selectedValue === '') {
                // Chưa chọn gì
                customReasonGroup.classList.add('hidden');
                customReasonGroup.classList.remove('show');
                customReasonTextarea.removeAttribute('required');
                leaveTypeInfo.textContent = 'Chọn loại nghỉ phép để xem thông tin chi tiết';
            } 
            else if (selectedValue === 'other') {
                // CHỈ hiển thị form "Lý do" khi chọn "Khác" - BẮT BUỘC nhập lý do
                customReasonGroup.classList.remove('hidden');
                customReasonGroup.classList.add('show');
                customReasonTextarea.setAttribute('required', 'required');
                reasonRequired.classList.remove('hidden');
                reasonOptional.classList.add('hidden');
                leaveTypeInfo.innerHTML = '<strong>Lưu ý:</strong> Bạn cần nhập lý do chi tiết khi chọn loại nghỉ "Khác"';
            }
            else {
                // Các loại nghỉ khác - KHÔNG hiển thị form "Lý do"
                customReasonGroup.classList.add('hidden');
                customReasonGroup.classList.remove('show');
                customReasonTextarea.removeAttribute('required');
                leaveTypeInfo.innerHTML = '<strong>' + selectedOption.text + '</strong> - Không cần nhập lý do thêm';
            }
        });

        // Validate form trước khi submit
        form.addEventListener('submit', function(e) {
            const leaveType = leaveTypeSelect.value;
            const customReason = customReasonTextarea.value.trim();
            const startDate = new Date(startDateInput.value);
            const endDate = new Date(endDateInput.value);

            // Kiểm tra loại nghỉ
            if (!leaveType) {
                e.preventDefault();
                alert('Vui lòng chọn loại nghỉ phép!');
                leaveTypeSelect.focus();
                return;
            }

            // Kiểm tra ngày
            if (endDate < startDate) {
                e.preventDefault();
                alert('Ngày kết thúc phải lớn hơn hoặc bằng ngày bắt đầu!');
                endDateInput.focus();
                return;
            }

            // Kiểm tra lý do khi chọn "Khác"
            if (leaveType === 'other' && !customReason) {
                e.preventDefault();
                alert('Vui lòng nhập lý do khi chọn loại nghỉ "Khác"!');
                customReasonTextarea.focus();
                return;
            }

            // Xử lý khi chọn "Khác" - set leaveTypeID về null và bắt buộc có customReason
            if (leaveType === 'other') {
                // Không set leaveTypeID, để backend xử lý
                // Đảm bảo customReason đã được điền
                if (!customReason) {
                    e.preventDefault();
                    alert('Vui lòng nhập lý do nghỉ phép!');
                    customReasonTextarea.focus();
                    return;
                }
            }

            // All validation passed
            return true;
        });

        // Real-time validation cho custom reason khi bắt buộc
        customReasonTextarea.addEventListener('input', function() {
            if (leaveTypeSelect.value === 'other') {
                if (this.value.trim().length < 10) {
                    this.style.borderColor = 'rgba(239, 68, 68, 0.5)';
                } else {
                    this.style.borderColor = 'rgba(34, 197, 94, 0.5)';
                }
            }
        });
    </script>
</body>
</html>
