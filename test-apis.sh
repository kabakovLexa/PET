#!/bin/bash

echo "🧪 Тестируем API endpoints микросервисов с Kafka и PostgreSQL..."

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
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
    
    if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
        echo -e "${GREEN}✅ SUCCESS (HTTP $http_code)${NC}"
        if [ ${#body} -gt 200 ]; then
            echo "Response: ${body:0:200}..."
        else
            echo "Response: $body"
        fi
    else
        echo -e "${RED}❌ FAILED (HTTP $http_code)${NC}"
        echo "Response: $body"
    fi
    echo "---"
}

# Функция для POST запроса
test_post() {
    local url=$1
    local data=$2
    local description=$3
    
    echo -e "${YELLOW}Тестируем POST: $description${NC}"
    echo -e "URL: $url"
    
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X POST -H "Content-Type: application/json" -d "$data" "$url")
    http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo $response | sed -e 's/HTTPSTATUS:.*//g')
    
    if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
        echo -e "${GREEN}✅ SUCCESS (HTTP $http_code)${NC}"
        echo "Response: $body"
    else
        echo -e "${RED}❌ FAILED (HTTP $http_code)${NC}"
        echo "Response: $body"
    fi
    echo "---"
}

echo "Ожидание запуска всех сервисов (30 секунд)..."
sleep 30

echo -e "${BLUE}=== ПРОВЕРКА ИНФРАСТРУКТУРЫ ===${NC}"
test_api "http://localhost:8761/eureka/apps" "Eureka Registry"
test_api "http://localhost:8090" "Kafka UI Dashboard"

echo -e "${BLUE}=== ТЕСТИРОВАНИЕ API GATEWAY ===${NC}"
test_api "http://localhost:8080/users/health" "User Service Health через Gateway"
test_api "http://localhost:8080/products/health" "Product Service Health через Gateway"

echo -e "${BLUE}=== ТЕСТИРОВАНИЕ USER SERVICE ===${NC}"
test_api "http://localhost:8080/users" "Получить всех пользователей"
test_post "http://localhost:8080/users" '{"name":"Kafka Пользователь","email":"kafka@test.com","department":"DevOps"}' "Создать пользователя (с Kafka событием)"
test_api "http://localhost:8080/users" "Проверить нового пользователя"

echo -e "${BLUE}=== ТЕСТИРОВАНИЕ PRODUCT SERVICE ===${NC}"
test_api "http://localhost:8080/products" "Получить все продукты"
test_post "http://localhost:8080/products" '{"name":"Kafka Продукт","description":"Тестовый продукт с событиями","price":1999.99,"category":"Testing","quantity":10,"active":true}' "Создать продукт (с Kafka событием)"
test_api "http://localhost:8080/products?activeOnly=true" "Получить активные продукты"

echo -e "${BLUE}=== ПРОВЕРКА БАЗЫ ДАННЫХ ===${NC}"
echo -e "${YELLOW}PostgreSQL должен содержать данные в базах user_db и product_db${NC}"

echo -e "${BLUE}=== KAFKA TOPICS ===${NC}"
echo -e "${YELLOW}Проверьте Kafka UI: http://localhost:8090${NC}"
echo -e "${YELLOW}Должны быть созданы топики: user-events, product-events${NC}"

echo -e "${GREEN}🎉 Тестирование ФАЗЫ 2 завершено!${NC}"
echo ""
echo -e "${BLUE}📊 Доступные сервисы:${NC}"
echo "   • Eureka Dashboard: http://localhost:8761"
echo "   • API Gateway: http://localhost:8080"
echo "   • Kafka UI: http://localhost:8090"
echo "   • PostgreSQL: localhost:5432"
echo ""
echo -e "${BLUE}📡 Event-driven архитектура:${NC}"
echo "   • User события → product-events topic → Product Service"
echo "   • Product события → user-events topic → User Service"
echo "   • PostgreSQL для persistent storage"
echo ""
echo -e "${BLUE}🔧 Для мониторинга логов:${NC}"
echo "   docker-compose logs -f user-service"
echo "   docker-compose logs -f product-service"