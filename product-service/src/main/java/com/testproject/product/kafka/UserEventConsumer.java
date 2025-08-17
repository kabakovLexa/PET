package com.testproject.product.kafka;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class UserEventConsumer {
    
    private static final Logger logger = LoggerFactory.getLogger(UserEventConsumer.class);
    private final ObjectMapper objectMapper;
    
    public UserEventConsumer() {
        this.objectMapper = new ObjectMapper();
        this.objectMapper.registerModule(new JavaTimeModule());
    }
    
    @KafkaListener(topics = "user-events", groupId = "product-service-group")
    public void handleUserEvent(String userEventJson) {
        try {
            Map<String, Object> userEvent = objectMapper.readValue(userEventJson, Map.class);
            String eventType = (String) userEvent.get("eventType");
            String userName = (String) userEvent.get("userName");
            String department = (String) userEvent.get("department");
            
            logger.info("Received user event in Product Service: {} for user: {} from department: {}", 
                       eventType, userName, department);
            
            // Here you could implement business logic based on user events
            // For example: update user-specific product recommendations
            switch (eventType) {
                case "USER_CREATED":
                    logger.info("New user registered: {} from {}", userName, department);
                    // Could trigger welcome product recommendations
                    break;
                case "USER_UPDATED":
                    logger.info("User profile updated: {}", userName);
                    // Could update product preferences
                    break;
                case "USER_DELETED":
                    logger.info("User removed: {}", userName);
                    // Could clean up user-specific data
                    break;
                default:
                    logger.warn("Unknown event type: {}", eventType);
            }
            
        } catch (Exception e) {
            logger.error("Error processing user event: {}", userEventJson, e);
        }
    }
}