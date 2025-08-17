#!/bin/bash

echo "🚀 Начинается сборка Java микросервисов (ФАЗА 4 - CI/CD)..."

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
    echo "🎉 Сборка ФАЗЫ 4 завершена!"
    echo ""
    echo "🔄 Полный CI/CD стек готов:"
    echo "   • Jenkins для автоматизации"
    echo "   • Prometheus + Grafana для метрик"
    echo "   • ELK Stack для логирования"
    echo "   • Kafka + PostgreSQL + микросервисы"
    echo "   • Автоматические тесты и деплой"
    echo ""
    echo "🚀 Запустите полный стек командой:"
    echo "   ./start.sh"
    echo ""
    echo "🔧 Настройте Jenkins:"
    echo "   ./scripts/setup-jenkins.sh"
    echo ""
    echo "Или запустить через Docker Compose:"
    echo "   docker-compose up -d"
else
    echo "❌ Ошибка при сборке Docker образов"
    exit 1
fi