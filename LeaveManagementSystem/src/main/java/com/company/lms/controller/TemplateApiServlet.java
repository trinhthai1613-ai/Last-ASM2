package com.company.lms.controller;

import com.company.lms.dao.LeaveRequestDAO;
import com.company.lms.model.LeaveReasonTemplate;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.json.JSONArray;
import org.json.JSONObject;
import java.io.IOException;
import java.util.List;

public class TemplateApiServlet extends HttpServlet {
    private LeaveRequestDAO leaveRequestDAO;
    
    @Override
    public void init() throws ServletException {
        leaveRequestDAO = new LeaveRequestDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String leaveTypeIdParam = request.getParameter("leaveTypeId");
        
        try {
            int leaveTypeId = Integer.parseInt(leaveTypeIdParam);
            List<LeaveReasonTemplate> templates = leaveRequestDAO.getTemplatesByLeaveType(leaveTypeId);
            
            JSONArray jsonArray = new JSONArray();
            for (LeaveReasonTemplate tmpl : templates) {
                JSONObject json = new JSONObject();
                json.put("templateID", tmpl.getTemplateID());
                json.put("reasonText", tmpl.getReasonText());
                json.put("description", tmpl.getDescription());
                jsonArray.put(json);
            }
            
            response.getWriter().write(jsonArray.toString());
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("[]");
        }
    }
}