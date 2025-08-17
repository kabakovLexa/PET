#!/bin/bash

echo "🚀 Начинается сборка Java микросервисов (ФАЗА 3 - с мониторингом)..."

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

# Создаем необходимые директории для мониторинга
echo "📁 Создаем директории для мониторинга..."
mkdir -p monitoring/prometheus
mkdir -p monitoring/grafana/provisioning/datasources
mkdir -p monitoring/grafana/provisioning/dashboards
mkdir -p monitoring/grafana/dashboards
mkdir -p monitoring/logstash
mkdir -p logs

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
    echo "🎉 Сборка ФАЗЫ 3 завершена!"
    echo ""
    echo "📊 Полный мониторинг стек готов:"
    echo "   • Prometheus + Grafana для метрик"
    echo "   • ELK Stack для логирования"
    echo "   • Kafka + PostgreSQL + микросервисы"
    echo ""
    echo "🚀 Запустите полный стек командой:"
    echo "   ./start.sh"
    echo ""
    echo "Или запустить через Docker Compose:"
    echo "   docker-compose up -d"
else
    echo "❌ Ошибка при сборке Docker образов"
    exit 1
fi