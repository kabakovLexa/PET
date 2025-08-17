package com.testproject.user.event;

import java.time.LocalDateTime;

public class UserEvent {
    private String eventType;
    private Long userId;
    private String userName;
    private String userEmail;
    private String department;
    private LocalDateTime timestamp;
    
    // Constructors
    public UserEvent() {
        this.timestamp = LocalDateTime.now();
    }
    
    public UserEvent(String eventType, Long userId, String userName, String userEmail, String department) {
        this.eventType = eventType;
        this.userId = userId;
        this.userName = userName;
        this.userEmail = userEmail;
        this.department = department;
        this.timestamp = LocalDateTime.now();
    }
    
    // Getters and Setters
    public String getEventType() {
        return eventType;
    }
    
    public void setEventType(String eventType) {
        this.eventType = eventType;
    }
    
    public Long getUserId() {
        return userId;
    }
    
    public void setUserId(Long userId) {
        this.userId = userId;
    }
    
    public String getUserName() {
        return userName;
    }
    
    public void setUserName(String userName) {
        this.userName = userName;
    }
    
    public String getUserEmail() {
        return userEmail;
    }
    
    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }
    
    public String getDepartment() {
        return department;
    }
    
    public void setDepartment(String department) {
        this.department = department;
    }
    
    public LocalDateTime getTimestamp() {
        return timestamp;
    }
    
    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
    
    @Override
    public String toString() {
        return "UserEvent{" +
               "eventType='" + eventType + '\'' +
               ", userId=" + userId +
               ", userName='" + userName + '\'' +
               ", userEmail='" + userEmail + '\'' +
               ", department='" + department + '\'' +
               ", timestamp=" + timestamp +
               '}';
    }
}