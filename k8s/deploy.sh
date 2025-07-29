#!/bin/bash

# E-commerce Application Kubernetes Deployment Script
set -e

echo "🚀 Starting E-commerce Application Kubernetes Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl and try again."
    exit 1
fi

print_status "Building Docker images..."

# Build backend image
print_status "Building backend image..."
cd ..
docker build -t ecom-backend:latest .

# Build frontend image
print_status "Building frontend image..."
cd ../ecom-frontend
docker build -t ecom-frontend:latest .
cd ../ecom-backend

print_status "Creating Kubernetes namespace..."
kubectl apply -f k8s/namespace.yaml

print_status "Deploying MongoDB..."
kubectl apply -f k8s/mongodb-configmap.yaml
kubectl apply -f k8s/mongodb-pvc.yaml
kubectl apply -f k8s/mongodb-deployment.yaml

print_status "Waiting for MongoDB to be ready..."
kubectl wait --for=condition=ready pod -l app=mongodb -n ecommerce --timeout=300s

print_status "Deploying Backend..."
kubectl apply -f k8s/backend-configmap.yaml
kubectl apply -f k8s/backend-deployment.yaml

print_status "Waiting for Backend to be ready..."
kubectl wait --for=condition=ready pod -l app=ecom-backend -n ecommerce --timeout=300s

print_status "Deploying Frontend..."
kubectl apply -f k8s/frontend-deployment.yaml

print_status "Waiting for Frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=ecom-frontend -n ecommerce --timeout=300s

print_status "Deploying Ingress..."
kubectl apply -f k8s/ingress.yaml

print_status "Deployment completed successfully! 🎉"

# Show deployment status
echo ""
print_status "Deployment Status:"
kubectl get pods -n ecommerce
echo ""
print_status "Services:"
kubectl get services -n ecommerce
echo ""
print_status "Ingress:"
kubectl get ingress -n ecommerce

echo ""
print_warning "To access the application:"
echo "1. Add 'ecommerce.local' to your /etc/hosts file"
echo "2. Access the application at: http://ecommerce.local"
echo ""
print_warning "To check logs:"
echo "kubectl logs -f deployment/ecom-frontend -n ecommerce"
echo "kubectl logs -f deployment/ecom-backend -n ecommerce"
echo "kubectl logs -f deployment/mongodb -n ecommerce" 