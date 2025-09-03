#!/bin/bash

# =============================================================================
# Local Docker + Kubernetes Deployment Script
# =============================================================================
# This script replaces the GitLab CI/CD pipeline for local development
# Industry Standard: Docker builds containers, Kubernetes orchestrates them

set -e  # Exit on any error

echo "🚀 Starting Industry-Standard Docker + Kubernetes Deployment"
echo "=============================================================="

# Configuration
NAMESPACE="chatapp"
BACKEND_IMAGE="chat-app-backend:latest"
FRONTEND_IMAGE="chat-app-frontend:latest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}📋 Step: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# =============================================================================
# STEP 1: Build Docker Images (Like CI/CD Build Stage)
# =============================================================================

print_step "Building Docker Images"

echo "🐳 Building Backend Docker Image..."
cd backend
docker build -t $BACKEND_IMAGE .
cd ..
print_success "Backend image built: $BACKEND_IMAGE"

echo "🐳 Building Frontend Docker Image..."
cd frontend
docker build -t $FRONTEND_IMAGE .
cd ..
print_success "Frontend image built: $FRONTEND_IMAGE"

# =============================================================================
# STEP 2: Prepare Kubernetes Manifests
# =============================================================================

print_step "Preparing Kubernetes Manifests"

# Create backup and update image placeholders in Kubernetes manifests
cp k8s/backend-deployment.yml k8s/backend-deployment.yml.bak
cp k8s/frontend-deployment.yml k8s/frontend-deployment.yml.bak

sed -i "s|BACKEND_IMAGE_PLACEHOLDER|${BACKEND_IMAGE}|g" k8s/backend-deployment.yml
sed -i "s|FRONTEND_IMAGE_PLACEHOLDER|${FRONTEND_IMAGE}|g" k8s/frontend-deployment.yml

print_success "Kubernetes manifests updated with Docker images"

# =============================================================================
# STEP 3: Check Kubernetes Cluster
# =============================================================================

print_step "Checking Kubernetes Cluster"

if ! kubectl cluster-info > /dev/null 2>&1; then
    print_error "Kubernetes cluster not accessible!"
    echo "Please ensure you have one of the following running:"
    echo "  - Docker Desktop with Kubernetes enabled"
    echo "  - Kind cluster: kind create cluster"
    echo "  - K3s: curl -sfL https://get.k3s.io | sh -"
    echo "  - Minikube: minikube start"
    exit 1
fi

print_success "Kubernetes cluster is accessible"
kubectl cluster-info

# =============================================================================
# STEP 4: Deploy to Kubernetes (Like CI/CD Deploy Stage)
# =============================================================================

print_step "Deploying to Kubernetes"

# Create namespace
echo "� Creating namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Create secrets (you'll need to set these environment variables)
echo "🔐 Creating application secrets..."
kubectl delete secret app-secrets -n $NAMESPACE --ignore-not-found=true

# Default values for local development
JWT_SECRET=${JWT_SECRET:-"your-super-secret-jwt-key-for-local-development"}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-"postgres123"}
DATABASE_URL=${DATABASE_URL:-"postgresql://chatapp_user:postgres123@postgres-service:5432/chatapp"}

kubectl create secret generic app-secrets \
    --from-literal=jwt-secret="$JWT_SECRET" \
    --from-literal=postgres-password="$POSTGRES_PASSWORD" \
    --from-literal=database-url="$DATABASE_URL" \
    --namespace=$NAMESPACE

print_success "Secrets created"

# Deploy PostgreSQL
echo "🗄️  Deploying PostgreSQL database..."
kubectl apply -f k8s/postgres-deployment.yml -n $NAMESPACE

echo "⏳ Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n $NAMESPACE --timeout=300s || print_warning "PostgreSQL pods not ready yet"

# Deploy Backend
echo "🔧 Deploying backend service..."
kubectl apply -f k8s/backend-deployment.yml -n $NAMESPACE
kubectl apply -f k8s/backend-service.yml -n $NAMESPACE

