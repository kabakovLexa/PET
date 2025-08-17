package com.testproject.user.metrics;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class UserMetrics {
    
    private final Counter userCreatedCounter;
    private final Counter userUpdatedCounter;
    private final Counter userDeletedCounter;
    private final Timer userCreationTimer;
    
    @Autowired
    public UserMetrics(MeterRegistry meterRegistry) {
        this.userCreatedCounter = Counter.builder("users_created_total")
                .description("Total number of users created")
                .tag("service", "user-service")
                .register(meterRegistry);
                
        this.userUpdatedCounter = Counter.builder("users_updated_total")
                .description("Total number of users updated")
                .tag("service", "user-service")
                .register(meterRegistry);
                
        this.userDeletedCounter = Counter.builder("users_deleted_total")
                .description("Total number of users deleted")
                .tag("service", "user-service")
                .register(meterRegistry);
                
        this.userCreationTimer = Timer.builder("user_creation_duration")
                .description("Time taken to create a user")
                .tag("service", "user-service")
                .register(meterRegistry);
    }
    
    public void incrementUserCreated() {
        userCreatedCounter.increment();
    }
    
    public void incrementUserUpdated() {
        userUpdatedCounter.increment();
    }
    
    public void incrementUserDeleted() {
        userDeletedCounter.increment();
    }
    
    public Timer.Sample startUserCreationTimer() {
        return Timer.start(userCreationTimer);
    }
    
    public void recordUserCreationTime(Timer.Sample sample) {
        sample.stop(userCreationTimer);
    }
}