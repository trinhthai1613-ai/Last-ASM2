package com.company.lms.model;

public class Role {
    private int roleID;
    private String roleCode;
    private String roleName;
    private String description;
    private int level;
    private boolean isActive;
    
    public Role() {
    }
    
    public int getRoleID() {
        return roleID;
    }
    
    public void setRoleID(int roleID) {
        this.roleID = roleID;
    }
    
    public String getRoleCode() {
        return roleCode;
    }
    
    public void setRoleCode(String roleCode) {
        this.roleCode = roleCode;
    }
    
    public String getRoleName() {
        return roleName;
    }
    
    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public int getLevel() {
        return level;
    }
    
    public void setLevel(int level) {
        this.level = level;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
    }
}