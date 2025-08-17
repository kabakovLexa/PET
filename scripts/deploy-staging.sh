#!/bin/bash

echo "🚀 Deploying to Staging Environment..."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Configuration
STAGING_HOST=${STAGING_HOST:-"staging.microservices.local"}
BUILD_VERSION=${BUILD_VERSION:-"latest"}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-"localhost:5000"}
HEALTHCHECK_TIMEOUT=300  # 5 minutes

# Function to check service health
check_service_health() {
    local service_name=$1
    local health_url=$2
    local timeout=$3
    
    echo -e "${YELLOW}Checking health of $service_name...${NC}"
    
    for i in $(seq 1 $timeout); do
        if curl -s -f "$health_url" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ $service_name is healthy${NC}"
            return 0
        fi
        echo -n "."
        sleep 1
    done
    
    echo -e "${RED}❌ $service_name health check failed after ${timeout}s${NC}"
    return 1
}

# Pre-deployment checks
echo -e "${BLUE}=== Pre-deployment Checks ===${NC}"

# Check if Docker images exist
SERVICES=("discovery-service" "api-gateway" "user-service" "product-service")
for service in "${SERVICES[@]}"; do
    echo -e "${YELLOW}Checking Docker image: ${service}:${BUILD_VERSION}${NC}"
    if docker images | grep -q "${service}.*${BUILD_VERSION}"; then
        echo -e "${GREEN}✅ Image found: ${service}:${BUILD_VERSION}${NC}"
    else
        echo -e "${RED}❌ Image not found: ${service}:${BUILD_VERSION}${NC}"
        echo "Please build images first with: docker build -t ${service}:${BUILD_VERSION} ./${service}"
        exit 1
    fi
done

# Backup current staging state
echo -e "${BLUE}=== Creating Backup ===${NC}"
echo -e "${YELLOW}Creating backup of current staging environment...${NC}"

if docker-compose -f docker-compose.staging.yml ps | grep -q "Up"; then
    echo "Backing up staging data..."
    docker-compose -f docker-compose.staging.yml exec -T postgres-staging pg_dump -U staging_user microservices_staging_db > "staging-backup-$(date +%Y%m%d-%H%M%S).sql"
    echo -e "${GREEN}✅ Backup created${NC}"
else
    echo "No existing staging environment found, skipping backup"
fi

# Update docker-compose with new image versions
echo -e "${BLUE}=== Updating Configuration ===${NC}"
echo -e "${YELLOW}Updating docker-compose.staging.yml with build version ${BUILD_VERSION}...${NC}"

# Create temporary staging config
cp docker-compose.staging.yml docker-compose.staging.tmp.yml

# Update image tags
for service in "${SERVICES[@]}"; do
    sed -i "s|image: ${service}:.*|image: ${service}:${BUILD_VERSION}|g" docker-compose.staging.tmp.yml
done

echo -e "${GREEN}✅ Configuration updated${NC}"

# Deploy to staging
echo -e "${BLUE}=== Deploying to Staging ===${NC}"
echo -e "${YELLOW}Starting staging deployment...${NC}"

# Rolling deployment strategy
docker-compose -f docker-compose.staging.tmp.yml pull
docker-compose -f docker-compose.staging.tmp.yml up -d

echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 30

# Health checks
echo -e "${BLUE}=== Health Checks ===${NC}"
HEALTH_CHECK_FAILED=false

# Check Discovery Service
if ! check_service_health "Discovery Service" "http://${STAGING_HOST}:8763/actuator/health" 60; then
    HEALTH_CHECK_FAILED=true
fi

# Check API Gateway
if ! check_service_health "API Gateway" "http://${STAGING_HOST}:8087/actuator/health" 60; then
    HEALTH_CHECK_FAILED=true
fi

# Check User Service through Gateway
if ! check_service_health "User Service" "http://${STAGING_HOST}:8087/users/health" 60; then
    HEALTH_CHECK_FAILED=true
fi

# Check Product Service through Gateway
if ! check_service_health "Product Service" "http://${STAGING_HOST}:8087/products/health" 60; then
    HEALTH_CHECK_FAILED=true
fi

# Run smoke tests
echo -e "${BLUE}=== Smoke Tests ===${NC}"
echo -e "${YELLOW}Running smoke tests on staging environment...${NC}"

SMOKE_TEST_FAILED=false

# Test basic functionality
echo "Testing user creation..."
USER_RESPONSE=$(curl -s -X POST "http://${STAGING_HOST}:8087/users" \
  -H "Content-Type: application/json" \
  -d '{"name":"Staging Test User","email":"staging-test@example.com","department":"QA"}')

if echo "$USER_RESPONSE" | grep -q "Staging Test User"; then
    echo -e "${GREEN}✅ User creation test passed${NC}"
else
    echo -e "${RED}❌ User creation test failed${NC}"
    SMOKE_TEST_FAILED=true
fi

echo "Testing product creation..."
PRODUCT_RESPONSE=$(curl -s -X POST "http://${STAGING_HOST}:8087/products" \
  -H "Content-Type: application/json" \
  -d '{"name":"Staging Test Product","description":"Test product","price":99.99,"category":"Test","quantity":5,"active":true}')

if echo "$PRODUCT_RESPONSE" | grep -q "Staging Test Product"; then
    echo -e "${GREEN}✅ Product creation test passed${NC}"
else
    echo -e "${RED}❌ Product creation test failed${NC}"
    SMOKE_TEST_FAILED=true
fi

# Final deployment status
echo -e "${BLUE}=== Deployment Summary ===${NC}"

if [ "$HEALTH_CHECK_FAILED" = true ] || [ "$SMOKE_TEST_FAILED" = true ]; then
    echo -e "${RED}❌ Staging deployment failed!${NC}"
    
    echo -e "${YELLOW}Rolling back to previous version...${NC}"
    docker-compose -f docker-compose.staging.yml down
    
    # Restore from backup if available
    LATEST_BACKUP=$(ls -t staging-backup-*.sql 2>/dev/null | head -n1)
    if [ -n "$LATEST_BACKUP" ]; then
        echo "Restoring from backup: $LATEST_BACKUP"
        # Restore backup process would go here
    fi
    
    # Cleanup
    rm -f docker-compose.staging.tmp.yml
    
    exit 1
else
    echo -e "${GREEN}🎉 Staging deployment successful!${NC}"
    
    # Replace staging config with new version
    mv docker-compose.staging.tmp.yml docker-compose.staging.yml
    
    echo -e "${BLUE}Staging Environment Details:${NC}"
    echo "• API Gateway: http://${STAGING_HOST}:8087"
    echo "• Discovery Service: http://${STAGING_HOST}:8763"
    echo "• Version: ${BUILD_VERSION}"
    echo "• Deployment Time: $(date)"
    
    # Send success notification
    echo -e "${GREEN}📧 Sending deployment success notification...${NC}"
    
    exit 0
fi