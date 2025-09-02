# CI/CD Pipeline Documentation

## Overview

This document describes the robust CI/CD pipeline setup for the Full-Stack Chat Application using GitLab CI/CD, Docker, and Kubernetes.

## Pipeline Architecture

The pipeline consists of 5 stages:

1. **Test** - Unit tests, linting, and build verification
2. **Security** - Security scanning and vulnerability assessment
3. **Build** - Docker image building and registry push
4. **Deploy** - Kubernetes deployment (staging/production)
5. **Post-Deploy** - Health checks and validation

## Features

### 🚀 Robust Build Process
- Multi-stage Docker builds with layer caching
- Parallel backend and frontend builds
- Automatic retries on failures
- Build artifacts preservation

### 🔒 Security-First Approach
- All secrets managed via GitLab CI/CD variables
- Kubernetes secrets for sensitive data
- Security scanning and vulnerability assessment
- Masked and protected variables

### 🎯 Environment Management
- Staging environment for development/MR testing
- Production deployment with manual approval
- Environment-specific configurations
- Health checks and rollback capabilities

### 📊 Quality Assurance
- Automated testing (unit tests, linting)
- Coverage reports and test artifacts
- Security audits with npm audit
- Health checks post-deployment

## Pipeline Stages Breakdown

### 1. Test Stage

#### `test_backend`
- Runs backend unit tests using Jest
- Generates test reports and coverage
- Caches dependencies for faster builds
- Artifacts: Test results, coverage reports

#### `lint_backend`
- ESLint code quality checks
- Ensures code style consistency
- Fails pipeline on linting errors

#### `test_frontend`
- Frontend unit tests (when available)
- Build verification
- Artifacts: Built frontend assets

### 2. Security Stage

#### `security_scan`
- npm audit for vulnerability scanning
- Checks both backend and frontend dependencies
- Allows failure (can be made strict)

### 3. Build Stage

#### `build_backend` & `build_frontend`
- Docker BuildKit for optimized builds
- Layer caching from latest images
- Multi-tag strategy (commit SHA + latest)
- Automated push to Docker registry

### 4. Deploy Stage

#### `deploy_to_staging`
- Automatic deployment for `develop` branch and MRs
- Creates Kubernetes namespace if needed
- Manages secrets via kubectl
- Rolling updates with health checks

#### `deploy_to_production`
- Manual deployment for `main` branch
- Production-grade configurations
- Enhanced monitoring and logging
- Rollback capabilities

### 5. Post-Deploy Stage

#### `health_check`
- Automated health endpoint verification
- Retry logic with timeout
- Environment-specific URL testing
- Non-blocking (allows manual intervention)

## Configuration Files

### `.gitlab-ci.yml`
Main pipeline configuration with:
- Stage definitions and job dependencies
- Docker and Kubernetes configurations
- Retry logic and error handling
- Environment-specific deployments

### `.env.example`
Template for all required environment variables:
- Docker registry credentials
- Kubernetes cluster configuration
- Application secrets (MongoDB, JWT, Cloudinary)
- Deployment settings

### `k8s/` Directory
Kubernetes manifests with:
- **configmap.yml**: Non-sensitive configuration
- **backend-deployment.yml**: Backend service with secrets
- **frontend-deployment.yml**: Frontend service
- **backend-service.yml**: Backend service exposure
- **frontend-service.yml**: Frontend service exposure
- **ingress.yml**: External traffic routing

## Setup Instructions

### 1. Prerequisites
- GitLab project with CI/CD enabled
- Kubernetes cluster access
- Docker Hub or private registry
- Domain name (for production)

### 2. Configure GitLab Variables
Run the setup script:
```bash
chmod +x setup-gitlab-variables.sh
./setup-gitlab-variables.sh
```

Or manually add these variables in GitLab (Settings > CI/CD > Variables):

#### Required Variables:
- `CI_DOCKER_USER` - Docker registry username
- `CI_DOCKER_PASSWORD` - Docker registry password (masked)
- `KUBE_SERVER` - Kubernetes API server URL
- `KUBE_NAMESPACE` - Kubernetes namespace (default: chatapp)
- `KUBE_CA_PEM` - Base64 encoded cluster CA (protected)
- `KUBE_TOKEN` - Service account token (masked, protected)
- `MONGODB_URI` - MongoDB connection string (masked)
- `JWT_SECRET` - JWT secret key (masked)
- `CLOUDINARY_CLOUD_NAME` - Cloudinary cloud name
- `CLOUDINARY_API_KEY` - Cloudinary API key
- `CLOUDINARY_API_SECRET` - Cloudinary API secret (masked)
- `DOMAIN_NAME` - Your domain name

### 3. Kubernetes Setup

#### Create Service Account:
```bash
kubectl create namespace chatapp
kubectl create serviceaccount gitlab-deploy -n chatapp
kubectl create clusterrolebinding gitlab-deploy-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=chatapp:gitlab-deploy
kubectl create token gitlab-deploy -n chatapp
```

### 4. Deploy
1. Push code to `develop` branch for staging
2. Create merge request for testing
3. Merge to `main` and manually deploy to production

## Monitoring and Troubleshooting

### Pipeline Monitoring
- Check GitLab CI/CD pipeline status
- Review job logs for errors
- Monitor resource usage and timing

### Kubernetes Monitoring
```bash
# Check deployments
kubectl get deployments -n chatapp

# Check pods
kubectl get pods -n chatapp

# Check services
kubectl get services -n chatapp

# View logs
kubectl logs -f deployment/backend-deployment -n chatapp
kubectl logs -f deployment/frontend-deployment -n chatapp
```

### Common Issues

#### Build Failures
- Check Docker daemon availability
- Verify registry credentials
- Review Dockerfile syntax

#### Deployment Failures
- Verify Kubernetes credentials
- Check namespace permissions
- Review resource limits

#### Health Check Failures
- Verify application startup time
- Check service endpoints
- Review network policies

## Best Practices

### Security
- Never commit secrets to code
- Use masked variables for sensitive data
- Regularly rotate credentials
- Enable branch protection

### Performance
- Use Docker layer caching
- Optimize image sizes
- Set appropriate resource limits
- Monitor application metrics

### Reliability
- Implement proper health checks
- Use rolling updates
- Set up monitoring and alerting
- Test rollback procedures

## Advanced Features

### Blue-Green Deployments
Modify the pipeline to support blue-green deployments:
```yaml
deploy_blue_green:
  script:
    - kubectl apply -f k8s/blue/
    - # Switch traffic after validation
```

### Canary Deployments
Implement gradual rollouts:
```yaml
deploy_canary:
  script:
    - kubectl apply -f k8s/canary/
    - # Monitor metrics before full rollout
```

### Multi-Environment Support
Add more environments:
- Development
- QA/Testing
- Staging
- Production

## Maintenance

### Regular Tasks
- Update base images monthly
- Review and update dependencies
- Monitor pipeline performance
- Update Kubernetes cluster

### Backup Strategy
- Database backups
- Configuration backups
- Registry image retention
- Disaster recovery planning

## Support

For issues or questions:
1. Check GitLab CI/CD logs
2. Review Kubernetes events
3. Consult documentation
4. Contact DevOps team
