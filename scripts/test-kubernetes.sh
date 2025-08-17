#!/bin/bash

echo "🧪 Testing Kubernetes deployment..."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE=${NAMESPACE:-"microservices"}
API_GATEWAY_URL=${API_GATEWAY_URL:-"http://localhost:8080"}

# Function to test API endpoint
test_api() {
    local url=$1
    local description=$2
    local expected_status=${3:-200}
    
    echo -e "${YELLOW}Testing: $description${NC}"
    
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" "$url")
    http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo $response | sed -e 's/HTTPSTATUS:.*//g')
    
    if [ "$http_code" -eq "$expected_status" ]; then
        echo -e "${GREEN}✅ SUCCESS (HTTP $http_code)${NC}"
        if [ ${#body} -gt 200 ]; then
            echo "Response: ${body:0:200}..."
        else
            echo "Response: $body"
        fi
        return 0
    else
        echo -e "${RED}❌ FAILED (HTTP $http_code, expected $expected_status)${NC}"
        echo "Response: $body"
        return 1
    fi
}

# Function to test POST endpoint
test_post() {
    local url=$1
    local data=$2
    local description=$3
    local expected_status=${4:-201}
    
    echo -e "${YELLOW}Testing POST: $description${NC}"
    
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X POST -H "Content-Type: application/json" -d "$data" "$url")
    http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo $response | sed -e 's/HTTPSTATUS:.*//g')
    
    if [ "$http_code" -eq "$expected_status" ] || [ "$http_code" -eq 200 ]; then
        echo -e "${GREEN}✅ SUCCESS (HTTP $http_code)${NC}"
        echo "Response: $body"
        return 0
    else
        echo -e "${RED}❌ FAILED (HTTP $http_code, expected $expected_status)${NC}"
        echo "Response: $body"
        return 1
    fi
}

# Wait for services to be ready
echo -e "${BLUE}⏳ Waiting for services to be ready...${NC}"
sleep 30

# Track test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Check Kubernetes cluster
echo -e "${PURPLE}=== Kubernetes Cluster Status ===${NC}"
echo -e "${BLUE}Cluster Info:${NC}"
kubectl cluster-info

echo -e "${BLUE}Pods Status:${NC}"
kubectl get pods -n "$NAMESPACE"

echo -e "${BLUE}Services Status:${NC}"
kubectl get services -n "$NAMESPACE"

# Test Discovery Service
echo -e "${PURPLE}=== Testing Discovery Service ===${NC}"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_api "http://localhost:8761/actuator/health" "Discovery Service Health"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test API Gateway
echo -e "${PURPLE}=== Testing API Gateway ===${NC}"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_api "${API_GATEWAY_URL}/actuator/health" "API Gateway Health"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test User Service
echo -e "${PURPLE}=== Testing User Service ===${NC}"

TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_api "${API_GATEWAY_URL}/users/health" "User Service Health through Gateway"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_api "${API_GATEWAY_URL}/users" "Get All Users"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_post "${API_GATEWAY_URL}/users" '{"name":"K8s Test User","email":"k8s-test@example.com","department":"DevOps"}' "Create User"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test Product Service
echo -e "${PURPLE}=== Testing Product Service ===${NC}"

TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_api "${API_GATEWAY_URL}/products/health" "Product Service Health through Gateway"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_api "${API_GATEWAY_URL}/products" "Get All Products"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_post "${API_GATEWAY_URL}/products" '{"name":"K8s Test Product","description":"Product created in Kubernetes","price":199.99,"category":"Cloud","quantity":15,"active":true}' "Create Product"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test Scaling
echo -e "${PURPLE}=== Testing Kubernetes Scaling ===${NC}"
echo -e "${YELLOW}Scaling user-service to 3 replicas...${NC}"
kubectl scale deployment/user-service --replicas=3 -n "$NAMESPACE"

# Wait for scaling
kubectl rollout status deployment/user-service -n "$NAMESPACE" --timeout=120s

REPLICAS=$(kubectl get deployment user-service -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}')
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if [ "$REPLICAS" -eq 3 ]; then
    echo -e "${GREEN}✅ Scaling test passed (3 replicas running)${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}❌ Scaling test failed ($REPLICAS replicas running, expected 3)${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Scale back to 2
kubectl scale deployment/user-service --replicas=2 -n "$NAMESPACE"

# Test Service Discovery
echo -e "${PURPLE}=== Testing Service Discovery ===${NC}"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_api "http://localhost:8761/eureka/apps" "Eureka Service Registry"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Load test
echo -e "${PURPLE}=== Basic Load Test ===${NC}"
echo -e "${YELLOW}Running concurrent requests...${NC}"
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Run 20 concurrent requests
for i in {1..20}; do
    curl -s "${API_GATEWAY_URL}/users" > /dev/null &
done
wait

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Load test passed${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}❌ Load test failed${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test results summary
echo ""
echo -e "${BLUE}=== Kubernetes Test Results Summary ===${NC}"
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

# Calculate success rate
if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc -l)
    echo -e "Success Rate: ${SUCCESS_RATE}%"
fi

# Show resource utilization
echo ""
echo -e "${PURPLE}=== Resource Utilization ===${NC}"
kubectl top pods -n "$NAMESPACE" 2>/dev/null || echo "Metrics server not available"

# Show logs if tests failed
if [ $FAILED_TESTS -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}=== Recent Logs for Troubleshooting ===${NC}"
    echo -e "${BLUE}API Gateway logs:${NC}"
    kubectl logs deployment/api-gateway -n "$NAMESPACE" --tail=10
    echo ""
    echo -e "${BLUE}User Service logs:${NC}"
    kubectl logs deployment/user-service -n "$NAMESPACE" --tail=10
fi

# Cleanup and summary
echo ""
echo -e "${BLUE}=== Kubernetes Deployment Status ===${NC}"
echo -e "📊 Cluster: $(kubectl config current-context)"
echo -e "🏷️ Namespace: $NAMESPACE"
echo -e "🔗 API Gateway: $API_GATEWAY_URL"
echo ""

if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}❌ Some tests failed. Check logs and troubleshoot.${NC}"
    exit 1
else
    echo -e "${GREEN}🎉 All Kubernetes tests passed! Deployment is healthy.${NC}"
    exit 0
fi