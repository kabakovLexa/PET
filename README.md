# Java Microservices Project для тестировщиков

## 🚀 Архитектура проекта

Этот проект представляет собой современную микросервисную архитектуру на Java с полным DevOps стеком.

### 📋 Микросервисы

1. **discovery-service** - Eureka Server для Service Discovery
2. **api-gateway** - Шлюз для маршрутизации запросов
3. **user-service** - Управление пользователями
4. **product-service** - Управление продуктами

### 🛠️ Технологический стек

- **Java 17** + **Spring Boot 3.2**
- **Spring Cloud Gateway** для API Gateway
- **Eureka Server** для Service Discovery
- **Docker** для контейнеризации
- **Docker Compose** для локального запуска

### 🚦 Быстрый старт

1. **Сборка проекта:**
```bash
mvn clean install
```

2. **Запуск через Docker Compose:**
```bash
docker-compose up -d
```

3. **Проверка сервисов:**
- Eureka Dashboard: http://localhost:8761
- API Gateway: http://localhost:8080
- User Service: http://localhost:8081
- Product Service: http://localhost:8082

### 📊 API Endpoints

#### User Service (через Gateway: http://localhost:8080/users)
- `GET /users` - Получить всех пользователей
- `POST /users` - Создать пользователя
- `GET /users/{id}` - Получить пользователя по ID

#### Product Service (через Gateway: http://localhost:8080/products)
- `GET /products` - Получить все продукты
- `POST /products` - Создать продукт
- `GET /products/{id}` - Получить продукт по ID

### 🏗️ Следующие фазы развития

- **Фаза 2:** Kafka, PostgreSQL, расширенная интеграция
- **Фаза 3:** Prometheus, Grafana, ELK Stack
- **Фаза 4:** Jenkins CI/CD
- **Фаза 5:** Kubernetes + Dashboard
- **Фаза 6:** Jira, TestIT, Confluent
- **Фаза 7:** Production deployment