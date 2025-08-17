package com.testproject.user.kafka;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class ProductEventConsumer {
    
    private static final Logger logger = LoggerFactory.getLogger(ProductEventConsumer.class);
    private final ObjectMapper objectMapper;
    
    public ProductEventConsumer() {
        this.objectMapper = new ObjectMapper();
        this.objectMapper.registerModule(new JavaTimeModule());
    }
    
    @KafkaListener(topics = "product-events", groupId = "user-service-group")
    public void handleProductEvent(String productEventJson) {
        try {
            Map<String, Object> productEvent = objectMapper.readValue(productEventJson, Map.class);
            String eventType = (String) productEvent.get("eventType");
            String productName = (String) productEvent.get("productName");
            String category = (String) productEvent.get("category");
            
            logger.info("Received product event in User Service: {} for product: {} in category: {}", 
                       eventType, productName, category);
            
            // Here you could implement business logic based on product events
            // For example: notify users about new products in their preferred categories
            switch (eventType) {
                case "PRODUCT_CREATED":
                    logger.info("New product available: {}", productName);
                    break;
                case "PRODUCT_UPDATED":
                    logger.info("Product updated: {}", productName);
                    break;
                case "PRODUCT_DELETED":
                    logger.info("Product removed: {}", productName);
                    break;
                default:
                    logger.warn("Unknown event type: {}", eventType);
            }
            
        } catch (Exception e) {
            logger.error("Error processing product event: {}", productEventJson, e);
        }
    }
}