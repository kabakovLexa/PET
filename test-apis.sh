#!/bin/bash

echo "🧪 Тестируем микросервисы с полным мониторингом (ФАЗА 3)..."

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
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

echo "Ожидание запуска всех сервисов (45 секунд)..."
sleep 45

echo -e "${PURPLE}=== ПРОВЕРКА ИНФРАСТРУКТУРЫ И МОНИТОРИНГА ===${NC}"
test_api "http://localhost:8761/eureka/apps" "Eureka Registry"
test_api "http://localhost:8090" "Kafka UI Dashboard"
test_api "http://localhost:9090/targets" "Prometheus Targets"
test_api "http://localhost:3000" "Grafana Dashboard"
test_api "http://localhost:5601" "Kibana Dashboard"
test_api "http://localhost:9200" "Elasticsearch Cluster Health"

echo -e "${PURPLE}=== ПРОВЕРКА PROMETHEUS МЕТРИК ===${NC}"
test_api "http://localhost:8081/actuator/prometheus" "User Service Metrics"
test_api "http://localhost:8082/actuator/prometheus" "Product Service Metrics"
test_api "http://localhost:8080/actuator/prometheus" "API Gateway Metrics"
test_api "http://localhost:8761/actuator/prometheus" "Discovery Service Metrics"

echo -e "${BLUE}=== ТЕСТИРОВАНИЕ API GATEWAY ===${NC}"
test_api "http://localhost:8080/users/health" "User Service Health через Gateway"
test_api "http://localhost:8080/products/health" "Product Service Health через Gateway"

echo -e "${BLUE}=== ТЕСТИРОВАНИЕ USER SERVICE + МЕТРИКИ ===${NC}"
test_api "http://localhost:8080/users" "Получить всех пользователей"
test_post "http://localhost:8080/users" '{"name":"Мониторинг Пользователь","email":"monitoring@test.com","department":"DevOps"}' "Создать пользователя (с Kafka событием и метриками)"
test_api "http://localhost:8080/users" "Проверить нового пользователя"

echo -e "${BLUE}=== ТЕСТИРОВАНИЕ PRODUCT SERVICE + МЕТРИКИ ===${NC}"
test_api "http://localhost:8080/products" "Получить все продукты"
test_post "http://localhost:8080/products" '{"name":"Мониторинг Продукт","description":"Продукт с полным мониторингом","price":2999.99,"category":"Monitoring","quantity":15,"active":true}' "Создать продукт (с Kafka событием и метриками)"
test_api "http://localhost:8080/products?activeOnly=true" "Получить активные продукты"

echo -e "${PURPLE}=== ПРОВЕРКА CUSTOM МЕТРИК ===${NC}"
echo -e "${YELLOW}Проверяем пользовательские метрики...${NC}"
curl -s "http://localhost:8081/actuator/prometheus" | grep "users_created_total"
curl -s "http://localhost:8082/actuator/prometheus" | grep "products_created_total"

echo -e "${GREEN}🎉 Тестирование ФАЗЫ 3 завершено!${NC}"
echo ""
echo -e "${BLUE}📊 Доступные дашборды мониторинга:${NC}"
echo "   • Grafana Dashboard: http://localhost:3000 (admin/admin123)"
echo "   • Prometheus UI: http://localhost:9090"
echo "   • Kibana Logs: http://localhost:5601"
echo "   • Kafka UI: http://localhost:8090"
echo "   • Eureka Dashboard: http://localhost:8761"
echo ""
echo -e "${BLUE}📡 Event-driven + Monitoring архитектура:${NC}"
echo "   • User события → product-events topic → Product Service"
echo "   • Product события → user-events topic → User Service"
echo "   • Все логи → Logstash → Elasticsearch → Kibana"
echo "   • Все метрики → Prometheus → Grafana"
echo "   • PostgreSQL для persistent storage"
echo ""
echo -e "${PURPLE}🔧 Для детального мониторинга:${NC}"
echo "   docker-compose logs -f user-service    # Логи User Service"
echo "   docker-compose logs -f product-service # Логи Product Service"
echo "   docker-compose logs -f logstash        # Логи Logstash"
echo "   docker-compose logs -f prometheus      # Логи Prometheus"
echo ""
echo -e "${PURPLE}📈 Метрики для анализа:${NC}"
echo "   • users_created_total, users_updated_total, users_deleted_total"
echo "   • products_created_total, products_updated_total, products_deleted_total"
echo "   • http_server_requests_seconds (latency)"
echo "   • kafka producer/consumer metrics"
echo "   • JVM metrics (heap, GC, threads)"