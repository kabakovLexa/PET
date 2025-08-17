package com.testproject.user.kafka;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.testproject.user.event.UserEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
public class UserEventPublisher {
    
    private static final Logger logger = LoggerFactory.getLogger(UserEventPublisher.class);
    private static final String TOPIC_NAME = "user-events";
    
    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;
    
    private final ObjectMapper objectMapper;
    
    public UserEventPublisher() {
        this.objectMapper = new ObjectMapper();
        this.objectMapper.registerModule(new JavaTimeModule());
    }
    
    public void publishUserEvent(UserEvent userEvent) {
        try {
            String eventJson = objectMapper.writeValueAsString(userEvent);
            kafkaTemplate.send(TOPIC_NAME, userEvent.getUserId().toString(), eventJson);
            logger.info("Published user event: {}", userEvent);
        } catch (JsonProcessingException e) {
            logger.error("Error publishing user event: {}", userEvent, e);
        }
    }
    
    public void publishUserCreated(Long userId, String userName, String userEmail, String department) {
        UserEvent event = new UserEvent("USER_CREATED", userId, userName, userEmail, department);
        publishUserEvent(event);
    }
    
    public void publishUserUpdated(Long userId, String userName, String userEmail, String department) {
        UserEvent event = new UserEvent("USER_UPDATED", userId, userName, userEmail, department);
        publishUserEvent(event);
    }
    
    public void publishUserDeleted(Long userId, String userName, String userEmail, String department) {
        UserEvent event = new UserEvent("USER_DELETED", userId, userName, userEmail, department);
        publishUserEvent(event);
    }
}