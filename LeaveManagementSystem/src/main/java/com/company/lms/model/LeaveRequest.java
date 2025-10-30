package com.company.lms.model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.math.BigDecimal;

public class LeaveRequest {
    private int requestID;
    private String requestCode;
    private int employeeID;
    private String employeeName;
    private int leaveTypeID;
    private String leaveTypeName;
    private LocalDate startDate;
    private LocalDate endDate;
    private BigDecimal totalDays;
    private Integer reasonTemplateID;
    private String customReason;
    private String reason;
    private String status;
    private Integer processedBy;
    private String processedByName;
    private LocalDateTime processedDate;
    private String processedNote;
    private String attachmentPath;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public LeaveRequest() {
    }
    
    // Getters and Setters
    public int getRequestID() {
        return requestID;
    }
    
    public void setRequestID(int requestID) {
        this.requestID = requestID;
    }
    
    public String getRequestCode() {
        return requestCode;
    }
    
    public void setRequestCode(String requestCode) {
        this.requestCode = requestCode;
    }
    
    public int getEmployeeID() {
        return employeeID;
    }
    
    public void setEmployeeID(int employeeID) {
        this.employeeID = employeeID;
    }
    
    public String getEmployeeName() {
        return employeeName;
    }
    
    public void setEmployeeName(String employeeName) {
        this.employeeName = employeeName;
    }
    
    public int getLeaveTypeID() {
        return leaveTypeID;
    }
    
    public void setLeaveTypeID(int leaveTypeID) {
        this.leaveTypeID = leaveTypeID;
    }
    
    public String getLeaveTypeName() {
        return leaveTypeName;
    }
    
    public void setLeaveTypeName(String leaveTypeName) {
        this.leaveTypeName = leaveTypeName;
    }
    
    public LocalDate getStartDate() {
        return startDate;
    }
    
    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }
    
    public LocalDate getEndDate() {
        return endDate;
    }
    
    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }
    
    public BigDecimal getTotalDays() {
        return totalDays;
    }
    
    public void setTotalDays(BigDecimal totalDays) {
        this.totalDays = totalDays;
    }
    
    public Integer getReasonTemplateID() {
        return reasonTemplateID;
    }
    
    public void setReasonTemplateID(Integer reasonTemplateID) {
        this.reasonTemplateID = reasonTemplateID;
    }
    
    public String getCustomReason() {
        return customReason;
    }
    
    public void setCustomReason(String customReason) {
        this.customReason = customReason;
    }
    
    public String getReason() {
        return reason;
    }
    
    public void setReason(String reason) {
        this.reason = reason;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Integer getProcessedBy() {
        return processedBy;
    }
    
    public void setProcessedBy(Integer processedBy) {
        this.processedBy = processedBy;
    }
    
    public String getProcessedByName() {
        return processedByName;
    }
    
    public void setProcessedByName(String processedByName) {
        this.processedByName = processedByName;
    }
    
    public LocalDateTime getProcessedDate() {
        return processedDate;
    }
    
    public void setProcessedDate(LocalDateTime processedDate) {
        this.processedDate = processedDate;
    }
    
    public String getProcessedNote() {
        return processedNote;
    }
    
    public void setProcessedNote(String processedNote) {
        this.processedNote = processedNote;
    }
    
    public String getAttachmentPath() {
        return attachmentPath;
    }
    
    public void setAttachmentPath(String attachmentPath) {
        this.attachmentPath = attachmentPath;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public String getStatusDisplay() {
        switch (status) {
            case "InProgress":
                return "Đang xử lý";
            case "Approved":
                return "Đã duyệt";
            case "Rejected":
                return "Từ chối";
            case "Cancelled":
                return "Đã hủy";
            default:
                return status;
        }
    }
    
    @Override
    public String toString() {
        return "LeaveRequest{" +
                "requestID=" + requestID +
                ", requestCode='" + requestCode + '\'' +
                ", employeeName='" + employeeName + '\'' +
                ", status='" + status + '\'' +
                ", startDate=" + startDate +
                ", endDate=" + endDate +
                '}';
    }
}