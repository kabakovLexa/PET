#!/bin/bash

echo "🚀 Начинается сборка Java микросервисов (ФАЗА 5 - Kubernetes)..."

# Проверяем наличие Maven
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven не найден! Пожалуйста, установите Maven."
    exit 1
fi

# Проверяем наличие Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не найден! Пожалуйста, установите Docker."
    exit 1
fi

echo "✅ Maven и Docker найдены"

# Переходим в корневую директорию проекта
cd "$(dirname "$0")"

# Создаем необходимые директории
echo "📁 Создаем директории..."
mkdir -p monitoring/prometheus
mkdir -p monitoring/grafana/provisioning/datasources
mkdir -p monitoring/grafana/provisioning/dashboards
mkdir -p monitoring/grafana/dashboards
mkdir -p monitoring/logstash
mkdir -p jenkins/jobs
mkdir -p kubernetes/dashboard
mkdir -p kubernetes/argocd
mkdir -p kubernetes/monitoring
mkdir -p helm/microservices/templates
mkdir -p logs
mkdir -p scripts

# Устанавливаем права на выполнение для скриптов
echo "🔧 Устанавливаем права на выполнение..."
chmod +x scripts/*.sh
chmod +x *.sh

echo "📦 Собираем все микросервисы с Maven..."
mvn clean install -DskipTests

# Проверяем успешность сборки
if [ $? -eq 0 ]; then
    echo "✅ Maven сборка успешно завершена!"
else
    echo "❌ Ошибка при сборке Maven"
    exit 1
fi

echo "🐳 Собираем Docker образы..."
docker-compose build

# Проверяем успешность сборки Docker
if [ $? -eq 0 ]; then
    echo "✅ Docker образы успешно собраны!"
    echo ""
    echo "🎉 Сборка ФАЗЫ 5 завершена!"
    echo ""
    echo "☸️ Полный Kubernetes стек готов:"
    echo "   • Kubernetes cluster с Kind"
    echo "   • Helm charts для deployment"
    echo "   • ArgoCD для GitOps"
    echo "   • Kubernetes Dashboard"
    echo "   • Horizontal Pod Autoscaler"
    echo "   • Jenkins для CI/CD"
    echo "   • Prometheus + Grafana в K8s"
    echo "   • Service Mesh готовность"
    echo ""
    echo "🚀 Варианты запуска:"
    echo "   Docker Compose: ./start.sh"
    echo "   Kubernetes:     ./scripts/setup-kubernetes.sh"
    echo ""
    echo "☸️ Kubernetes deployment:"
    echo "   ./scripts/deploy-to-kubernetes.sh"
    echo ""
    echo "📊 Helm deployment:"
    echo "   helm install microservices ./helm/microservices -n microservices --create-namespace"
else
    echo "❌ Ошибка при сборке Docker образов"
    exit 1
fi