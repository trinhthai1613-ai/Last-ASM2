<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.Employee" %>
<%@ page import="com.company.lms.model.LeaveRequest" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    Employee user = (Employee) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    LeaveRequest leaveRequest = (LeaveRequest) request.getAttribute("request");
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xét duyệt đơn nghỉ phép</title>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
</head>
<body>
    <div class="container" style="max-width: 800px; margin: 40px auto; padding: 0 30px;">
        <a href="${pageContext.request.contextPath}/request/list" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Quay lại
        </a>
        
        <div class="card mt-2">
            <h1 class="gradient-text mb-3"><i class="fas fa-check-circle"></i> Xét duyệt đơn nghỉ phép</h1>
            
            <% if (leaveRequest != null) { %>
                <div style="padding: 20px; background: rgba(99, 102, 241, 0.1); border-radius: 12px; margin-bottom: 30px;">
                    <h3 style="margin-bottom: 15px;">Thông tin đơn</h3>
                    <p><strong>Nhân viên:</strong> <%= leaveRequest.getEmployeeName() %></p>
                    <p><strong>Loại nghỉ:</strong> <%= leaveRequest.getLeaveTypeName() %></p>
                    <p><strong>Từ ngày:</strong> <%= leaveRequest.getStartDate().format(dateFormatter) %></p>
                    <p><strong>Đến ngày:</strong> <%= leaveRequest.getEndDate().format(dateFormatter) %></p>
                    <p><strong>Số ngày:</strong> <%= leaveRequest.getTotalDays() %> ngày</p>
                    <p><strong>Lý do:</strong> <%= leaveRequest.getReason() %></p>
                </div>
                
                <form action="${pageContext.request.contextPath}/request/process" method="post">
                    <input type="hidden" name="requestID" value="<%= leaveRequest.getRequestID() %>">
                    
                    <div class="form-group">
                        <label class="form-label">Ghi chú</label>
                        <textarea name="note" class="form-control" rows="4" placeholder="Nhập ghi chú (nếu có)..."></textarea>
                    </div>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                        <button type="submit" name="action" value="APPROVE" class="btn btn-success" style="width: 100%;">
                            <i class="fas fa-check"></i> Duyệt
                        </button>
                        <button type="submit" name="action" value="REJECT" class="btn btn-danger" style="width: 100%;">
                            <i class="fas fa-times"></i> Từ chối
                        </button>
                    </div>
                </form>
            <% } else { %>
                <p style="text-align: center; color: #94a3b8; padding: 40px;">Không tìm thấy thông tin đơn nghỉ phép</p>
            <% } %>
        </div>
    </div>
</body>
</html>