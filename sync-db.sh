#!/bin/bash

# Database Synchronization Script
# Syncs data between local MongoDB and Podman MongoDB

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
LOCAL_DB="ecom"
CONTAINER_DB="ecom"
BACKUP_DIR="./db-backups"
DATE=$(date +%Y%m%d_%H%M%S)

print_status "Starting database synchronization..."

# Create backup directory
mkdir -p $BACKUP_DIR

# Function to backup local database
backup_local_db() {
    print_status "Backing up local MongoDB..."
    mongodump --db $LOCAL_DB --out "$BACKUP_DIR/local_backup_$DATE"
    print_status "Local backup completed: $BACKUP_DIR/local_backup_$DATE"
}

# Function to backup container database
backup_container_db() {
    print_status "Backing up container MongoDB..."
    podman exec ecom-mongodb mongodump --db $CONTAINER_DB --out "/tmp/container_backup_$DATE"
    podman cp "ecom-mongodb:/tmp/container_backup_$DATE" "$BACKUP_DIR/"
    print_status "Container backup completed: $BACKUP_DIR/container_backup_$DATE"
}

# Function to sync local to container
sync_local_to_container() {
    print_status "Syncing local data to container..."
    
    # Create backup first
    backup_local_db
    
    # Export local data to current directory
    mongodump --db $LOCAL_DB --out "./local_export_$DATE"
    
    # Copy to container
    podman cp "./local_export_$DATE" "ecom-mongodb:/tmp/"
    
    # Import into container with authentication
    podman exec ecom-mongodb mongorestore --username admin --password password123 --authenticationDatabase admin --db $CONTAINER_DB --drop "/tmp/local_export_$DATE/$LOCAL_DB"
    
    # Cleanup
    rm -rf "./local_export_$DATE"
    podman exec ecom-mongodb rm -rf "/tmp/local_export_$DATE"
    
    print_status "Sync completed: Local → Container"
}

# Function to sync container to local
sync_container_to_local() {
    print_status "Syncing container data to local..."
    
    # Create backup first
    backup_container_db
    
    # Export container data
    podman exec ecom-mongodb mongodump --db $CONTAINER_DB --out "/tmp/container_export_$DATE"
    
    # Copy to host
    podman cp "ecom-mongodb:/tmp/container_export_$DATE" "./"
    
    # Import into local
    mongorestore --db $LOCAL_DB --drop "./container_export_$DATE/$CONTAINER_DB"
    
    # Cleanup
    rm -rf "./container_export_$DATE"
    podman exec ecom-mongodb rm -rf "/tmp/container_export_$DATE"
    
    print_status "Sync completed: Container → Local"
}

# Function to show sync status
show_status() {
    print_status "Database Status:"
    echo "Local MongoDB collections:"
    mongosh $LOCAL_DB --eval "db.getCollectionNames().forEach(printjson)" --quiet
    
    echo ""
    echo "Container MongoDB collections:"
    podman exec ecom-mongodb mongosh --username admin --password password123 --authenticationDatabase admin $CONTAINER_DB --eval "db.getCollectionNames().forEach(printjson)" --quiet
}

# Main script logic
case "$1" in
    "local-to-container")
        sync_local_to_container
        ;;
    "container-to-local")
        sync_container_to_local
        ;;
    "backup-local")
        backup_local_db
        ;;
    "backup-container")
        backup_container_db
        ;;
    "status")
        show_status
        ;;
    "auto-sync")
        # Auto-sync based on timestamp comparison
        print_status "Auto-sync mode - syncing local to container"
        sync_local_to_container
        ;;
    *)
        echo "Usage: $0 {local-to-container|container-to-local|backup-local|backup-container|status|auto-sync}"
        echo ""
        echo "Commands:"
        echo "  local-to-container  - Sync local MongoDB to container"
        echo "  container-to-local  - Sync container MongoDB to local"
        echo "  backup-local        - Backup local MongoDB"
        echo "  backup-container    - Backup container MongoDB"
        echo "  status             - Show database status"
        echo "  auto-sync          - Auto-sync local to container"
        echo ""
        echo "Recommended workflow:"
        echo "  1. Use local MongoDB for development"
        echo "  2. Run: $0 local-to-container (when ready to deploy)"
        echo "  3. Use container MongoDB for production testing"
        ;;
esac 