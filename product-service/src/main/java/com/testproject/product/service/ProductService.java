package com.testproject.product.service;

import com.testproject.product.kafka.ProductEventPublisher;
import com.testproject.product.metrics.ProductMetrics;
import com.testproject.product.model.Product;
import com.testproject.product.repository.ProductRepository;
import io.micrometer.core.instrument.Timer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
public class ProductService {
    
    private static final Logger logger = LoggerFactory.getLogger(ProductService.class);
    
    @Autowired
    private ProductRepository productRepository;
    
    @Autowired
    private ProductEventPublisher productEventPublisher;
    
    @Autowired
    private ProductMetrics productMetrics;
    
    public List<Product> getAllProducts() {
        logger.debug("Fetching all products");
        return productRepository.findAll();
    }
    
    public List<Product> getActiveProducts() {
        logger.debug("Fetching active products");
        return productRepository.findByActiveTrue();
    }
    
    public Optional<Product> getProductById(Long id) {
        logger.debug("Fetching product by id: {}", id);
        return productRepository.findById(id);
    }
    
    public List<Product> getProductsByCategory(String category) {
        logger.debug("Fetching products by category: {}", category);
        return productRepository.findByCategory(category);
    }
    
    public List<Product> getActiveProductsByCategory(String category) {
        logger.debug("Fetching active products by category: {}", category);
        return productRepository.findByCategoryAndActiveTrue(category);
    }
    
    public List<Product> searchProductsByName(String name) {
        logger.debug("Searching products by name: {}", name);
        return productRepository.findByNameContainingIgnoreCase(name);
    }
    
    public List<Product> getProductsByPriceRange(BigDecimal minPrice, BigDecimal maxPrice) {
        logger.debug("Fetching products by price range: {} - {}", minPrice, maxPrice);
        return productRepository.findByPriceBetween(minPrice, maxPrice);
    }
    
    public Product createProduct(Product product) {
        logger.info("Creating new product: {}", product.getName());
        
        Product savedProduct = productRepository.save(product);
        logger.info("Product created successfully: {}", savedProduct);
        
        // Publish Kafka event
        productEventPublisher.publishProductCreated(savedProduct);
        
        return savedProduct;
    }
    
    public Product updateProduct(Long id, Product productDetails) {
        logger.info("Updating product with id: {}", id);
        
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        
        product.setName(productDetails.getName());
        product.setDescription(productDetails.getDescription());
        product.setPrice(productDetails.getPrice());
        product.setCategory(productDetails.getCategory());
        product.setQuantity(productDetails.getQuantity());
        product.setActive(productDetails.getActive());
        
        Product updatedProduct = productRepository.save(product);
        logger.info("Product updated successfully: {}", updatedProduct);
        
        // Publish Kafka event
        productEventPublisher.publishProductUpdated(updatedProduct);
        
        return updatedProduct;
    }
    
    public void deleteProduct(Long id) {
        logger.info("Deleting product with id: {}", id);
        
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        
        // Publish Kafka event before deletion
        productEventPublisher.publishProductDeleted(product);
        
        productRepository.delete(product);
        logger.info("Product deleted successfully: {}", product.getName());
    }
    
    public Product deactivateProduct(Long id) {
        logger.info("Deactivating product with id: {}", id);
        
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        product.setActive(false);
        
        Product updatedProduct = productRepository.save(product);
        
        // Publish Kafka event
        productEventPublisher.publishProductUpdated(updatedProduct);
        
        return updatedProduct;
    }
    
    public Product activateProduct(Long id) {
        logger.info("Activating product with id: {}", id);
        
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        product.setActive(true);
        
        Product updatedProduct = productRepository.save(product);
        
        // Publish Kafka event
        productEventPublisher.publishProductUpdated(updatedProduct);
        
        return updatedProduct;
    }
}