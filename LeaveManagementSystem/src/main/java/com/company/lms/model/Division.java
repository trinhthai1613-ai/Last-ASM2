package com.company.lms.model;

public class Division {
    private int divisionID;
    private String divisionCode;
    private String divisionName;
    private String description;
    private boolean isActive;
    
    public Division() {
    }
    
    public int getDivisionID() {
        return divisionID;
    }
    
    public void setDivisionID(int divisionID) {
        this.divisionID = divisionID;
    }
    
    public String getDivisionCode() {
        return divisionCode;
    }
    
    public void setDivisionCode(String divisionCode) {
        this.divisionCode = divisionCode;
    }
    
    public String getDivisionName() {
        return divisionName;
    }
    
    public void setDivisionName(String divisionName) {
        this.divisionName = divisionName;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
    }
}