echo "⏳ Waiting for backend to be ready..."
kubectl wait --for=condition=ready pod -l app=chat-app-backend -n $NAMESPACE --timeout=300s || print_warning "Backend pods not ready yet"

# Deploy Frontend
echo "🌐 Deploying frontend service..."
kubectl apply -f k8s/frontend-deployment.yml -n $NAMESPACE
kubectl apply -f k8s/frontend-service.yml -n $NAMESPACE

# Setup Ingress (optional)
echo "🌍 Setting up ingress..."
kubectl apply -f k8s/ingress.yml -n $NAMESPACE 2>/dev/null || print_warning "Ingress not applied (may require ingress controller)"

# =============================================================================
# STEP 5: Display Results
# =============================================================================

print_step "Deployment Results"

echo ""
echo "🎉 KUBERNETES DEPLOYMENT COMPLETED!"
echo "====================================="
echo ""
echo "📊 Cluster Status:"
kubectl get pods -n $NAMESPACE -o wide 2>/dev/null || print_warning "Could not get pods"
echo ""
echo "🔗 Services:"
kubectl get services -n $NAMESPACE 2>/dev/null || print_warning "Could not get services"
echo ""
echo "🌐 Ingress:"
kubectl get ingress -n $NAMESPACE 2>/dev/null || print_warning "Could not get ingress"
echo ""
echo "🎯 Access Your Application:"
echo "================================"

# Get service ports
FRONTEND_PORT=$(kubectl get service frontend-service -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "NodePort not available")
BACKEND_PORT=$(kubectl get service backend-service -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "NodePort not available")

if [[ "$FRONTEND_PORT" != "NodePort not available" ]]; then
    echo "🌐 Frontend: http://localhost:$FRONTEND_PORT"
    echo "🔧 Backend API: http://localhost:$BACKEND_PORT"
else
    echo "🌐 Frontend: Use port-forward -> kubectl port-forward service/frontend-service 3000:80 -n $NAMESPACE"
    echo "� Backend API: Use port-forward -> kubectl port-forward service/backend-service 5000:5000 -n $NAMESPACE"
fi

echo "🏥 Health Check: Use port-forward -> kubectl port-forward service/backend-service 5000:5000 -n $NAMESPACE (then visit http://localhost:5000/health)"
echo ""
echo "� Docker Images Used:"
echo "  Backend: $BACKEND_IMAGE"
echo "  Frontend: $FRONTEND_IMAGE"
echo ""
echo "☸️  Kubernetes is now orchestrating your Docker containers!"
echo "🔄 This follows the same industry-standard pattern as Netflix, Google, and Amazon"

# =============================================================================
# USEFUL COMMANDS
# =============================================================================

echo ""
echo "📚 Useful Commands:"
echo "==================="
echo "View logs:"
echo "  kubectl logs -l app=chat-app-backend -n $NAMESPACE"
echo "  kubectl logs -l app=chat-app-frontend -n $NAMESPACE"
echo ""
echo "Port forward services:"
echo "  kubectl port-forward service/frontend-service 3000:80 -n $NAMESPACE"
echo "  kubectl port-forward service/backend-service 5000:5000 -n $NAMESPACE"
echo ""
echo "Scale applications:"
echo "  kubectl scale deployment backend-deployment --replicas=3 -n $NAMESPACE"
echo "  kubectl scale deployment frontend-deployment --replicas=2 -n $NAMESPACE"
echo ""
echo "Clean up:"
echo "  kubectl delete namespace $NAMESPACE"
echo ""

# Restore original files
echo "� Restoring original Kubernetes manifests..."
cp k8s/backend-deployment.yml.bak k8s/backend-deployment.yml
cp k8s/frontend-deployment.yml.bak k8s/frontend-deployment.yml
rm k8s/*.bak

print_success "🎊 Industry-Standard Docker + Kubernetes Deployment Complete!"
