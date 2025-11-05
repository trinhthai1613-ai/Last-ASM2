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
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
            background: #ffffff;
            min-height: 100vh;
            color: #1d1d1f;
            padding: 20px;
            -webkit-font-smoothing: antialiased;
        }
        .container { max-width: 900px; margin: 0 auto; }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 40px;
        }
        .header h1 {
            font-size: 28px;
            font-weight: 600;
            letter-spacing: -0.02em;
        }
        .btn {
            background: #000000;
            border: none;
            border-radius: 980px;
            padding: 10px 22px;
            color: #fff;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
            letter-spacing: -0.01em;
        }
        .btn:hover {
            transform: scale(1.02);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        .btn-secondary {
            background: #f5f5f7;
            border: 1px solid rgba(0, 0, 0, 0.1);
            color: #1d1d1f;
        }
        .btn-secondary:hover { background: #e8e8ed; }

        .export-card {
            background: #ffffff;
            border-radius: 18px;
            padding: 40px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            box-shadow: 0 2px 16px rgba(0, 0, 0, 0.08);
        }
        .card-title {
            font-size: 22px;
            font-weight: 600;
            margin-bottom: 30px;
            letter-spacing: -0.02em;
        }
        .form-group {
            margin-bottom: 24px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #1d1d1f;
            font-size: 14px;
            font-weight: 500;
        }
        .form-control {
            width: 100%;
            background: #f5f5f7;
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 12px;
            padding: 12px 16px;
            color: #1d1d1f;
            font-size: 14px;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
        }
        .form-control:focus {
            outline: none;
            border-color: #000000;
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(0, 0, 0, 0.06);
        }
        .date-range {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        .info-box {
            background: #f5f5f7;
            border-radius: 12px;
            padding: 16px;
            margin-bottom: 24px;
        }
        .info-box i { color: #000000; margin-right: 10px; }
        .info-box p { color: #6e6e73; line-height: 1.6; }

        .btn-export {
            width: 100%;
            padding: 14px;
            font-size: 16px;
            background: #34c759;
            color: #fff;
        }
        .btn-export:hover {
            box-shadow: 0 6px 16px rgba(52, 199, 89, 0.3);
        }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h1>⬇️ Xuất báo cáo</h1>
        <a href="${pageContext.request.contextPath}/agenda" class="btn btn-secondary">
            ← Quay lại
        </a>
    </div>

    <div class="export-card">
        <div class="card-title">
            📊 Xuất dữ liệu CSV
        </div>

        <div class="info-box">
            <p><strong>ℹ️ Thông tin:</strong> Chức năng này cho phép bạn xuất toàn bộ dữ liệu lịch nghỉ phép theo khoảng thời gian và phòng ban. File CSV có thể mở bằng Excel hoặc Google Sheets.</p>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/export">
            <input type="hidden" name="action" value="csv">

            <div class="form-group">
                <label>🏢 Phòng ban</label>
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
                    <label>📅 Từ ngày</label>
                    <input type="date" name="startDate" class="form-control"
                           value="<%= LocalDate.now().withDayOfMonth(1).toString() %>" required>
                </div>

                <div class="form-group">
                    <label>📅 Đến ngày</label>
                    <input type="date" name="endDate" class="form-control"
                           value="<%= LocalDate.now().toString() %>" required>
                </div>
            </div>

            <button type="submit" class="btn btn-export">
                📤 Xuất báo cáo CSV
            </button>
        </form>

        <div class="info-box" style="margin-top: 30px; margin-bottom: 0;">
            <p><strong>💡 Mẹo:</strong> Để xem báo cáo theo tháng, chọn ngày đầu tháng và cuối tháng. Để xem toàn công ty, chọn "Tất cả phòng ban".</p>
        </div>
    </div>
</div>
</body>
</html>