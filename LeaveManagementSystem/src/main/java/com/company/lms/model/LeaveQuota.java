package com.company.lms.model;

import java.time.LocalDateTime;

public class LeaveQuota {
    private int quotaID;
    private int employeeID;
    private int leaveTypeID;
    private int year;
    private double totalDays;
    private double usedDays;
    private double remainingDays;
    private double carryOverDays;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Thông tin bổ sung từ JOIN
    private String leaveTypeName;
    private String leaveTypeCode;
    private String employeeName;
    
    // Constructor
    public LeaveQuota() {}
    
    // Getters & Setters
    public int getQuotaID() { return quotaID; }
    public void setQuotaID(int quotaID) { this.quotaID = quotaID; }
    
    public int getEmployeeID() { return employeeID; }
    public void setEmployeeID(int employeeID) { this.employeeID = employeeID; }
    
    public int getLeaveTypeID() { return leaveTypeID; }
    public void setLeaveTypeID(int leaveTypeID) { this.leaveTypeID = leaveTypeID; }
    
    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }
    
    public double getTotalDays() { return totalDays; }
    public void setTotalDays(double totalDays) { this.totalDays = totalDays; }
    
    public double getUsedDays() { return usedDays; }
    public void setUsedDays(double usedDays) { this.usedDays = usedDays; }
    
    public double getRemainingDays() { return remainingDays; }
    public void setRemainingDays(double remainingDays) { this.remainingDays = remainingDays; }
    
    public double getCarryOverDays() { return carryOverDays; }
    public void setCarryOverDays(double carryOverDays) { this.carryOverDays = carryOverDays; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    public String getLeaveTypeName() { return leaveTypeName; }
    public void setLeaveTypeName(String leaveTypeName) { this.leaveTypeName = leaveTypeName; }
    
    public String getLeaveTypeCode() { return leaveTypeCode; }
    public void setLeaveTypeCode(String leaveTypeCode) { this.leaveTypeCode = leaveTypeCode; }
    
    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }
}