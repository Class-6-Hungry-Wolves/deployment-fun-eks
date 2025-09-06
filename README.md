# EKS Deployment Fun

A comprehensive Amazon EKS deployment project that demonstrates infrastructure as code using Terraform, containerized application deployment, and Kubernetes orchestration.

## Overview

This repository provides a complete end-to-end solution for deploying applications on Amazon EKS (Elastic Kubernetes Service). It includes infrastructure provisioning with Terraform, container image building and pushing to ECR, and Kubernetes deployment configurations.

## Architecture

The project implements the following components:

- **Amazon EKS Cluster**: Managed Kubernetes service for container orchestration
- **Amazon ECR**: Container registry for storing Docker images
- **Terraform**: Infrastructure as Code for AWS resources
- **Kubernetes Manifests**: Application deployment configurations
- **Shell Scripts**: Automation for build and deployment processes

## Prerequisites

Before you begin, ensure you have the following installed and configured:

### Required Tools
- **AWS CLI** (v2.x recommended)
  ```bash
  aws --version
  ```
- **Terraform** (>= 1.0)
  ```bash
  terraform version
  ```
- **kubectl** (compatible with your EKS version)
  ```bash
  kubectl version --client
  ```
- **Docker** (for building container images)
  ```bash
  docker --version
  ```

### AWS Configuration
- AWS credentials configured with appropriate permissions for:
  - EKS cluster creation and management
  - ECR repository creation and image pushing
  - VPC, security groups, and IAM role management
  - EC2 instances for worker nodes

```bash
aws configure list
```

### Permissions Required
Your AWS credentials should have the following permissions:
- `AmazonEKSClusterPolicy`
- `AmazonEKSWorkerNodePolicy`
- `AmazonEKS_CNI_Policy`
- `AmazonEC2ContainerRegistryFullAccess`
- `IAMFullAccess` (for role creation)
- `VPCFullAccess`

## 🛠️ Installation & Deployment

Follow these steps to deploy the complete infrastructure and applications:

### Step 1: Configure Backend
Update the Terraform backend configuration for your environment:

```bash
# Edit terraform/backend.tf with your S3 bucket
vim terraform/backend.tf
```

### Step 2: Initialize Terraform
```bash
cd terraform
terraform init
```

### Step 3: Plan Infrastructure
Review the infrastructure that will be created:

```bash
terraform plan
```

### Step 4: Deploy Infrastructure
Create the EKS cluster and supporting AWS resources:

```bash
terraform apply
```

**Note**: This process typically takes 10-15 minutes to complete.

### Step 5: Update kubeconfig
Configure kubectl to interact with your new EKS cluster:

```bash
aws eks update-kubeconfig --region <your-region> --name <cluster-name>
```

### Step 6: Build and Push Container Images
Ensure Docker is running, then build and push your application images to ECR:

```bash
./scripts/build_and_push_ecr.sh
```

**Important**: Docker must be running for this script to work!

### Step 7: Update Kubernetes Manifests
Edit the Kubernetes deployment file to match your AWS account's ECR repository:

```bash
vim k8s/apps.yaml
```

Update the image references to match your AWS account ID:
```yaml
image: <your-account-id>.dkr.ecr.<region>.amazonaws.com/<repository-name>:<tag>
```

### Step 8: Deploy Applications
Deploy your applications to the EKS cluster:

```bash
kubectl apply -f k8s/apps.yaml
```

### Step 9: Get Service Endpoints
Retrieve the external endpoints for your deployed services:

```bash
./get_endpoints.sh
```

## Configuration Files

### Kubernetes Manifests
- **k8s/apps.yaml**: Contains deployment, service, and ingress configurations for your applications

### Scripts
- **build_and_push_ecr.sh**: Automates Docker image building and ECR pushing process
- **get_endpoints.sh**: Retrieves and displays service endpoints and load balancer URLs

## Monitoring & Troubleshooting

### Check Cluster Status
```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

### View Application Logs
```bash
kubectl logs -f deployment/<app-name>
```

### Check Service Status
```bash
kubectl get services
kubectl describe service <service-name>
```

### Common Issues

1. **ECR Authentication Issues**
   ```bash
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
   ```

2. **kubectl Access Issues**
   ```bash
   aws eks update-kubeconfig --region <region> --name <cluster-name>
   ```

3. **Image Pull Errors**
   - Verify ECR repository exists and images are pushed
   - Check IAM permissions for EKS worker nodes to access ECR

## Cleanup

To avoid ongoing AWS charges, clean up resources when done:

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/apps.yaml

# Destroy Terraform infrastructure
cd terraform
terraform destroy
```
