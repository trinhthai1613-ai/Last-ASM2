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
    LeaveRequest request = (LeaveRequest) request.getAttribute("request");
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết đơn nghỉ phép</title>
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
            <h1 class="gradient-text mb-3"><i class="fas fa-file-alt"></i> Chi tiết đơn nghỉ phép</h1>
            
            <% if (request != null) { %>
                <div class="info-grid" style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px;">
                    <div class="info-item" style="padding: 15px; background: rgba(99, 102, 241, 0.1); border-radius: 12px;">
                        <div style="font-size: 13px; color: #94a3b8; margin-bottom: 5px;">Mã đơn</div>
                        <div style="font-size: 16px; font-weight: 500;"><%= request.getRequestCode() %></div>
                    </div>
                    
                    <div class="info-item" style="padding: 15px; background: rgba(99, 102, 241, 0.1); border-radius: 12px;">
                        <div style="font-size: 13px; color: #94a3b8; margin-bottom: 5px;">Loại nghỉ</div>
                        <div style="font-size: 16px; font-weight: 500;"><%= request.getLeaveTypeName() %></div>
                    </div>
                    
                    <div class="info-item" style="padding: 15px; background: rgba(99, 102, 241, 0.1); border-radius: 12px;">
                        <div style="font-size: 13px; color: #94a3b8; margin-bottom: 5px;">Từ ngày</div>
                        <div style="font-size: 16px; font-weight: 500;"><%= request.getStartDate().format(dateFormatter) %></div>
                    </div>
                    
                    <div class="info-item" style="padding: 15px; background: rgba(99, 102, 241, 0.1); border-radius: 12px;">
                        <div style="font-size: 13px; color: #94a3b8; margin-bottom: 5px;">Đến ngày</div>
                        <div style="font-size: 16px; font-weight: 500;"><%= request.getEndDate().format(dateFormatter) %></div>
                    </div>
                    
                    <div class="info-item" style="padding: 15px; background: rgba(99, 102, 241, 0.1); border-radius: 12px;">
                        <div style="font-size: 13px; color: #94a3b8; margin-bottom: 5px;">Số ngày</div>
                        <div style="font-size: 16px; font-weight: 500;"><%= request.getTotalDays() %> ngày</div>
                    </div>
                    
                    <div class="info-item" style="padding: 15px; background: rgba(99, 102, 241, 0.1); border-radius: 12px;">
                        <div style="font-size: 13px; color: #94a3b8; margin-bottom: 5px;">Trạng thái</div>
                        <div style="font-size: 16px; font-weight: 500;"><span class="badge badge-<%= "Approved".equals(request.getStatus()) ? "success" : "InProgress".equals(request.getStatus()) ? "warning" : "danger" %>"><%= request.getStatusDisplay() %></span></div>
                    </div>
                </div>
                
                <div class="mt-3" style="padding: 20px; background: rgba(99, 102, 241, 0.1); border-radius: 12px;">
                    <div style="font-size: 13px; color: #94a3b8; margin-bottom: 10px;">Lý do</div>
                    <div style="font-size: 15px; line-height: 1.6;"><%= request.getReason() %></div>
                </div>
                
                <% if (request.getProcessedBy() != null) { %>
                    <div class="mt-3" style="padding: 20px; background: rgba(99, 102, 241, 0.1); border-radius: 12px;">
                        <div style="font-size: 13px; color: #94a3b8; margin-bottom: 10px;">Người xử lý</div>
                        <div style="font-size: 15px;"><%= request.getProcessedByName() %></div>
                        <% if (request.getProcessedNote() != null) { %>
                            <div style="margin-top: 10px; padding-top: 10px; border-top: 1px solid rgba(99, 102, 241, 0.2);">
                                <div style="font-size: 13px; color: #94a3b8; margin-bottom: 5px;">Ghi chú</div>
                                <div style="font-size: 14px;"><%= request.getProcessedNote() %></div>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            <% } else { %>
                <p style="text-align: center; color: #94a3b8; padding: 40px;">Không tìm thấy thông tin đơn nghỉ phép</p>
            <% } %>
        </div>
    </div>
</body>
</html>