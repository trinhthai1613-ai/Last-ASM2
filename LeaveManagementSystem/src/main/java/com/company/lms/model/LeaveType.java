package com.company.lms.model;

public class LeaveType {
    private int leaveTypeID;
    private String leaveTypeCode;
    private String leaveTypeName;
    private String description;
    private int defaultDaysPerYear;
    private boolean requiresApproval;
    private boolean isPaid;
    private boolean allowCustomReason;
    private boolean isActive;
    
    public LeaveType() {
    }
    
    public int getLeaveTypeID() {
        return leaveTypeID;
    }
    
    public void setLeaveTypeID(int leaveTypeID) {
        this.leaveTypeID = leaveTypeID;
    }
    
    public String getLeaveTypeCode() {
        return leaveTypeCode;
    }
    
    public void setLeaveTypeCode(String leaveTypeCode) {
        this.leaveTypeCode = leaveTypeCode;
    }
    
    public String getLeaveTypeName() {
        return leaveTypeName;
    }
    
    public void setLeaveTypeName(String leaveTypeName) {
        this.leaveTypeName = leaveTypeName;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public int getDefaultDaysPerYear() {
        return defaultDaysPerYear;
    }
    
    public void setDefaultDaysPerYear(int defaultDaysPerYear) {
        this.defaultDaysPerYear = defaultDaysPerYear;
    }
    
    public boolean isRequiresApproval() {
        return requiresApproval;
    }
    
    public void setRequiresApproval(boolean requiresApproval) {
        this.requiresApproval = requiresApproval;
    }
    
    public boolean isPaid() {
        return isPaid;
    }
    
    public void setPaid(boolean paid) {
        isPaid = paid;
    }
    
    public boolean isAllowCustomReason() {
        return allowCustomReason;
    }
    
    public void setAllowCustomReason(boolean allowCustomReason) {
        this.allowCustomReason = allowCustomReason;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
    }
}