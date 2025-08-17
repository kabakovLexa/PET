# Java Microservices Project для тестировщиков

## 🚀 Архитектура проекта

Этот проект представляет собой современную микросервисную архитектуру на Java с полным DevOps стеком и event-driven коммуникацией.

### 📋 Микросервисы (ФАЗА 2)

1. **discovery-service** - Eureka Server для Service Discovery
2. **api-gateway** - Шлюз для маршрутизации запросов
3. **user-service** - Управление пользователями с PostgreSQL и Kafka
4. **product-service** - Управление продуктами с PostgreSQL и Kafka

### 🛠️ Технологический стек

#### ФАЗА 1 - Базовая архитектура:
- **Java 17** + **Spring Boot 3.2**
- **Spring Cloud Gateway** для API Gateway
- **Eureka Server** для Service Discovery
- **H2 Database** (заменена в ФАЗЕ 2)
- **Docker** для контейнеризации

#### ФАЗА 2 - Event-driven + Persistent storage:
- ✅ **PostgreSQL** - persistent database (заменила H2)
- ✅ **Apache Kafka** - межсервисное общение через события  
- ✅ **Kafka UI** - управление Kafka топиками
- ✅ **Zookeeper** - координация Kafka
- ✅ **Event-driven архитектура** между сервисами

### 🌐 Архитектурная диаграмма

```
┌─────────────────┐    ┌─────────────────┐
│   User Service  │◄──►│ Product Service │
│   (port 8081)   │    │   (port 8082)   │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          ▼                      ▼
┌─────────────────────────────────────────┐
│            Apache Kafka                 │
│    Topics: user-events, product-events  │
└─────────────────────────────────────────┘
          ▲
          │
┌─────────┴───────┐    ┌─────────────────┐
│   API Gateway   │    │ Discovery Service│
│   (port 8080)   │    │   (port 8761)   │
└─────────────────┘    └─────────────────┘
          ▲
          │
┌─────────┴───────┐
│   PostgreSQL    │
│   (port 5432)   │
└─────────────────┘
```

### 🚦 Быстрый старт

1. **Сборка проекта:**
```bash
./build.sh
```

2. **Запуск через Docker Compose:**
```bash
./start.sh
```

3. **Тестирование API:**
```bash
./test-apis.sh
```

4. **Остановка сервисов:**
```bash
./stop.sh
```

### 📊 Доступные сервисы

- **Eureka Dashboard**: http://localhost:8761
- **API Gateway**: http://localhost:8080  
- **Kafka UI**: http://localhost:8090
- **PostgreSQL**: localhost:5432
- **User Service**: http://localhost:8081
- **Product Service**: http://localhost:8082

### 📡 Event-driven коммуникация

#### Kafka Topics:
1. **user-events** - события пользователей
   - USER_CREATED
   - USER_UPDATED  
   - USER_DELETED

2. **product-events** - события продуктов
   - PRODUCT_CREATED
   - PRODUCT_UPDATED
   - PRODUCT_DELETED

#### Межсервисное общение:
- User Service → публикует события → Product Service получает
- Product Service → публикует события → User Service получает

### 📚 API Endpoints

#### User Service (через Gateway: http://localhost:8080/users)
- `GET /users` - Получить всех пользователей
- `POST /users` - Создать пользователя (+ Kafka событие)
- `PUT /users/{id}` - Обновить пользователя (+ Kafka событие)
- `DELETE /users/{id}` - Удалить пользователя (+ Kafka событие)
- `GET /users/{id}` - Получить пользователя по ID
- `GET /users/department/{dept}` - Пользователи по отделу

#### Product Service (через Gateway: http://localhost:8080/products)
- `GET /products` - Получить все продукты
- `POST /products` - Создать продукт (+ Kafka событие)
- `PUT /products/{id}` - Обновить продукт (+ Kafka событие)
- `DELETE /products/{id}` - Удалить продукт (+ Kafka событие)
- `GET /products/{id}` - Получить продукт по ID
- `GET /products/category/{category}` - Продукты по категории
- `PATCH /products/{id}/activate` - Активировать продукт
- `PATCH /products/{id}/deactivate` - Деактивировать продукт

### 🗄️ База данных

**PostgreSQL databases:**
- `user_db` - данные пользователей
- `product_db` - данные продуктов

**Подключение:**
```
Host: localhost:5432
Username: postgres  
Password: postgres123
```

### 📈 Мониторинг

**Kafka UI**: http://localhost:8090
- Просмотр топиков
- Мониторинг сообщений
- Управление consumer groups

**Логи сервисов:**
```bash
docker-compose logs -f user-service
docker-compose logs -f product-service
docker-compose logs -f kafka
```

### 🏗️ Следующие фазы развития

- **Фаза 3:** Prometheus, Grafana, ELK Stack (логирование и мониторинг)
- **Фаза 4:** Jenkins CI/CD (автоматизация)
- **Фаза 5:** Kubernetes + Dashboard (оркестрация)
- **Фаза 6:** Jira, TestIT, Confluent (интеграции)
- **Фаза 7:** Production deployment (продакшен)

### 🧪 Тестирование Event-driven архитектуры

1. Создайте нового пользователя:
```bash
curl -X POST http://localhost:8080/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","department":"QA"}'
```

2. Проверьте логи Product Service - должно появиться сообщение о получении USER_CREATED события

3. Создайте новый продукт:
```bash
curl -X POST http://localhost:8080/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Product","description":"Test","price":999.99,"category":"Test","quantity":5,"active":true}'
```

4. Проверьте логи User Service - должно появиться сообщение о получении PRODUCT_CREATED события

**ФАЗА 2 готова! Event-driven микросервисная архитектура с PostgreSQL и Kafka работает! 🎉**