# Java Microservices Project для тестировщиков

## 🚀 Архитектура проекта

Этот проект представляет собой современную микросервисную архитектуру на Java с полным DevOps стеком, включающим CI/CD pipeline, event-driven коммуникацию и production-ready мониторинг.

### 📋 Микросервисы (ФАЗА 4 - CI/CD)

1. **discovery-service** - Eureka Server для Service Discovery
2. **api-gateway** - Шлюз для маршрутизации запросов
3. **user-service** - Управление пользователями с PostgreSQL, Kafka и метриками
4. **product-service** - Управление продуктами с PostgreSQL, Kafka и метриками

### 🛠️ Технологический стек

#### ФАЗА 1 - Базовая архитектура:
- **Java 17** + **Spring Boot 3.2**
- **Spring Cloud Gateway** для API Gateway
- **Eureka Server** для Service Discovery
- **Docker** для контейнеризации

#### ФАЗА 2 - Event-driven + Persistent storage:
- **PostgreSQL** - persistent database
- **Apache Kafka** - межсервисное общение через события  
- **Kafka UI** - управление Kafka топиками
- **Zookeeper** - координация Kafka

#### ФАЗА 3 - Мониторинг и логирование:
- **Prometheus** - сбор метрик
- **Grafana** - визуализация метрик и дашборды
- **ELK Stack** (Elasticsearch, Logstash, Kibana) - централизованное логирование
- **Custom metrics** - бизнес метрики приложений

#### ФАЗА 4 - CI/CD Pipeline:
- ✅ **Jenkins** - автоматизация сборки и деплоя
- ✅ **Automated Testing** - unit, integration, smoke tests
- ✅ **Docker Registry** - хранение Docker images
- ✅ **Multi-environment deployment** (test, staging, production)
- ✅ **Pipeline as Code** - Jenkinsfile с полным CI/CD
- ✅ **Quality Gates** - код качество и security scanning

### 🌐 Архитектурная диаграма

```
┌─────────────────────────────────────────────────────────────────┐
│                        CI/CD Pipeline                           │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────────┐ │
│  │ Source  │→│ Build   │→│ Test    │→│ Deploy  │→│ Monitor     │ │
│  │ Code    │ │ & QA    │ │ Suite   │ │ Stage   │ │ & Alert     │ │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                   ↓
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   User Service  │◄──►│ Product Service │    │    Jenkins      │
│   (port 8081)   │    │   (port 8082)   │    │   (port 8085)   │
└─────────┬───────┘    └─────────┬───────┘    └─────────────────┘
          │                      │
          ▼                      ▼
┌─────────────────────────────────────────┐
│            Apache Kafka                 │
│    Topics: user-events, product-events  │
└─────────────────────────────────────────┘
          ▲
          │
┌─────────┴───────┐    ┌─────────────────┐    ┌─────────────────┐
│   API Gateway   │    │ Discovery Service│    │   Monitoring    │
│   (port 8080)   │    │   (port 8761)   │    │ Prometheus/     │
└─────────────────┘    └─────────────────┘    │ Grafana/ELK     │
          ▲                                   └─────────────────┘
          │
┌─────────┴───────┐
│   PostgreSQL    │
│   (port 5432)   │
└─────────────────┘
```

### 🚦 Быстрый старт

1. **Сборка полного стека:**
```bash
./build.sh
```

2. **Запуск всех сервисов:**
```bash
./start.sh
```

3. **Настройка Jenkins:**
```bash
./scripts/setup-jenkins.sh
```

4. **Тестирование API:**
```bash
./test-apis.sh
```

5. **Остановка сервисов:**
```bash
./stop.sh
```

### 📊 Доступные сервисы

#### Основные сервисы:
- **Eureka Dashboard**: http://localhost:8761
- **API Gateway**: http://localhost:8080  
- **User Service**: http://localhost:8081
- **Product Service**: http://localhost:8082

#### CI/CD и DevOps:
- **Jenkins**: http://localhost:8085 (admin/admin123)
- **Grafana**: http://localhost:3000 (admin/admin123)
- **Prometheus**: http://localhost:9090
- **Kibana**: http://localhost:5601
- **Kafka UI**: http://localhost:8090
- **PostgreSQL**: localhost:5432

### 🔄 CI/CD Pipeline Features

#### Автоматизация сборки:
- **Parallel builds** - одновременная сборка всех сервисов
- **Automated testing** - unit tests, integration tests
- **Code quality analysis** - SonarQube integration ready
- **Security scanning** - OWASP dependency check
- **Docker image building** - automated containerization

#### Deployment Strategy:
- **Multi-environment support** - test, staging, production
- **Rolling deployments** - zero-downtime updates
- **Blue-green deployment** - для production
- **Automated rollback** - при failure detection
- **Smoke tests** - автоматическая проверка после деплоя

