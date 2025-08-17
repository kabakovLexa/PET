#!/bin/bash

echo "🚀 Запускаем Java микросервисы..."

# Проверяем наличие Docker Compose
if ! command -v docker-compose &> /dev/null && ! command -v docker compose &> /dev/null; then
    echo "❌ Docker Compose не найден! Пожалуйста, установите Docker Compose."
    exit 1
fi

# Переходим в корневую директорию проекта
cd "$(dirname "$0")"

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
    echo "📊 Статус сервисов:"
    sleep 5
    
    if command -v docker-compose &> /dev/null; then
        docker-compose ps
    else
        docker compose ps
    fi
    
    echo ""
    echo "🌐 Доступные сервисы:"
    echo "   • Eureka Dashboard: http://localhost:8761"
    echo "   • API Gateway: http://localhost:8080"
    echo "   • User Service: http://localhost:8081"
    echo "   • Product Service: http://localhost:8082"
    echo ""
    echo "📚 Примеры API запросов:"
    echo "   • GET http://localhost:8080/users - Получить всех пользователей"
    echo "   • GET http://localhost:8080/products - Получить все продукты"
    echo "   • GET http://localhost:8080/users/health - Проверить статус User Service"
    echo "   • GET http://localhost:8080/products/health - Проверить статус Product Service"
    echo ""
    echo "Для остановки сервисов используйте: ./stop.sh"
else
    echo "❌ Ошибка при запуске контейнеров"
    exit 1
fi