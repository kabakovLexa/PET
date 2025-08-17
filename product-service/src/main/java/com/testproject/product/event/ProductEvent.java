package com.testproject.product.event;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class ProductEvent {
    private String eventType;
    private Long productId;
    private String productName;
    private String description;
    private BigDecimal price;
    private String category;
    private Integer quantity;
    private Boolean active;
    private LocalDateTime timestamp;
    
    // Constructors
    public ProductEvent() {
        this.timestamp = LocalDateTime.now();
    }
    
    public ProductEvent(String eventType, Long productId, String productName, 
                       String description, BigDecimal price, String category, 
                       Integer quantity, Boolean active) {
        this.eventType = eventType;
        this.productId = productId;
        this.productName = productName;
        this.description = description;
        this.price = price;
        this.category = category;
        this.quantity = quantity;
        this.active = active;
        this.timestamp = LocalDateTime.now();
    }
    
    // Getters and Setters
    public String getEventType() {
        return eventType;
    }
    
    public void setEventType(String eventType) {
        this.eventType = eventType;
    }
    
    public Long getProductId() {
        return productId;
    }
    
    public void setProductId(Long productId) {
        this.productId = productId;
    }
    
    public String getProductName() {
        return productName;
    }
    
    public void setProductName(String productName) {
        this.productName = productName;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public BigDecimal getPrice() {
        return price;
    }
    
    public void setPrice(BigDecimal price) {
        this.price = price;
    }
    
    public String getCategory() {
        return category;
    }
    
    public void setCategory(String category) {
        this.category = category;
    }
    
    public Integer getQuantity() {
        return quantity;
    }
    
    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }
    
    public Boolean getActive() {
        return active;
    }
    
    public void setActive(Boolean active) {
        this.active = active;
    }
    
    public LocalDateTime getTimestamp() {
        return timestamp;
    }
    
    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
    
    @Override
    public String toString() {
        return "ProductEvent{" +
               "eventType='" + eventType + '\'' +
               ", productId=" + productId +
               ", productName='" + productName + '\'' +
               ", category='" + category + '\'' +
               ", price=" + price +
               ", timestamp=" + timestamp +
               '}';
    }
}