package com.company.lms.model;

import java.sql.Timestamp;

public class AuditLog {
    private long auditID;
    private String tableName;
    private int recordID;
    private String action;
    private Integer employeeID;
    private String employeeName;
    private String employeeCode;
    private String oldValue;
    private String newValue;
    private String iPAddress;
    private String userAgent;
    private Timestamp createdAt;

    // Getters and Setters
    public long getAuditID() { return auditID; }
    public void setAuditID(long auditID) { this.auditID = auditID; }
    
    public String getTableName() { return tableName; }
    public void setTableName(String tableName) { this.tableName = tableName; }
    
    public int getRecordID() { return recordID; }
    public void setRecordID(int recordID) { this.recordID = recordID; }
    
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    
    public Integer getEmployeeID() { return employeeID; }
    public void setEmployeeID(Integer employeeID) { this.employeeID = employeeID; }
    
    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }
    
    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }
    
    public String getOldValue() { return oldValue; }
    public void setOldValue(String oldValue) { this.oldValue = oldValue; }
    
    public String getNewValue() { return newValue; }
    public void setNewValue(String newValue) { this.newValue = newValue; }
    
    public String getIPAddress() { return iPAddress; }
    public void setIPAddress(String iPAddress) { this.iPAddress = iPAddress; }
    
    public String getUserAgent() { return userAgent; }
    public void setUserAgent(String userAgent) { this.userAgent = userAgent; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public String getActionDisplay() {
        if (action == null) return "";
        switch (action) {
            case "INSERT": return "Tạo mới";
            case "UPDATE": return "Cập nhật";
            case "DELETE": return "Xóa";
            default: return action;
        }
    }
}