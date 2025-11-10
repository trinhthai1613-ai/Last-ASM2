package com.company.lms.model;

import java.sql.Timestamp;

public class AuditLog {
    private Long auditID;
    private String tableName;
    private int recordID;
    private String action;
    private String actionDisplay;
    private Integer employeeID;
    private String employeeName;
    private String employeeCode;
    private Integer divisionID;
    private String divisionName;
    private String divisionCode;
    private String oldValue;
    private String newValue;
    private String note;
    private String iPAddress;
    private String userAgent;
    private Timestamp createdAt;

    // Getters & Setters
    public Long getAuditID() { return auditID; }
    public void setAuditID(Long auditID) { this.auditID = auditID; }
    
    public String getTableName() { return tableName; }
    public void setTableName(String tableName) { this.tableName = tableName; }
    
    public int getRecordID() { return recordID; }
    public void setRecordID(int recordID) { this.recordID = recordID; }
    
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    
    public String getActionDisplay() { return actionDisplay; }
    public void setActionDisplay(String actionDisplay) { this.actionDisplay = actionDisplay; }
    
    public Integer getEmployeeID() { return employeeID; }
    public void setEmployeeID(Integer employeeID) { this.employeeID = employeeID; }
    
    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }
    
    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }
    
    public Integer getDivisionID() { return divisionID; }
    public void setDivisionID(Integer divisionID) { this.divisionID = divisionID; }
    
    public String getDivisionName() { return divisionName; }
    public void setDivisionName(String divisionName) { this.divisionName = divisionName; }
    
    public String getDivisionCode() { return divisionCode; }
    public void setDivisionCode(String divisionCode) { this.divisionCode = divisionCode; }
    
    public String getOldValue() { return oldValue; }
    public void setOldValue(String oldValue) { this.oldValue = oldValue; }
    
    public String getNewValue() { return newValue; }
    public void setNewValue(String newValue) { this.newValue = newValue; }
    
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    
    public String getIPAddress() { return iPAddress; }
    public void setIPAddress(String iPAddress) { this.iPAddress = iPAddress; }
    
    public String getUserAgent() { return userAgent; }
    public void setUserAgent(String userAgent) { this.userAgent = userAgent; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    /**
     * Lấy màu badge theo action
     */
    public String getActionBadgeClass() {
        if (action == null) return "action-update";
        
        switch (action) {
            case "APPROVE": return "action-approve";
            case "REJECT": return "action-reject";
            case "UPDATE": return "action-update";
            default: return "action-update";
        }
    }
}