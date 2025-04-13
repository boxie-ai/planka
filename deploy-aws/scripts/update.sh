#!/bin/bash
# Update script for Planka AWS deployment

# Exit on any error
set -e

# Configuration
PLANKA_DIR="/opt/planka"
BACKUP_DIR="/tmp/planka_backup_before_update"

# Create backup before update
echo "Creating backup before update..."
mkdir -p $BACKUP_DIR
tar -czf "${BACKUP_DIR}/planka_data.tar.gz" $PLANKA_DIR/data

# Update Planka
echo "Updating Planka..."
cd $PLANKA_DIR

# Stash any local changes
git stash

# Pull latest changes
git pull origin master

# Update Docker images
echo "Updating Docker images..."
docker-compose pull

# Restart containers
echo "Restarting containers..."
docker-compose down
docker-compose up -d

# Wait for application to start
echo "Waiting for application to start..."
sleep 10

# Check if application is running
if curl -s http://localhost:80 > /dev/null; then
  echo "Update completed successfully!"
else
  echo "Warning: Application may not have started correctly. Please check logs with 'docker-compose logs'."
fi

echo "Backup created at: ${BACKUP_DIR}/planka_data.tar.gz"