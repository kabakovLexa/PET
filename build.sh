#!/bin/bash

echo "🚀 Начинается сборка Java микросервисов..."

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
    echo "🎉 Сборка завершена! Теперь вы можете запустить сервисы командой:"
    echo "   ./start.sh"
    echo ""
    echo "Или запустить через Docker Compose:"
    echo "   docker-compose up -d"
else
    echo "❌ Ошибка при сборке Docker образов"
    exit 1
fi