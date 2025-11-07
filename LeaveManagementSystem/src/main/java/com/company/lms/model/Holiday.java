package com.company.lms.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class Holiday {
    private int holidayID;
    private String holidayName;
    private LocalDate holidayDate;
    private int year;
    private boolean isRecurring;
    private String description;
    private LocalDateTime createdAt;
    
    // Getters & Setters
    public int getHolidayID() { return holidayID; }
    public void setHolidayID(int holidayID) { this.holidayID = holidayID; }
    
    public String getHolidayName() { return holidayName; }
    public void setHolidayName(String holidayName) { this.holidayName = holidayName; }
    
    public LocalDate getHolidayDate() { return holidayDate; }
    public void setHolidayDate(LocalDate holidayDate) { this.holidayDate = holidayDate; }
    
    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }
    
    public boolean isRecurring() { return isRecurring; }
    public void setRecurring(boolean recurring) { isRecurring = recurring; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}