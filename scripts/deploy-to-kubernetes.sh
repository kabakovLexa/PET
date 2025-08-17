#!/bin/bash

echo "🚀 Deploying microservices to Kubernetes..."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE=${NAMESPACE:-"microservices"}
HELM_RELEASE_NAME=${HELM_RELEASE_NAME:-"microservices"}
BUILD_VERSION=${BUILD_VERSION:-"latest"}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${BLUE}=== Checking Prerequisites ===${NC}"

if ! command_exists kubectl; then
    echo -e "${RED}❌ kubectl not found${NC}"
    exit 1
fi

if ! command_exists helm; then
    echo -e "${RED}❌ Helm not found${NC}"
    exit 1
fi

if ! command_exists docker; then
    echo -e "${RED}❌ Docker not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Check if cluster is available
echo -e "${BLUE}=== Checking Kubernetes Cluster ===${NC}"
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo -e "${RED}❌ Kubernetes cluster not available${NC}"
    echo "Please run: ./scripts/setup-kubernetes.sh"
    exit 1
fi

echo -e "${GREEN}✅ Kubernetes cluster is available${NC}"

# Build Docker images for Kubernetes
echo -e "${BLUE}=== Building Docker Images ===${NC}"

# Build images with Kind-compatible tags
SERVICES=("discovery-service" "api-gateway" "user-service" "product-service")

for service in "${SERVICES[@]}"; do
    echo -e "${YELLOW}Building $service...${NC}"
    docker build -t "${service}:${BUILD_VERSION}" "./${service}/"
    
    # Load images into Kind cluster
    kind load docker-image "${service}:${BUILD_VERSION}" --name microservices-cluster
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $service built and loaded into cluster${NC}"
    else
        echo -e "${RED}❌ Failed to build $service${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✅ All Docker images built and loaded${NC}"

# Deploy using raw Kubernetes manifests (alternative approach)
echo -e "${BLUE}=== Deploying Infrastructure Components ===${NC}"

# Deploy PostgreSQL
echo -e "${YELLOW}Deploying PostgreSQL...${NC}"
kubectl apply -f kubernetes/postgres-deployment.yaml
kubectl rollout status statefulset/postgres -n "$NAMESPACE" --timeout=300s

# Deploy Kafka
echo -e "${YELLOW}Deploying Kafka...${NC}"
kubectl apply -f kubernetes/kafka-deployment.yaml
kubectl rollout status statefulset/zookeeper -n "$NAMESPACE" --timeout=300s
kubectl rollout status statefulset/kafka -n "$NAMESPACE" --timeout=300s

echo -e "${GREEN}✅ Infrastructure components deployed${NC}"

# Deploy microservices
echo -e "${BLUE}=== Deploying Microservices ===${NC}"
kubectl apply -f kubernetes/microservices-deployment.yaml

# Wait for deployments to be ready
echo -e "${YELLOW}Waiting for microservices to be ready...${NC}"
for service in "${SERVICES[@]}"; do
    kubectl rollout status deployment/"${service}" -n "$NAMESPACE" --timeout=300s
done

echo -e "${GREEN}✅ Microservices deployed successfully${NC}"

# Deploy monitoring
echo -e "${BLUE}=== Deploying Monitoring Stack ===${NC}"

# Create monitoring namespace and RBAC
kubectl apply -f kubernetes/monitoring/prometheus-rbac.yaml

# Deploy Prometheus using Helm
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.service.type=NodePort \
  --set prometheus.service.nodePort=30090 \
  --set grafana.service.type=NodePort \
  --set grafana.service.nodePort=30000 \
  --set grafana.adminPassword=admin123

echo -e "${GREEN}✅ Monitoring stack deployed${NC}"

# Health checks
echo -e "${BLUE}=== Running Health Checks ===${NC}"

