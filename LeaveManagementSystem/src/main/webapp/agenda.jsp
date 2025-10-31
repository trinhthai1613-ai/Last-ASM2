<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.Employee" %>
<%@ page import="com.company.lms.model.LeaveRequest" %>
<%@ page import="java.util.List" %>
<%
    Employee user = (Employee) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    @SuppressWarnings("unchecked")
    List<LeaveRequest> leaveRequests = (List<LeaveRequest>) request.getAttribute("leaveRequests");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch nghỉ phép</title>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
    <style>
        .agenda-container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 30px;
        }
        
        .calendar-grid {
            display: grid;
            gap: 20px;
        }
        
        .leave-item {
            background: rgba(99, 102, 241, 0.1);
            border-radius: 12px;
            padding: 20px;
            border-left: 4px solid;
            transition: all 0.3s ease;
        }
        
        .leave-item.approved {
            border-left-color: #10b981;
        }
        
        .leave-item:hover {
            transform: translateX(5px);
            background: rgba(99, 102, 241, 0.15);
        }
        
        .leave-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }
        
        .leave-type {
            font-size: 18px;
            font-weight: 600;
            color: #fff;
        }
        
        .leave-dates {
            color: #94a3b8;
            font-size: 14px;
        }
        
        .leave-duration {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 500;
        }
        
        .no-leaves {
            text-align: center;
            padding: 60px 20px;
            color: #94a3b8;
        }
        
        .no-leaves i {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.5;
        }
    </style>
</head>
<body>
    <div class="agenda-container">
        <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Quay lại
        </a>
        
        <div class="card mt-2">
            <h1 class="gradient-text mb-3">
                <i class="fas fa-calendar-alt"></i> Lịch nghỉ phép
            </h1>
            
            <% if (leaveRequests != null && !leaveRequests.isEmpty()) { %>
                <div class="calendar-grid">
                    <% for (LeaveRequest lr : leaveRequests) { %>
                        <div class="leave-item <%= lr.getStatus().toLowerCase() %>">
                            <div class="leave-header">
                                <div>
                                    <div class="leave-type">
                                        <i class="fas fa-umbrella-beach"></i>
                                        <%= lr.getLeaveTypeName() != null ? lr.getLeaveTypeName() : "Nghỉ phép" %>
                                    </div>
                                    <div class="leave-dates">
                                        <i class="fas fa-calendar"></i>
                                        <%= lr.getStartDate() %> - <%= lr.getEndDate() %>
                                    </div>
                                </div>
                                <div class="leave-duration">
                                    <%= lr.getTotalDays() %> ngày
                                </div>
                            </div>
                            
                            <% if (lr.getReason() != null && !lr.getReason().isEmpty()) { %>
                                <div style="margin-top: 10px; color: #cbd5e1; font-size: 14px;">
                                    <i class="fas fa-quote-left"></i>
                                    <%= lr.getReason() %>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            <% } else { %>
                <div class="no-leaves">
                    <i class="fas fa-calendar-times"></i>
                    <h3>Chưa có lịch nghỉ phép nào</h3>
                    <p>Bạn chưa có đơn nghỉ phép nào được duyệt</p>
                    <a href="${pageContext.request.contextPath}/request/create" class="btn btn-primary mt-2">
                        <i class="fas fa-plus-circle"></i> Tạo đơn nghỉ phép
                    </a>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>