#### Pipeline Stages:
1. **📋 Checkout** - получение исходного кода
2. **🔍 Pre-build Checks** - code style, security, dependencies
3. **🏗️ Build & Test** - параллельная сборка и тестирование
4. **📊 Quality Analysis** - code quality и security анализ
5. **🐳 Docker Images** - сборка и тегирование образов
6. **🧪 Integration Tests** - полное E2E тестирование
7. **📦 Registry Push** - публикация образов в registry
8. **🚀 Deploy Staging** - автоматический деплой в staging
9. **🎯 Deploy Production** - manual approval + production деплой

### 📡 Event-driven коммуникация

#### Kafka Topics:
1. **user-events** - события пользователей
   - USER_CREATED, USER_UPDATED, USER_DELETED

2. **product-events** - события продуктов
   - PRODUCT_CREATED, PRODUCT_UPDATED, PRODUCT_DELETED

#### Межсервисное общение:
- User Service → публикует события → Product Service получает
- Product Service → публикует события → User Service получает
- Все события трассируются через мониторинг

### 📚 API Endpoints

#### User Service (через Gateway: http://localhost:8080/users)
- `GET /users` - Получить всех пользователей
- `POST /users` - Создать пользователя (+ Kafka событие + метрики)
- `PUT /users/{id}` - Обновить пользователя
- `DELETE /users/{id}` - Удалить пользователя
- `GET /users/{id}` - Получить пользователя по ID
- `GET /users/department/{dept}` - Пользователи по отделу

#### Product Service (через Gateway: http://localhost:8080/products)
- `GET /products` - Получить все продукты
- `POST /products` - Создать продукт (+ Kafka событие + метрики)
- `PUT /products/{id}` - Обновить продукт
- `DELETE /products/{id}` - Удалить продукт
- `GET /products/{id}` - Получить продукт по ID
- `GET /products/category/{category}` - Продукты по категории
- `PATCH /products/{id}/activate` - Активировать продукт
- `PATCH /products/{id}/deactivate` - Деактивировать продукт

### 🧪 Тестирование

#### Automated Test Suite:
```bash
# Запуск всех тестов
./test-apis.sh

# CI/CD интеграционные тесты
./scripts/ci-cd-test.sh

# Деплой в staging с тестами
./scripts/deploy-staging.sh
```

#### Test Environments:
- **Test**: docker-compose.test.yml - изолированное тестирование
- **Staging**: docker-compose.staging.yml - pre-production тесты
- **Production**: docker-compose.prod.yml - production deployment

### 📈 Мониторинг и метрики

#### Custom Application Metrics:
- `users_created_total, users_updated_total, users_deleted_total`
- `products_created_total, products_updated_total, products_deleted_total`  
- `user_creation_duration, product_creation_duration`
- `http_server_requests_seconds` - latency метрики
- `kafka_producer_*` и `kafka_consumer_*` метрики

#### Dashboards:
- **Grafana Microservices Overview** - статус сервисов, latency, throughput
- **Jenkins Pipeline Dashboard** - build статус, deployment metrics
- **Kafka Dashboard** - message throughput, consumer lag
- **Infrastructure Dashboard** - CPU, memory, disk usage

### 🗄️ База данных

**PostgreSQL databases:**
- `user_db` - данные пользователей
- `product_db` - данные продуктов

**Multi-environment support:**
- Development: H2 in-memory
- Test: PostgreSQL test instance
- Staging: PostgreSQL staging
- Production: PostgreSQL с backups

### 🔐 Security & Quality

#### Code Quality:
- **Maven Checkstyle** - code style enforcement
- **SpotBugs** - static analysis
- **JaCoCo** - code coverage reporting
- **OWASP Dependency Check** - vulnerability scanning

#### Security:
- **Docker security scanning** - image vulnerability check
- **Secrets management** - environment-based configuration
- **Network isolation** - Docker networks
- **Access control** - Jenkins role-based security

### 🏗️ Development Workflow

#### Git Flow:
```
main branch    → production deployments
develop branch → staging deployments  
feature/*      → feature development
release/*      → release preparation
hotfix/*       → production hotfixes
```

#### Pipeline Triggers:
- **Push to develop** → automatic staging deployment
- **Push to main** → production deployment (with approval)
- **Pull Requests** → automated testing and quality checks
- **Manual triggers** → on-demand builds and deployments

### 🚀 Следующие фазы развития

- **Фаза 5:** Kubernetes + Dashboard (container orchestration)
- **Фаза 6:** Jira, TestIT, Confluent (external integrations)
- **Фаза 7:** Production deployment (VPS/DNS setup)

### 🎯 Production Ready Features

✅ **High Availability** - service redundancy и load balancing  
✅ **Monitoring & Alerting** - comprehensive observability  
✅ **Automated Recovery** - health checks и auto-restart  
✅ **Security** - vulnerability scanning и secrets management  
✅ **Scalability** - horizontal scaling ready  
✅ **Backup & Recovery** - database backups и rollback procedures  
✅ **Documentation** - comprehensive API и deployment docs  

**ФАЗА 4 завершена! Полный CI/CD pipeline с Jenkins готов для production использования! 🎉🔄**