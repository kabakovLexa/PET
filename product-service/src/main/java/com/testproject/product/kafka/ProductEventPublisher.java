package com.testproject.product.kafka;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.testproject.product.event.ProductEvent;
import com.testproject.product.model.Product;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
public class ProductEventPublisher {
    
    private static final Logger logger = LoggerFactory.getLogger(ProductEventPublisher.class);
    private static final String TOPIC_NAME = "product-events";
    
    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;
    
    private final ObjectMapper objectMapper;
    
    public ProductEventPublisher() {
        this.objectMapper = new ObjectMapper();
        this.objectMapper.registerModule(new JavaTimeModule());
    }
    
    public void publishProductEvent(ProductEvent productEvent) {
        try {
            String eventJson = objectMapper.writeValueAsString(productEvent);
            kafkaTemplate.send(TOPIC_NAME, productEvent.getProductId().toString(), eventJson);
            logger.info("Published product event: {}", productEvent);
        } catch (JsonProcessingException e) {
            logger.error("Error publishing product event: {}", productEvent, e);
        }
    }
    
    public void publishProductCreated(Product product) {
        ProductEvent event = new ProductEvent(
            "PRODUCT_CREATED",
            product.getId(),
            product.getName(),
            product.getDescription(),
            product.getPrice(),
            product.getCategory(),
            product.getQuantity(),
            product.getActive()
        );
        publishProductEvent(event);
    }
    
    public void publishProductUpdated(Product product) {
        ProductEvent event = new ProductEvent(
            "PRODUCT_UPDATED",
            product.getId(),
            product.getName(),
            product.getDescription(),
            product.getPrice(),
            product.getCategory(),
            product.getQuantity(),
            product.getActive()
        );
        publishProductEvent(event);
    }
    
    public void publishProductDeleted(Product product) {
        ProductEvent event = new ProductEvent(
            "PRODUCT_DELETED",
            product.getId(),
            product.getName(),
            product.getDescription(),
            product.getPrice(),
            product.getCategory(),
            product.getQuantity(),
            product.getActive()
        );
        publishProductEvent(event);
    }
}