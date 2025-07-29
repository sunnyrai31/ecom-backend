#!/bin/bash

# E-commerce Backend Deployment Script for Podman
# This script provides easy deployment options for the e-commerce backend

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  E-commerce Backend Deployment${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Check if Podman is installed
check_podman() {
    if ! command -v podman &> /dev/null; then
        print_error "Podman is not installed. Please install Podman first."
        exit 1
    fi
    print_status "Podman is available"
}

# Clean up existing containers
cleanup() {
    print_status "Cleaning up existing containers..."
    podman stop ecom-backend ecom-mongodb 2>/dev/null || true
    podman rm ecom-backend ecom-mongodb 2>/dev/null || true
    podman network rm ecom-network 2>/dev/null || true
}

# Build the application
build_app() {
    print_status "Building e-commerce backend image..."
    podman build -t ecom-backend .
    print_status "Build completed successfully"
}

# Deploy with MongoDB
deploy_with_mongodb() {
    print_status "Deploying with MongoDB..."
    
    # Create network
    podman network create ecom-network 2>/dev/null || true
    
    # Start MongoDB
    print_status "Starting MongoDB..."
    podman run -d \
        --name ecom-mongodb \
        --network ecom-network \
        -p 27017:27017 \
        -e MONGO_INITDB_ROOT_USERNAME=admin \
        -e MONGO_INITDB_ROOT_PASSWORD=password123 \
        -e MONGO_INITDB_DATABASE=ecom \
        -v mongodb_data:/data/db \
        -v ./mongo-init:/docker-entrypoint-initdb.d:Z \
        mongo:7.0
    
    # Wait for MongoDB to be ready
    print_status "Waiting for MongoDB to be ready..."
    sleep 10
    
    # Start the backend
    print_status "Starting e-commerce backend..."
    podman run -d \
        --name ecom-backend \
        --network ecom-network \
        -p 4201:4201 \
        -e NODE_ENV=production \
        -e PORT=4201 \
        -e MONGO_URI="mongodb://admin:password123@ecom-mongodb:27017/ecom?authSource=admin" \
        ecom-backend
    
    print_status "Deployment completed successfully!"
}

# Deploy backend only (requires external MongoDB)
deploy_backend_only() {
    print_status "Deploying backend only..."
    
    if [ -z "$MONGO_URI" ]; then
        print_error "MONGO_URI environment variable is required for backend-only deployment"
        print_warning "Please set MONGO_URI or use the full deployment option"
        exit 1
    fi
    
    podman run -d \
        --name ecom-backend \
        -p 4201:4201 \
        -e NODE_ENV=production \
        -e PORT=4201 \
        -e MONGO_URI="$MONGO_URI" \
        ecom-backend
    
    print_status "Backend deployment completed!"
}

# Health check
health_check() {
    print_status "Performing health check..."
    
    # Wait for application to start
    sleep 5
    
    # Check if containers are running
    if ! podman ps | grep -q ecom-backend; then
        print_error "Backend container is not running"
        return 1
    fi
    
    # Test health endpoint
    if curl -f http://localhost:4201/health > /dev/null 2>&1; then
        print_status "Health check passed! Application is running at http://localhost:4201"
    else
        print_warning "Health check failed. Check logs with: podman logs ecom-backend"
    fi
}

# Show logs
show_logs() {
    print_status "Showing backend logs..."
    podman logs -f ecom-backend
}

# Stop deployment
stop_deployment() {
    print_status "Stopping deployment..."
    podman stop ecom-backend ecom-mongodb 2>/dev/null || true
    print_status "Deployment stopped"
}

# Show status
show_status() {
    print_status "Container status:"
    podman ps -a --filter "name=ecom"
    
    echo ""
    print_status "Network status:"
    podman network ls | grep ecom || echo "No ecom network found"
}

# Main menu
show_menu() {
    echo ""
    echo "Choose deployment option:"
    echo "1) Deploy with MongoDB (full stack)"
    echo "2) Deploy backend only (requires MONGO_URI)"
    echo "3) Build application only"
    echo "4) Health check"
    echo "5) Show logs"
    echo "6) Stop deployment"
    echo "7) Show status"
    echo "8) Cleanup and exit"
    echo "0) Exit"
    echo ""
    read -p "Enter your choice: " choice
}

# Main execution
main() {
    print_header
    check_podman
    
    while true; do
        show_menu
        case $choice in
            1)
                cleanup
                build_app
                deploy_with_mongodb
                health_check
                ;;
            2)
                cleanup
                build_app
                deploy_backend_only
                health_check
                ;;
            3)
                build_app
                ;;
            4)
                health_check
                ;;
            5)
                show_logs
                ;;
            6)
                stop_deployment
                ;;
            7)
                show_status
                ;;
            8)
                cleanup
                print_status "Cleanup completed"
                exit 0
                ;;
            0)
                print_status "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Handle command line arguments
case "${1:-}" in
    "build")
        build_app
        ;;
    "deploy")
        cleanup
        build_app
        deploy_with_mongodb
        health_check
        ;;
    "stop")
        stop_deployment
        ;;
    "logs")
        show_logs
        ;;
    "status")
        show_status
        ;;
    "cleanup")
        cleanup
        ;;
    *)
        main
        ;;
esac 