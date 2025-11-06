package com.company.lms.model;

import java.time.LocalDateTime;

public class LeaveReasonTemplate {
    private int templateID;
    private int leaveTypeID;
    private String reasonText;
    private String description;
    private boolean isActive;
    private int usageCount;
    private LocalDateTime createdAt;
    
    // Getters & Setters
    public int getTemplateID() { return templateID; }
    public void setTemplateID(int templateID) { this.templateID = templateID; }
    
    public int getLeaveTypeID() { return leaveTypeID; }
    public void setLeaveTypeID(int leaveTypeID) { this.leaveTypeID = leaveTypeID; }
    
    public String getReasonText() { return reasonText; }
    public void setReasonText(String reasonText) { this.reasonText = reasonText; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    
    public int getUsageCount() { return usageCount; }
    public void setUsageCount(int usageCount) { this.usageCount = usageCount; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}