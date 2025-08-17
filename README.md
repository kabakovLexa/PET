# Java Microservices Project для тестировщиков

## 🚀 Архитектура проекта

Этот проект представляет собой современную микросервисную архитектуру на Java с полным DevOps стеком, включающим Kubernetes orchestration, CI/CD pipeline, event-driven коммуникацию и production-ready мониторинг.

### 📋 Микросервисы (ФАЗА 5 - Kubernetes)

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
- **Jenkins** - автоматизация сборки и деплоя
- **Automated Testing** - unit, integration, smoke tests
- **Docker Registry** - хранение Docker images
- **Multi-environment deployment** (test, staging, production)

#### ФАЗА 5 - Kubernetes Orchestration:
- ✅ **Kubernetes Cluster** - container orchestration с Kind
- ✅ **Kubernetes Dashboard** - веб-интерфейс для управления кластером
- ✅ **Helm Charts** - пакетный менеджер для Kubernetes
- ✅ **ArgoCD** - GitOps continuous delivery
- ✅ **Service Mesh Ready** - подготовка к Istio
- ✅ **Horizontal Pod Autoscaler** - автоматическое масштабирование
- ✅ **Ingress Controller** - управление внешним трафиком
- ✅ **Persistent Volumes** - хранилище для stateful сервисов

### 🌐 Архитектурная диаграмма

```
                    ┌─────────────────────────────────────┐
                    │           Kubernetes Cluster        │
                    │                                     │
┌─────────────────┐ │  ┌─────────────┐ ┌─────────────────┐ │ ┌─────────────────┐
│   ArgoCD        │◄┼──┤ Helm Charts ├─┤ K8s Dashboard  │ │ │    Jenkins      │
│   GitOps        │ │  └─────────────┘ └─────────────────┘ │ │    CI/CD        │
└─────────────────┘ │                                     │ └─────────────────┘
                    │  ┌─────────────┐ ┌─────────────────┐ │
                    │  │   Ingress   │ │   Service Mesh  │ │
                    │  │ Controller  │ │   (Istio Ready) │ │
                    │  └─────────────┘ └─────────────────┘ │
                    │                                     │
                    │  ┌─────────────┐ ┌─────────────────┐ │
                    │  │ User Service│ │Product Service  │ │
                    │  │ (2 replicas)│ │  (2 replicas)   │ │
                    │  └─────────────┘ └─────────────────┘ │
                    │         │                │          │
                    │         ▼                ▼          │
                    │  ┌─────────────────────────────────┐ │
                    │  │        Apache Kafka             │ │
                    │  │   (StatefulSet + PV)           │ │
                    │  └─────────────────────────────────┘ │
                    │         ▲                           │
                    │         │                           │
                    │  ┌─────────────┐ ┌─────────────────┐ │
                    │  │API Gateway  │ │Discovery Service│ │
                    │  │(3 replicas) │ │  (2 replicas)   │ │
                    │  └─────────────┘ └─────────────────┘ │
                    │         ▲                           │
                    │         │                           │
                    │  ┌─────────────────────────────────┐ │
                    │  │       PostgreSQL                │ │
                    │  │   (StatefulSet + PV)           │ │
                    │  └─────────────────────────────────┘ │
                    └─────────────────────────────────────┘
```

### 🚦 Быстрый старт

#### Docker Compose (развертывание для разработки):
```bash
./build.sh
./start.sh
./test-apis.sh
```

#### Kubernetes (production-ready развертывание):
```bash
# 1. Настройка Kubernetes кластера
./scripts/setup-kubernetes.sh

# 2. Развертывание микросервисов  
./scripts/deploy-to-kubernetes.sh

# 3. Тестирование развертывания
./scripts/test-kubernetes.sh

# 4. Использование Helm
helm install microservices ./helm/microservices -n microservices --create-namespace

# 5. Обновление через Helm
helm upgrade microservices ./helm/microservices -n microservices
```

### 📊 Доступные сервисы

#### Docker Compose mode:
- **Eureka Dashboard**: http://localhost:8761
- **API Gateway**: http://localhost:8080  
- **Jenkins**: http://localhost:8085 (admin/admin123)
- **Grafana**: http://localhost:3000 (admin/admin123)
- **Prometheus**: http://localhost:9090
- **Kibana**: http://localhost:5601
- **Kafka UI**: http://localhost:8090

#### Kubernetes mode:
- **API Gateway**: http://localhost:8080 (port-forward)
- **Kubernetes Dashboard**: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
- **ArgoCD**: http://localhost:8080 (port-forward)
- **Grafana**: http://localhost:3000 (port-forward)
- **Prometheus**: http://localhost:9090 (port-forward)

### ☸️ Kubernetes Features

#### Orchestration:
- **Kind Cluster** - локальный Kubernetes кластер для разработки
- **Multi-node Setup** - 1 control-plane + 2 worker nodes
- **Ingress Controller** - NGINX для управления внешним трафиком
- **Service Discovery** - Kubernetes native + Eureka hybrid
- **Load Balancing** - автоматическое между репликами

#### Storage:
- **Persistent Volumes** - для PostgreSQL и Kafka данных
- **StatefulSets** - для stateful сервисов (DB, Kafka)
- **Dynamic Provisioning** - автоматическое создание PV

#### Scaling:
- **Horizontal Pod Autoscaler** - автомасштабирование по CPU/Memory
- **Manual Scaling** - `kubectl scale deployment/user-service --replicas=5`
- **Resource Limits** - CPU/Memory limits для всех pods

