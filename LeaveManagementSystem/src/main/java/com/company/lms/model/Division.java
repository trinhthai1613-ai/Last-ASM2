package com.company.lms.model;

import java.sql.Timestamp;

public class Division {
    private Integer divisionID;
    private String divisionCode;
    private String divisionName;
    private String description;
    private Boolean isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Constructors
    public Division() {
    }

    public Division(Integer divisionID, String divisionCode, String divisionName) {
        this.divisionID = divisionID;
        this.divisionCode = divisionCode;
        this.divisionName = divisionName;
    }

    // Getters and Setters
    public Integer getDivisionID() {
        return divisionID;
    }

    public void setDivisionID(Integer divisionID) {
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

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "Division{" +
                "divisionID=" + divisionID +
                ", divisionCode='" + divisionCode + '\'' +
                ", divisionName='" + divisionName + '\'' +
                ", isActive=" + isActive +
                '}';
    }
}