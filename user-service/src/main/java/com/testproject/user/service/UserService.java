package com.testproject.user.service;

import com.testproject.user.kafka.UserEventPublisher;
import com.testproject.user.metrics.UserMetrics;
import com.testproject.user.model.User;
import com.testproject.user.repository.UserRepository;
import io.micrometer.core.instrument.Timer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class UserService {
    
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private UserEventPublisher userEventPublisher;
    
    public List<User> getAllUsers() {
        logger.debug("Fetching all users");
        return userRepository.findAll();
    }
    
    public Optional<User> getUserById(Long id) {
        logger.debug("Fetching user by id: {}", id);
        return userRepository.findById(id);
    }
    
    public Optional<User> getUserByEmail(String email) {
        logger.debug("Fetching user by email: {}", email);
        return userRepository.findByEmail(email);
    }
    
    public User createUser(User user) {
        logger.info("Creating new user: {}", user.getEmail());
        
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("User with email " + user.getEmail() + " already exists");
        }
        
        User savedUser = userRepository.save(user);
        logger.info("User created successfully: {}", savedUser);
        
        // Publish Kafka event
        userEventPublisher.publishUserCreated(
            savedUser.getId(), 
            savedUser.getName(), 
            savedUser.getEmail(), 
            savedUser.getDepartment()
        );
        
        return savedUser;
    }
    
    public User updateUser(Long id, User userDetails) {
        logger.info("Updating user with id: {}", id);
        
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + id));
        
        user.setName(userDetails.getName());
        user.setEmail(userDetails.getEmail());
        user.setDepartment(userDetails.getDepartment());
        
        User updatedUser = userRepository.save(user);
        logger.info("User updated successfully: {}", updatedUser);
        
        // Publish Kafka event
        userEventPublisher.publishUserUpdated(
            updatedUser.getId(), 
            updatedUser.getName(), 
            updatedUser.getEmail(), 
            updatedUser.getDepartment()
        );
        
        return updatedUser;
    }
    
    public void deleteUser(Long id) {
        logger.info("Deleting user with id: {}", id);
        
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + id));
        
        // Publish Kafka event before deletion
        userEventPublisher.publishUserDeleted(
            user.getId(), 
            user.getName(), 
            user.getEmail(), 
            user.getDepartment()
        );
        
        userRepository.delete(user);
        logger.info("User deleted successfully: {}", user.getEmail());
    }
    
    public List<User> getUsersByDepartment(String department) {
        logger.debug("Fetching users by department: {}", department);
        return userRepository.findByDepartment(department);
    }
}