package com.company.lms.service;

import com.company.lms.dao.LeaveRequestDAO;
import com.company.lms.dao.LeaveTypeDAO;
import com.company.lms.model.LeaveRequest;
import com.company.lms.model.LeaveType;
import com.company.lms.util.DateUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public class LeaveRequestService {
    private static final Logger logger = LoggerFactory.getLogger(LeaveRequestService.class);
    private LeaveRequestDAO leaveRequestDAO;
    private LeaveTypeDAO leaveTypeDAO;
    
    public LeaveRequestService() {
        this.leaveRequestDAO = new LeaveRequestDAO();
        this.leaveTypeDAO = new LeaveTypeDAO();
    }
    
    public boolean createLeaveRequest(LeaveRequest request) {
        if (request == null) {
            return false;
        }
        
        if (request.getStartDate().isAfter(request.getEndDate())) {
            logger.warn("Start date is after end date");
            return false;
        }
        
        if (request.getStartDate().isBefore(LocalDate.now())) {
            logger.warn("Start date is in the past");
            return false;
        }
        
        int workingDays = DateUtils.calculateWorkingDays(request.getStartDate(), request.getEndDate());
        request.setTotalDays(BigDecimal.valueOf(workingDays));
        
        return leaveRequestDAO.createLeaveRequest(request);
    }
    
    public List<LeaveRequest> getLeaveRequests(int employeeID, String status) {
        return leaveRequestDAO.getLeaveRequests(employeeID, status);
    }
    
    public LeaveRequest getLeaveRequestById(int requestID) {
        return leaveRequestDAO.getLeaveRequestById(requestID);
    }
    
    public boolean approveLeaveRequest(int requestID, int processedBy, String note) {
        return leaveRequestDAO.processLeaveRequest(requestID, processedBy, "APPROVE", note);
    }
    
    public boolean rejectLeaveRequest(int requestID, int processedBy, String note) {
        return leaveRequestDAO.processLeaveRequest(requestID, processedBy, "REJECT", note);
    }
    
    public List<LeaveType> getAllLeaveTypes() {
        return leaveTypeDAO.getAllLeaveTypes();
    }
    
    public boolean canEmployeeCreateRequest(int employeeID, LocalDate startDate, LocalDate endDate) {
        // Check for overlapping requests
        List<LeaveRequest> existingRequests = leaveRequestDAO.getLeaveRequests(employeeID, null);
        
        for (LeaveRequest existing : existingRequests) {
            if ("Approved".equals(existing.getStatus()) || "InProgress".equals(existing.getStatus())) {
                if (isDateOverlapping(startDate, endDate, existing.getStartDate(), existing.getEndDate())) {
                    logger.warn("Overlapping leave request found for employee {}", employeeID);
                    return false;
                }
            }
        }
        
        return true;
    }
    
    private boolean isDateOverlapping(LocalDate start1, LocalDate end1, LocalDate start2, LocalDate end2) {
        return !start1.isAfter(end2) && !end1.isBefore(start2);
    }
}