#### Monitoring:
- **Prometheus Operator** - автоматический monitoring stack
- **Grafana Dashboards** - предустановленные дашборды
- **Health Probes** - liveness и readiness проверки
- **Metrics Scraping** - автоматический сбор метрик

#### Security:
- **RBAC** - Role-Based Access Control
- **Service Accounts** - dedicated для каждого сервиса
- **Network Policies** - изоляция трафика между namespace
- **Secrets Management** - encrypted secrets для паролей

### 🎯 Helm Charts

#### Основной чарт `./helm/microservices/`:
```bash
# Установка в development
helm install dev-microservices ./helm/microservices \
  --namespace microservices \
  --create-namespace

# Установка в staging
helm install staging-microservices ./helm/microservices \
  --namespace microservices-staging \
  --create-namespace \
  --values helm/microservices/values-staging.yaml

# Обновление
helm upgrade microservices ./helm/microservices
```

#### Features:
- **Dependency Management** - автоматическая установка PostgreSQL, Kafka
- **Environment-specific Values** - разные конфигурации для разных сред
- **ConfigMap/Secret Management** - централизованная конфигурация
- **Service Templates** - переиспользуемые шаблоны
- **Ingress Configuration** - автоматическая настройка внешнего доступа

### 🔄 GitOps с ArgoCD

#### ArgoCD Applications:
```yaml
# Development
argocd-application: microservices-app
target: HEAD branch
namespace: microservices

# Staging  
argocd-application: microservices-staging
target: develop branch
namespace: microservices-staging

# Production
argocd-application: microservices-production
target: main branch
namespace: microservices-prod (manual sync)
```

#### GitOps Workflow:
1. **Code Push** → Git Repository
2. **ArgoCD** → автоматический sync изменений
3. **Helm** → deployment в Kubernetes
4. **Monitoring** → проверка health через Prometheus/Grafana

### 📚 API Endpoints

#### Kubernetes Service Discovery:
- Сервисы доступны по DNS именам: `http://user-service:8081`
- Внешний доступ через API Gateway: `http://api-gateway:8080`
- Load balancing автоматически между репликами

#### Health Checks:
```bash
# Kubernetes health probes
curl http://user-service:8081/actuator/health/liveness
curl http://user-service:8081/actuator/health/readiness

# Через API Gateway
curl http://localhost:8080/users/health
curl http://localhost:8080/products/health
```

### 🧪 Testing в Kubernetes

#### Automated Tests:
```bash
# Полное тестирование Kubernetes deployment
./scripts/test-kubernetes.sh

# Тестирование scaling
kubectl scale deployment/user-service --replicas=5 -n microservices
kubectl get pods -n microservices -w

# Rolling update testing
kubectl set image deployment/user-service user-service=user-service:v2 -n microservices
kubectl rollout status deployment/user-service -n microservices
```

#### Load Testing:
```bash
# Создание нагрузки для тестирования HPA
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh
while true; do wget -q -O- http://api-gateway:8080/users; done
```

### 📈 Мониторинг в Kubernetes

#### Prometheus Stack:
- **Prometheus Operator** - automated monitoring setup
- **ServiceMonitor** - автоматическое обнаружение сервисов
- **AlertManager** - уведомления о проблемах
- **Node Exporter** - мониторинг узлов кластера

#### Grafana Dashboards:
- **Kubernetes Cluster Overview** - статус узлов, pods, deployments
- **Microservices Dashboard** - business метрики приложений
- **JVM Dashboard** - Java application metrics
- **Kafka Dashboard** - messaging metrics

### 🔧 Operations

#### Debugging:
```bash
# Логи сервиса
kubectl logs -f deployment/user-service -n microservices

# Описание проблемы
kubectl describe pod <pod-name> -n microservices

# Выполнение команд в контейнере
kubectl exec -it <pod-name> -n microservices -- /bin/bash

# Port forwarding для локального доступа
kubectl port-forward svc/api-gateway 8080:8080 -n microservices
```

#### Scaling Operations:
```bash
# Manual scaling
kubectl scale deployment/user-service --replicas=3 -n microservices

# Autoscaling
kubectl autoscale deployment user-service --cpu-percent=50 --min=2 --max=10 -n microservices

# Check HPA status
kubectl get hpa -n microservices
```

#### Updates:
```bash
# Rolling update
kubectl set image deployment/user-service user-service=user-service:v2 -n microservices

# Rollback
kubectl rollout undo deployment/user-service -n microservices

# History
kubectl rollout history deployment/user-service -n microservices
```

### 🏗️ Следующие фазы развития

- **Фаза 6:** Jira, TestIT, Confluent (external integrations)
- **Фаза 7:** Production deployment (VPS/DNS setup + Service Mesh)

### 🎯 Production Ready Features

✅ **Container Orchestration** - Kubernetes для автоматического управления  
✅ **High Availability** - несколько реплик каждого сервиса  
✅ **Auto-scaling** - HPA для динамического масштабирования  
✅ **Service Discovery** - Kubernetes native + hybrid Eureka  
✅ **Load Balancing** - автоматическое между репликами  
✅ **Rolling Updates** - zero-downtime deployments  
✅ **Health Monitoring** - liveness/readiness probes  
✅ **Resource Management** - CPU/Memory limits и requests  
✅ **Persistent Storage** - для stateful сервисов  
✅ **GitOps Workflow** - ArgoCD для automated deployments  
✅ **Observability** - полный monitoring stack в Kubernetes  
✅ **Security** - RBAC, service accounts, network policies  

**ФАЗА 5 завершена! Enterprise-grade Kubernetes orchestration готова для production использования! ☸️🚀**