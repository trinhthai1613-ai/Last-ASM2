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
            
            <form action="${pageContext.request.contextPath}/request/create" method="post">
                <div class="form-group">
                    <label for="leaveTypeID">Loại nghỉ phép <span class="required">*</span></label>
                    <select id="leaveTypeID" name="leaveTypeID" required>
                        <option value="">-- Chọn loại nghỉ phép --</option>
                        <% if (leaveTypes != null) {
                            for (LeaveType lt : leaveTypes) { %>
                                <option value="<%= lt.getLeaveTypeID() %>"><%= lt.getLeaveTypeName() %></option>
                        <%  }
                        } %>
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
                
                <div class="form-group">
                    <label for="customReason">Lý do <span class="required">*</span></label>
                    <textarea id="customReason" name="customReason" placeholder="Nhập lý do nghỉ phép..." required></textarea>
                </div>
                
                <button type="submit" class="btn-submit">
                    <i class="fas fa-paper-plane"></i> Gửi đơn
                </button>
            </form>
        </div>
    </div>
</body>
</html>