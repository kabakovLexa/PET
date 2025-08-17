#!/bin/bash

echo "🧹 Cleaning up Kubernetes resources..."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME=${CLUSTER_NAME:-"microservices-cluster"}
NAMESPACE=${NAMESPACE:-"microservices"}

echo -e "${YELLOW}This will delete the entire Kubernetes cluster and all resources.${NC}"
read -p "Are you sure you want to proceed? (y/N): " -r

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo -e "${BLUE}=== Cleaning up Kubernetes resources ===${NC}"

# Stop port forwards
echo -e "${YELLOW}Stopping port forwards...${NC}"
pkill -f "kubectl.*port-forward" || true

# Delete Helm releases
echo -e "${YELLOW}Deleting Helm releases...${NC}"
helm list --all-namespaces -q | xargs -I {} helm uninstall {} || true

# Delete namespaces
echo -e "${YELLOW}Deleting namespaces...${NC}"
kubectl delete namespace $NAMESPACE --ignore-not-found=true
kubectl delete namespace microservices-staging --ignore-not-found=true
kubectl delete namespace microservices-prod --ignore-not-found=true
kubectl delete namespace monitoring --ignore-not-found=true
kubectl delete namespace argocd --ignore-not-found=true

# Delete Kind cluster
echo -e "${YELLOW}Deleting Kind cluster...${NC}"
if command -v kind >/dev/null 2>&1; then
    kind delete cluster --name "$CLUSTER_NAME"
    echo -e "${GREEN}✅ Kind cluster deleted${NC}"
else
    echo -e "${YELLOW}⚠️ Kind not found, skipping cluster deletion${NC}"
fi

# Clean up Docker images
echo -e "${YELLOW}Cleaning up Docker images...${NC}"
docker images | grep -E "(discovery-service|api-gateway|user-service|product-service)" | awk '{print $3}' | xargs -I {} docker rmi {} -f 2>/dev/null || true

echo -e "${GREEN}🎉 Kubernetes cleanup completed!${NC}"
echo ""
echo -e "${BLUE}To recreate the environment:${NC}"
echo "   ./scripts/setup-kubernetes.sh"
echo "   ./scripts/deploy-to-kubernetes.sh"