package com.testproject.product.repository;

import com.testproject.product.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    
    List<Product> findByCategory(String category);
    
    List<Product> findByActiveTrue();
    
    List<Product> findByActiveFalse();
    
    List<Product> findByPriceBetween(BigDecimal minPrice, BigDecimal maxPrice);
    
    List<Product> findByNameContainingIgnoreCase(String name);
    
    List<Product> findByCategoryAndActiveTrue(String category);
}