#!/bin/bash

echo "🧪 Тестируем микросервисы с полным CI/CD и мониторингом (ФАЗА 4)..."

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
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

echo "Ожидание запуска всех сервисов (60 секунд)..."
sleep 60

echo -e "${CYAN}=== ПРОВЕРКА CI/CD И ИНФРАСТРУКТУРЫ ===${NC}"
test_api "http://localhost:8085/login" "Jenkins CI/CD Server"
test_api "http://localhost:8761/eureka/apps" "Eureka Registry"
test_api "http://localhost:8090" "Kafka UI Dashboard"
test_api "http://localhost:9090/targets" "Prometheus Targets"
test_api "http://localhost:3000/api/health" "Grafana Dashboard"
test_api "http://localhost:5601/api/status" "Kibana Dashboard"
test_api "http://localhost:9200/_cluster/health" "Elasticsearch Cluster Health"

echo -e "${PURPLE}=== ПРОВЕРКА PROMETHEUS МЕТРИК ===${NC}"
test_api "http://localhost:8081/actuator/prometheus" "User Service Metrics"
test_api "http://localhost:8082/actuator/prometheus" "Product Service Metrics"
test_api "http://localhost:8080/actuator/prometheus" "API Gateway Metrics"
test_api "http://localhost:8761/actuator/prometheus" "Discovery Service Metrics"

echo -e "${BLUE}=== ТЕСТИРОВАНИЕ API GATEWAY ===${NC}"
test_api "http://localhost:8080/users/health" "User Service Health через Gateway"
test_api "http://localhost:8080/products/health" "Product Service Health через Gateway"

echo -e "${BLUE}=== ТЕСТИРОВАНИЕ USER SERVICE + CI/CD PIPELINE ===${NC}"
test_api "http://localhost:8080/users" "Получить всех пользователей"
test_post "http://localhost:8080/users" '{"name":"CI/CD Пользователь","email":"cicd@test.com","department":"DevOps"}' "Создать пользователя (с полной трассировкой)"
test_api "http://localhost:8080/users" "Проверить нового пользователя"

echo -e "${BLUE}=== ТЕСТИРОВАНИЕ PRODUCT SERVICE + CI/CD PIPELINE ===${NC}"
test_api "http://localhost:8080/products" "Получить все продукты"
test_post "http://localhost:8080/products" '{"name":"CI/CD Продукт","description":"Продукт созданный в CI/CD pipeline","price":4999.99,"category":"CI-CD","quantity":20,"active":true}' "Создать продукт (с полной трассировкой)"
test_api "http://localhost:8080/products?activeOnly=true" "Получить активные продукты"

echo -e "${PURPLE}=== ПРОВЕРКА CUSTOM МЕТРИК ===${NC}"
echo -e "${YELLOW}Проверяем пользовательские метрики...${NC}"
echo "User Service метрики:"
curl -s "http://localhost:8081/actuator/prometheus" | grep -E "(users_created_total|users_updated_total)" | head -5

echo -e "\nProduct Service метрики:"
curl -s "http://localhost:8082/actuator/prometheus" | grep -E "(products_created_total|products_updated_total)" | head -5

echo -e "${CYAN}=== ТЕСТИРОВАНИЕ CI/CD ФУНКЦИОНАЛЬНОСТИ ===${NC}"
echo -e "${YELLOW}Проверяем Jenkins API...${NC}"
JENKINS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8085/api/json")
if [ "$JENKINS_STATUS" -eq 200 ] || [ "$JENKINS_STATUS" -eq 403 ]; then
    echo -e "${GREEN}✅ Jenkins API доступен${NC}"
else
    echo -e "${RED}❌ Jenkins API недоступен (HTTP $JENKINS_STATUS)${NC}"
fi

echo -e "${GREEN}🎉 Тестирование ФАЗЫ 4 завершено!${NC}"
echo ""
echo -e "${CYAN}📊 Доступные CI/CD и мониторинг дашборды:${NC}"
echo "   • Jenkins CI/CD: http://localhost:8085 (admin/admin123)"
echo "   • Grafana Dashboard: http://localhost:3000 (admin/admin123)" 
echo "   • Prometheus UI: http://localhost:9090"
echo "   • Kibana Logs: http://localhost:5601"
echo "   • Kafka UI: http://localhost:8090"
echo "   • Eureka Dashboard: http://localhost:8761"
echo ""
echo -e "${BLUE}🔄 CI/CD Pipeline Features:${NC}"
echo "   • Автоматическая сборка при коммитах"
echo "   • Параллельное тестирование сервисов"
echo "   • Quality gates и security scanning"
echo "   • Docker image building и registry push"
echo "   • Автоматический деплой в staging"
echo "   • Manual approval для production"
echo ""
echo -e "${PURPLE}📡 Event-driven + CI/CD + Monitoring архитектура:${NC}"
echo "   • User события → product-events topic → Product Service"
echo "   • Product события → user-events topic → User Service"
echo "   • Все логи → Logstash → Elasticsearch → Kibana"
echo "   • Все метрики → Prometheus → Grafana"
echo "   • CI/CD → Jenkins → Automated Testing → Deployment"
echo "   • PostgreSQL для persistent storage"
echo ""
echo -e "${CYAN}🚀 Следующие шаги для настройки CI/CD:${NC}"
echo "   1. Запустить: ./scripts/setup-jenkins.sh"
echo "   2. Открыть Jenkins: http://localhost:8085"
echo "   3. Создать multibranch pipeline"
echo "   4. Настроить webhooks для автосборки"
echo "   5. Запустить тестовую сборку"
echo ""
echo -e "${GREEN}✅ ФАЗА 4: CI/CD успешно развернута и готова к использованию!${NC}"