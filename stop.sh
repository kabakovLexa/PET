#!/bin/bash

echo "🛑 Останавливаем Java микросервисы..."

# Переходим в корневую директорию проекта
cd "$(dirname "$0")"

echo "🐳 Останавливаем контейнеры..."

# Используем docker-compose или docker compose в зависимости от версии
if command -v docker-compose &> /dev/null; then
    docker-compose down
else
    docker compose down
fi

if [ $? -eq 0 ]; then
    echo "✅ Все сервисы успешно остановлены!"
else
    echo "❌ Ошибка при остановке контейнеров"
    exit 1
fi