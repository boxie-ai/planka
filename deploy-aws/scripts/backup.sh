#!/bin/bash
# Backup script for Planka AWS deployment

# Exit on any error
set -e

# Configuration
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/tmp/planka_backup_${TIMESTAMP}"
S3_BUCKET="planka-backups" # Replace with your S3 bucket name
EC2_DATA_PATH="/opt/planka/data"
RDS_INSTANCE_IDENTIFIER="planka-db" # Update based on your RDS instance name

# Create backup directory
mkdir -p $BACKUP_DIR

# Back up EC2 data files
echo "Backing up Planka data files..."
tar -czf "${BACKUP_DIR}/planka_data.tar.gz" $EC2_DATA_PATH

# Create RDS snapshot
echo "Creating RDS snapshot..."
aws rds create-db-snapshot \
  --db-instance-identifier $RDS_INSTANCE_IDENTIFIER \
  --db-snapshot-identifier "planka-snapshot-${TIMESTAMP}"

# Upload backup to S3
echo "Uploading backup to S3..."
aws s3 cp "${BACKUP_DIR}/planka_data.tar.gz" "s3://${S3_BUCKET}/planka_data_${TIMESTAMP}.tar.gz"

# Clean up
rm -rf $BACKUP_DIR

echo "Backup completed successfully!"
echo "Files backed up to: s3://${S3_BUCKET}/planka_data_${TIMESTAMP}.tar.gz"
echo "Database snapshot created: planka-snapshot-${TIMESTAMP}"