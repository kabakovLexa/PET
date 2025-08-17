#!/bin/bash

echo "🚀 Запускаем Java микросервисы..."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

# Проверяем наличие Docker Compose
if ! command -v docker-compose &> /dev/null && ! command -v docker compose &> /dev/null; then
    echo "❌ Docker Compose не найден! Пожалуйста, установите Docker Compose."
    exit 1
fi

# Переходим в корневую директорию проекта
cd "$(dirname "$0")"

echo -e "${BLUE}Выберите режим развертывания:${NC}"
echo -e "${YELLOW}1) Docker Compose (локальная разработка)${NC}"
echo -e "${YELLOW}2) Kubernetes (production-ready)${NC}"
echo ""
read -p "Введите номер (1-2): " deployment_choice

case $deployment_choice in
    1)
        echo -e "${PURPLE}=== Запуск в режиме Docker Compose ===${NC}"
        echo "🐳 Запускаем контейнеры через Docker Compose..."

        # Используем docker-compose или docker compose в зависимости от версии
        if command -v docker-compose &> /dev/null; then
            docker-compose up -d
        else
            docker compose up -d
        fi

        # Проверяем успешность запуска
        if [ $? -eq 0 ]; then
            echo "✅ Все сервисы успешно запущены!"
            echo ""
            echo "⏳ Ожидание готовности сервисов (30 секунд)..."
            sleep 30
            
            echo "📊 Статус сервисов:"
            if command -v docker-compose &> /dev/null; then
                docker-compose ps
            else
                docker compose ps
            fi
            
            echo ""
            echo -e "${BLUE}🌐 Доступные сервисы:${NC}"
            echo "   • Eureka Dashboard: http://localhost:8761"
            echo "   • API Gateway: http://localhost:8080"
            echo "   • User Service: http://localhost:8081"
            echo "   • Product Service: http://localhost:8082"
            echo ""
            echo -e "${PURPLE}🔄 CI/CD и Мониторинг:${NC}"
            echo "   • Jenkins CI/CD: http://localhost:8085 (admin/admin123)"
            echo "   • Grafana Dashboard: http://localhost:3000 (admin/admin123)"
            echo "   • Prometheus: http://localhost:9090"
            echo "   • Kibana Logs: http://localhost:5601"
            echo "   • Kafka UI: http://localhost:8090"
            echo ""
            echo -e "${BLUE}🧪 Запустить тесты:${NC}"
            echo "   ./test-apis.sh"
            echo ""
            echo "Для остановки сервисов используйте: ./stop.sh"
        else
            echo "❌ Ошибка при запуске контейнеров"
            exit 1
        fi
        ;;
    2)
        echo -e "${PURPLE}=== Запуск в режиме Kubernetes ===${NC}"
        echo ""
        echo -e "${YELLOW}🔧 Настройка Kubernetes кластера...${NC}"
        echo "Выполняется автоматическая настройка Kind кластера"
        
        # Запускаем настройку Kubernetes
        if [ -f "./scripts/setup-kubernetes.sh" ]; then
            ./scripts/setup-kubernetes.sh
            
            if [ $? -eq 0 ]; then
                echo ""
                echo -e "${YELLOW}🚀 Развертывание микросервисов в Kubernetes...${NC}"
                ./scripts/deploy-to-kubernetes.sh
                
                if [ $? -eq 0 ]; then
                    echo ""
                    echo -e "${GREEN}🎉 Kubernetes развертывание завершено!${NC}"
                    echo ""
                    echo -e "${BLUE}☸️ Kubernetes сервисы:${NC}"
                    echo "   • API Gateway: http://localhost:8080 (port-forward активен)"
                    echo "   • Eureka Dashboard: http://localhost:8761 (port-forward активен)"
                    echo "   • Grafana: http://localhost:3000 (port-forward активен)"
                    echo "   • Prometheus: http://localhost:9090 (port-forward активен)"
                    echo ""
                    echo -e "${PURPLE}🎛️ Kubernetes Dashboard:${NC}"
                    echo "   • Dashboard URL: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
                    echo "   • Запустите: kubectl proxy"
                    echo ""
                    echo -e "${PURPLE}🔄 ArgoCD:${NC}"
                    echo "   • ArgoCD URL: http://localhost:8080"
                    echo "   • Запустите: kubectl port-forward svc/argocd-server -n argocd 8080:443"
                    echo ""
                    echo -e "${BLUE}🧪 Запустить Kubernetes тесты:${NC}"
                    echo "   ./scripts/test-kubernetes.sh"
                    echo ""
                    echo -e "${BLUE}⚙️ Полезные команды:${NC}"
                    echo "   kubectl get pods -n microservices"
                    echo "   kubectl logs -f deployment/api-gateway -n microservices"
                    echo "   helm list -n microservices"
                else
                    echo -e "${RED}❌ Ошибка при развертывании в Kubernetes${NC}"
                    exit 1
                fi
            else
                echo -e "${RED}❌ Ошибка при настройке Kubernetes кластера${NC}"
                exit 1
            fi
        else
            echo -e "${RED}❌ Скрипт setup-kubernetes.sh не найден${NC}"
            exit 1
        fi
        ;;
    *)
        echo -e "${RED}❌ Неверный выбор. Используйте 1 или 2.${NC}"
        exit 1
        ;;
esac