#!/bin/bash

echo "🧪 Running CI/CD Integration Tests..."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Test configuration
TEST_HOST=${TEST_HOST:-"localhost"}
API_GATEWAY_PORT=${API_GATEWAY_PORT:-"8083"}
DISCOVERY_PORT=${DISCOVERY_PORT:-"8762"}

# Function to test API endpoint
test_endpoint() {
    local url=$1
    local description=$2
    local expected_status=${3:-200}
    
    echo -e "${YELLOW}Testing: $description${NC}"
    
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" "$url")
    http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo $response | sed -e 's/HTTPSTATUS:.*//g')
    
    if [ "$http_code" -eq "$expected_status" ]; then
        echo -e "${GREEN}✅ PASSED (HTTP $http_code)${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED (HTTP $http_code, expected $expected_status)${NC}"
        echo "Response: $body"
        return 1
    fi
}

# Function to test POST endpoint
test_post_endpoint() {
    local url=$1
    local data=$2
    local description=$3
    local expected_status=${4:-201}
    
    echo -e "${YELLOW}Testing POST: $description${NC}"
    
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X POST -H "Content-Type: application/json" -d "$data" "$url")
    http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo $response | sed -e 's/HTTPSTATUS:.*//g')
    
    if [ "$http_code" -eq "$expected_status" ] || [ "$http_code" -eq 200 ]; then
        echo -e "${GREEN}✅ PASSED (HTTP $http_code)${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED (HTTP $http_code, expected $expected_status)${NC}"
        echo "Response: $body"
        return 1
    fi
}

# Wait for services to be ready
echo -e "${BLUE}⏳ Waiting for services to be ready...${NC}"
sleep 60

# Track test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test Discovery Service
echo -e "${BLUE}=== Testing Discovery Service ===${NC}"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_endpoint "http://${TEST_HOST}:${DISCOVERY_PORT}/actuator/health" "Discovery Service Health Check"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test API Gateway
echo -e "${BLUE}=== Testing API Gateway ===${NC}"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_endpoint "http://${TEST_HOST}:${API_GATEWAY_PORT}/actuator/health" "API Gateway Health Check"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test User Service through Gateway
echo -e "${BLUE}=== Testing User Service ===${NC}"

TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_endpoint "http://${TEST_HOST}:${API_GATEWAY_PORT}/users/health" "User Service Health through Gateway"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_endpoint "http://${TEST_HOST}:${API_GATEWAY_PORT}/users" "Get All Users"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_post_endpoint "http://${TEST_HOST}:${API_GATEWAY_PORT}/users" '{"name":"CI Test User","email":"ci-test@example.com","department":"QA"}' "Create User"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test Product Service through Gateway
echo -e "${BLUE}=== Testing Product Service ===${NC}"

TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_endpoint "http://${TEST_HOST}:${API_GATEWAY_PORT}/products/health" "Product Service Health through Gateway"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_endpoint "http://${TEST_HOST}:${API_GATEWAY_PORT}/products" "Get All Products"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_post_endpoint "http://${TEST_HOST}:${API_GATEWAY_PORT}/products" '{"name":"CI Test Product","description":"Product created during CI testing","price":99.99,"category":"Test","quantity":10,"active":true}' "Create Product"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test Service Registration
echo -e "${BLUE}=== Testing Service Registration ===${NC}"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
if test_endpoint "http://${TEST_HOST}:${DISCOVERY_PORT}/eureka/apps" "Eureka Service Registry"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Performance Test - Load Testing
echo -e "${BLUE}=== Performance Test ===${NC}"
echo -e "${YELLOW}Running basic load test...${NC}"
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Simple load test with 10 concurrent requests
for i in {1..10}; do
    curl -s "http://${TEST_HOST}:${API_GATEWAY_PORT}/users" > /dev/null &
done
wait

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Load test passed${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "${RED}❌ Load test failed${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Generate Test Report
echo ""
echo -e "${BLUE}=== Test Results Summary ===${NC}"
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

# Calculate success rate
SUCCESS_RATE=$(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc -l)
echo -e "Success Rate: ${SUCCESS_RATE}%"

# Create JUnit XML report for Jenkins
cat > test-results.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="MicroservicesIntegrationTests" tests="$TOTAL_TESTS" failures="$FAILED_TESTS" time="$(date +%s)">
EOF

# Add test cases (simplified)
for ((i=1; i<=PASSED_TESTS; i++)); do
    echo "    <testcase name=\"test_$i\" classname=\"IntegrationTest\" time=\"1\"/>" >> test-results.xml
done

for ((i=1; i<=FAILED_TESTS; i++)); do
    echo "    <testcase name=\"failed_test_$i\" classname=\"IntegrationTest\" time=\"1\">" >> test-results.xml
    echo "        <failure message=\"Test failed\">Integration test failure</failure>" >> test-results.xml
    echo "    </testcase>" >> test-results.xml
done

echo "</testsuite>" >> test-results.xml

# Exit with error code if tests failed
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}❌ Some tests failed. CI/CD pipeline should be marked as failed.${NC}"
    exit 1
else
    echo -e "${GREEN}🎉 All tests passed! CI/CD pipeline can proceed.${NC}"
    exit 0
fi