# Check service health
check_service_health() {
    local service_name=$1
    local namespace=$2
    
    echo -e "${YELLOW}Checking health of $service_name...${NC}"
    
    # Check if pods are running
    running_pods=$(kubectl get pods -n "$namespace" -l app="$service_name" --field-selector=status.phase=Running --no-headers | wc -l)
    total_pods=$(kubectl get pods -n "$namespace" -l app="$service_name" --no-headers | wc -l)
    
    if [ "$running_pods" -eq "$total_pods" ] && [ "$total_pods" -gt 0 ]; then
        echo -e "${GREEN}✅ $service_name is healthy ($running_pods/$total_pods pods running)${NC}"
        return 0
    else
        echo -e "${RED}❌ $service_name is unhealthy ($running_pods/$total_pods pods running)${NC}"
        return 1
    fi
}

HEALTH_CHECK_FAILED=false

# Check infrastructure
if ! check_service_health "postgres" "$NAMESPACE"; then
    HEALTH_CHECK_FAILED=true
fi

if ! check_service_health "kafka" "$NAMESPACE"; then
    HEALTH_CHECK_FAILED=true
fi

# Check microservices
for service in "${SERVICES[@]}"; do
    if ! check_service_health "$service" "$NAMESPACE"; then
        HEALTH_CHECK_FAILED=true
    fi
done

# Port forward services for testing
echo -e "${BLUE}=== Setting up Port Forwards ===${NC}"

echo -e "${YELLOW}Setting up port forwards...${NC}"

# Kill existing port forwards
pkill -f "kubectl.*port-forward" || true
sleep 2

# Start new port forwards in background
kubectl port-forward svc/api-gateway 8080:8080 -n "$NAMESPACE" > /dev/null 2>&1 &
kubectl port-forward svc/discovery-service 8761:8761 -n "$NAMESPACE" > /dev/null 2>&1 &
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring > /dev/null 2>&1 &
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring > /dev/null 2>&1 &

echo -e "${GREEN}✅ Port forwards configured${NC}"

# Display deployment summary
echo -e "${BLUE}=== Deployment Summary ===${NC}"

if [ "$HEALTH_CHECK_FAILED" = false ]; then
    echo -e "${GREEN}🎉 Deployment successful!${NC}"
    
    echo -e "${PURPLE}📊 Cluster Information:${NC}"
    echo "• Namespace: $NAMESPACE"
    echo "• Helm Release: $HELM_RELEASE_NAME"
    echo "• Build Version: $BUILD_VERSION"
    echo ""
    
    echo -e "${PURPLE}🌐 Service Access (via port-forward):${NC}"
    echo "• API Gateway: http://localhost:8080"
    echo "• Eureka Dashboard: http://localhost:8761"
    echo "• Grafana: http://localhost:3000 (admin/admin123)"
    echo "• Prometheus: http://localhost:9090"
    echo ""
    
    echo -e "${PURPLE}☸️ Kubernetes Resources:${NC}"
    kubectl get pods,services,deployments -n "$NAMESPACE"
    echo ""
    
    echo -e "${YELLOW}📚 Useful Commands:${NC}"
    echo "• View pods: kubectl get pods -n $NAMESPACE"
    echo "• View logs: kubectl logs -f deployment/api-gateway -n $NAMESPACE"
    echo "• Scale service: kubectl scale deployment/user-service --replicas=3 -n $NAMESPACE"
    echo "• Delete deployment: helm uninstall $HELM_RELEASE_NAME -n $NAMESPACE"
    echo ""
    
    echo -e "${BLUE}🧪 Test the deployment:${NC}"
    echo "   ./scripts/test-kubernetes.sh"
    
else
    echo -e "${RED}❌ Deployment completed with issues${NC}"
    echo -e "${YELLOW}Check pod logs for troubleshooting:${NC}"
    echo "   kubectl logs -n $NAMESPACE -l app=user-service"
    echo "   kubectl describe pods -n $NAMESPACE"
    exit 1
fi