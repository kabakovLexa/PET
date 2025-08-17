package com.testproject.product.metrics;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class ProductMetrics {
    
    private final Counter productCreatedCounter;
    private final Counter productUpdatedCounter;
    private final Counter productDeletedCounter;
    private final Timer productCreationTimer;
    private final MeterRegistry meterRegistry;
    
    @Autowired
    public ProductMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        
        this.productCreatedCounter = Counter.builder("products_created_total")
                .description("Total number of products created")
                .tag("service", "product-service")
                .register(meterRegistry);
                
        this.productUpdatedCounter = Counter.builder("products_updated_total")
                .description("Total number of products updated")
                .tag("service", "product-service")
                .register(meterRegistry);
                
        this.productDeletedCounter = Counter.builder("products_deleted_total")
                .description("Total number of products deleted")
                .tag("service", "product-service")
                .register(meterRegistry);
                
        this.productCreationTimer = Timer.builder("product_creation_duration")
                .description("Time taken to create a product")
                .tag("service", "product-service")
                .register(meterRegistry);
    }
    
    public void incrementProductCreated() {
        productCreatedCounter.increment();
    }
    
    public void incrementProductUpdated() {
        productUpdatedCounter.increment();
    }
    
    public void incrementProductDeleted() {
        productDeletedCounter.increment();
    }
    
    public Timer.Sample startProductCreationTimer() {
        return Timer.start(productCreationTimer);
    }
    
    public void recordProductCreationTime(Timer.Sample sample) {
        sample.stop(productCreationTimer);
    }
    
    public void registerActiveProductsGauge(java.util.function.Supplier<Number> valueSupplier) {
        Gauge.builder("products_active_total")
                .description("Total number of active products")
                .tag("service", "product-service")
                .register(meterRegistry, valueSupplier);
    }
}