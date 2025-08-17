#!/bin/bash

echo "☸️ Setting up Kubernetes cluster for microservices..."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME=${CLUSTER_NAME:-"microservices-cluster"}
NAMESPACE=${NAMESPACE:-"microservices"}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${BLUE}=== Checking Prerequisites ===${NC}"

if ! command_exists kubectl; then
    echo -e "${RED}❌ kubectl not found. Please install kubectl first.${NC}"
    echo "Installation guide: https://kubernetes.io/docs/tasks/tools/install-kubectl/"
    exit 1
fi

if ! command_exists helm; then
    echo -e "${RED}❌ Helm not found. Installing Helm...${NC}"
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

if ! command_exists kind; then
    echo -e "${YELLOW}⚠️ Kind not found. Installing Kind for local cluster...${NC}"
    # Install kind for local development
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
fi

echo -e "${GREEN}✅ Prerequisites check completed${NC}"

# Create local Kubernetes cluster with Kind
echo -e "${BLUE}=== Creating Kubernetes Cluster ===${NC}"

# Check if cluster already exists
if kind get clusters | grep -q "$CLUSTER_NAME"; then
    echo -e "${YELLOW}⚠️ Cluster '$CLUSTER_NAME' already exists${NC}"
    read -p "Do you want to recreate it? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting existing cluster..."
        kind delete cluster --name "$CLUSTER_NAME"
    else
        echo "Using existing cluster..."
    fi
fi

if ! kind get clusters | grep -q "$CLUSTER_NAME"; then
    echo -e "${YELLOW}Creating new Kind cluster '$CLUSTER_NAME'...${NC}"
    cat <<EOF | kind create cluster --name "$CLUSTER_NAME" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 30080
    hostPort: 8080
    protocol: TCP
  - containerPort: 30090
    hostPort: 9090
    protocol: TCP
  - containerPort: 30000
    hostPort: 3000
    protocol: TCP
- role: worker
- role: worker
EOF
fi

# Set kubectl context
kubectl config use-context "kind-$CLUSTER_NAME"
echo -e "${GREEN}✅ Cluster '$CLUSTER_NAME' is ready${NC}"

# Install NGINX Ingress Controller
echo -e "${BLUE}=== Installing NGINX Ingress Controller ===${NC}"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for ingress controller to be ready
echo -e "${YELLOW}Waiting for ingress controller...${NC}"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

echo -e "${GREEN}✅ NGINX Ingress Controller installed${NC}"

# Create namespaces
echo -e "${BLUE}=== Creating Namespaces ===${NC}"
kubectl apply -f kubernetes/namespace.yaml
echo -e "${GREEN}✅ Namespaces created${NC}"

# Install Kubernetes Dashboard
echo -e "${BLUE}=== Installing Kubernetes Dashboard ===${NC}"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Apply dashboard user configuration
kubectl apply -f kubernetes/dashboard/dashboard-deployment.yaml

echo -e "${GREEN}✅ Kubernetes Dashboard installed${NC}"

# Install ArgoCD
echo -e "${BLUE}=== Installing ArgoCD ===${NC}"
kubectl apply -f kubernetes/argocd/argocd-namespace.yaml
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo -e "${YELLOW}Waiting for ArgoCD to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo -e "${GREEN}✅ ArgoCD installed${NC}"

# Add Helm repositories
echo -e "${BLUE}=== Adding Helm Repositories ===${NC}"
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo -e "${GREEN}✅ Helm repositories added${NC}"

# Get dashboard token
echo -e "${BLUE}=== Getting Access Information ===${NC}"

# Kubernetes Dashboard token
echo -e "${PURPLE}Kubernetes Dashboard Token:${NC}"
kubectl -n kubernetes-dashboard create token admin-user

# ArgoCD admin password
echo -e "${PURPLE}ArgoCD Admin Password:${NC}"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

echo -e "${GREEN}🎉 Kubernetes setup completed!${NC}"
echo ""
echo -e "${BLUE}📊 Access Information:${NC}"
echo "• Kubernetes Dashboard: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
echo "  Run: kubectl proxy"
echo ""
echo "• ArgoCD: http://localhost:8080"
echo "  Run: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  Username: admin"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Run: ./scripts/deploy-to-kubernetes.sh"
echo "2. Access dashboards using the information above"
echo "3. Configure ArgoCD applications for GitOps"