# Planka AWS Deployment

This directory contains CloudFormation templates and CircleCI configuration to deploy Planka to AWS.

## Architecture

The deployment creates:

- A VPC with public and private subnets
- An EC2 instance running Planka in a Docker container
- An RDS PostgreSQL database instance
- Required security groups and network resources
- Route 53 DNS configuration for custom domain
- SSL certificate using Let's Encrypt

## Prerequisites

1. AWS account with appropriate permissions
2. Domain name configured in Route 53 (default: boards.boxie.ai)
3. CircleCI account connected to your GitHub repository
4. AWS credentials stored in CircleCI environment variables

## Deployment Instructions

### 1. Set up AWS credentials in CircleCI

In CircleCI project settings, add the following environment variables:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION` (e.g., us-east-1)

### 2. Configure Parameters

Edit the parameters files in the `deploy-aws` directory to customize your deployment:
- `parameters-staging.json`: Staging environment configuration
- `parameters-production.json`: Production environment configuration

### 3. Deploy

The deployment will automatically trigger when you push to the master branch.

To deploy manually:
1. Log in to CircleCI
2. Find your project
3. Go to the Pipelines tab
4. Click "Run Pipeline" and select the branch to deploy from

### 4. Post-Deployment

After deployment is complete, you'll need to:
1. Verify the DNS records are properly configured
2. Make sure SSL certificates are issued correctly
3. Create the initial admin user through the Planka interface

## Maintenance

### Backup and Restore

Automatic backups are configured for the RDS database. For additional data backup:

```bash
# SSH to the EC2 instance
ssh -i your-key.pem ec2-user@your-instance-ip

# Backup files
cd /opt/planka
tar -czf planka-data-backup.tar.gz data/

# Copy backup to S3 (recommended)
aws s3 cp planka-data-backup.tar.gz s3://your-backup-bucket/
```

### Updates

To update Planka to a newer version:

```bash
# SSH to the EC2 instance
ssh -i your-key.pem ec2-user@your-instance-ip

# Update repository and restart
cd /opt/planka
git pull
docker-compose down
docker-compose pull
docker-compose up -d
```

## Troubleshooting

Common issues:

1. **Database connection errors**: Check security groups and connection strings in the docker-compose.yml file
2. **SSL certificate issues**: Verify Let's Encrypt setup in the Nginx configuration
3. **Application not starting**: Check Docker logs with `docker-compose logs`