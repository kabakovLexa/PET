#!/bin/bash

echo "🧪 Тестируем API endpoints микросервисов..."

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для тестирования API
test_api() {
    local url=$1
    local description=$2
    
    echo -e "${YELLOW}Тестируем: $description${NC}"
    echo -e "URL: $url"
    
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" "$url")
    http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo $response | sed -e 's/HTTPSTATUS:.*//g')
    
    if [ "$http_code" -eq 200 ]; then
        echo -e "${GREEN}✅ SUCCESS (HTTP $http_code)${NC}"
        echo "Response: $body"
    else
        echo -e "${RED}❌ FAILED (HTTP $http_code)${NC}"
        echo "Response: $body"
    fi
    echo "---"
}

echo "Ожидание запуска сервисов (10 секунд)..."
sleep 10

echo -e "${YELLOW}=== ТЕСТИРОВАНИЕ API GATEWAY ===${NC}"
test_api "http://localhost:8080/users/health" "User Service Health через Gateway"
test_api "http://localhost:8080/products/health" "Product Service Health через Gateway"

echo -e "${YELLOW}=== ТЕСТИРОВАНИЕ USER SERVICE ===${NC}"
test_api "http://localhost:8080/users" "Получить всех пользователей"
test_api "http://localhost:8080/users/1" "Получить пользователя по ID"
test_api "http://localhost:8080/users/department/QA" "Пользователи отдела QA"

echo -e "${YELLOW}=== ТЕСТИРОВАНИЕ PRODUCT SERVICE ===${NC}"
test_api "http://localhost:8080/products" "Получить все продукты"
test_api "http://localhost:8080/products?activeOnly=true" "Получить активные продукты"
test_api "http://localhost:8080/products/1" "Получить продукт по ID"
test_api "http://localhost:8080/products/category/Electronics" "Продукты категории Electronics"

echo -e "${YELLOW}=== ТЕСТИРОВАНИЕ EUREKA ===${NC}"
test_api "http://localhost:8761/eureka/apps" "Eureka Registry"

echo -e "${GREEN}🎉 Тестирование завершено!${NC}"
echo ""
echo "Для создания нового пользователя:"
echo 'curl -X POST http://localhost:8080/users -H "Content-Type: application/json" -d "{\"name\":\"Тестовый Пользователь\",\"email\":\"test@example.com\",\"department\":\"QA\"}"'
echo ""
echo "Для создания нового продукта:"
echo 'curl -X POST http://localhost:8080/products -H "Content-Type: application/json" -d "{\"name\":\"Тестовый продукт\",\"description\":\"Описание\",\"price\":1999.99,\"category\":\"Test\",\"quantity\":10}"'