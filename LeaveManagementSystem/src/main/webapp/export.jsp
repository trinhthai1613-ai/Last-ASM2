<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.company.lms.model.*" %>
<%@ page import="com.company.lms.dao.DivisionDAO" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%
    Employee user = (Employee) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    DivisionDAO divisionDAO = new DivisionDAO();
    List<Division> divisions = divisionDAO.getAllDivisions();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xuất báo cáo - CEO</title>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Be Vietnam Pro', sans-serif;
            background: linear-gradient(135deg, #0a0e27 0%, #1a1d3e 50%, #2a2d5e 100%);
            min-height: 100vh; color: #fff; padding: 20px;
        }
        .container { max-width: 900px; margin: 0 auto; }
        .header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 40px;
        }
        .header h1 {
            font-size: 32px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        .btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none; border-radius: 10px; padding: 12px 24px;
            color: #fff; font-weight: 600; cursor: pointer;
            transition: all 0.3s ease; text-decoration: none;
            display: inline-block; font-size: 16px;
        }
        .btn:hover { transform: translateY(-2px); box-shadow: 0 5px 20px rgba(102,126,234,0.4); }
        .btn-secondary { background: rgba(99,102,241,0.2); border: 1px solid rgba(99,102,241,0.5); }

        .export-card {
            background: rgba(10,14,39,0.7); backdrop-filter: blur(20px);
            border-radius: 20px; padding: 40px;
            border: 1px solid rgba(99,102,241,0.2);
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
        }
        .card-title {
            font-size: 24px; font-weight: 700;
            margin-bottom: 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        .form-group {
            margin-bottom: 25px;
        }
        .form-group label {
            display: block; margin-bottom: 10px;
            color: #94a3b8; font-size: 15px; font-weight: 500;
        }
        .form-control {
            width: 100%;
            background: rgba(15,23,42,0.5);
            border: 1px solid rgba(99,102,241,0.3);
            border-radius: 10px; padding: 12px 18px;
            color: #fff; font-size: 15px;
            transition: all 0.3s ease;
            font-family: 'Be Vietnam Pro', sans-serif;
        }
        .form-control:focus {
            outline: none; border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102,126,234,0.1);
        }
        .date-range {
            display: grid; grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        .info-box {
            background: rgba(99,102,241,0.1);
            border: 1px solid rgba(99,102,241,0.3);
            border-radius: 10px; padding: 15px;
            margin-bottom: 25px;
        }
        .info-box i { color: #667eea; margin-right: 10px; }
        .info-box p { color: #94a3b8; line-height: 1.6; }

        .btn-export {
            width: 100%; padding: 15px;
            font-size: 18px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            box-shadow: 0 10px 30px rgba(16,185,129,0.4);
        }
        .btn-export:hover {
            box-shadow: 0 15px 40px rgba(16,185,129,0.5);
        }

        option { background: #1a1d3e; color: #fff; }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h1><i class="fas fa-download"></i> Xuất báo cáo</h1>
        <a href="${pageContext.request.contextPath}/agenda" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Quay lại
        </a>
    </div>

    <div class="export-card">
        <div class="card-title">
            <i class="fas fa-file-csv"></i> Xuất dữ liệu CSV
        </div>

        <div class="info-box">
            <p><i class="fas fa-info-circle"></i> Chức năng này cho phép bạn xuất toàn bộ dữ liệu lịch nghỉ phép theo khoảng thời gian và phòng ban. File CSV có thể mở bằng Excel hoặc Google Sheets.</p>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/export">
            <input type="hidden" name="action" value="csv">

            <div class="form-group">
                <label><i class="fas fa-building"></i> Phòng ban</label>
                <select name="divisionId" class="form-control">
                    <option value="">Tất cả phòng ban</option>
                    <% if (divisions != null) {
                        for (Division div : divisions) { %>
                        <option value="<%= div.getDivisionID() %>"><%= div.getDivisionName() %></option>
                    <% }} %>
                </select>
            </div>

            <div class="date-range">
                <div class="form-group">
                    <label><i class="fas fa-calendar-day"></i> Từ ngày</label>
                    <input type="date" name="startDate" class="form-control"
                           value="<%= LocalDate.now().withDayOfMonth(1).toString() %>" required>
                </div>

                <div class="form-group">
                    <label><i class="fas fa-calendar-day"></i> Đến ngày</label>
                    <input type="date" name="endDate" class="form-control"
                           value="<%= LocalDate.now().toString() %>" required>
                </div>
            </div>

            <button type="submit" class="btn btn-export">
                <i class="fas fa-file-export"></i> Xuất báo cáo CSV
            </button>
        </form>

        <div class="info-box" style="margin-top: 30px; margin-bottom: 0;">
            <p><i class="fas fa-lightbulb"></i> <strong>Mẹo:</strong> Để xem báo cáo theo tháng, chọn ngày đầu tháng và cuối tháng. Để xem toàn công ty, chọn "Tất cả phòng ban".</p>
        </div>
    </div>
</div>
</body>
</html>