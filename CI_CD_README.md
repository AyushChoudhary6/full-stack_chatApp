# CI/CD Pipeline Documentation

This document describes the CI/CD pipeline setup for the Full-Stack Chat Application.

## Overview

The CI/CD pipeline is built using GitLab CI/CD and includes the following stages:

1. **Validate** - Code linting and formatting checks
2. **Test** - Unit and integration testing
3. **Security** - Dependency and container security scanning
4. **Build** - Docker image building
5. **Push** - Pushing images to container registry
6. **Deploy** - Deployment to Kubernetes clusters

## Pipeline Stages

### 1. Validate Stage

#### Backend Linting
- Uses ESLint to check code quality
- Enforces consistent coding standards
- Runs on all branches and merge requests

#### Frontend Linting
- Uses ESLint with React-specific rules
- Checks for common React patterns and best practices
- Runs on all branches and merge requests

### 2. Test Stage

#### Backend Testing
- Uses Jest as the testing framework
- Includes MongoDB service for integration tests
- Runs unit tests and API endpoint tests
- Generates coverage reports

#### Frontend Testing
- Currently placeholder for test framework setup
- Can be configured with Vitest or Jest
- Runs component and utility function tests

### 3. Security Stage

#### Dependency Security
- Runs `npm audit` on both backend and frontend
- Checks for known vulnerabilities
- Fails pipeline on high-severity issues

#### Container Security
- Placeholder for container scanning tools
- Can integrate with Trivy, Snyk, or similar tools
- Scans Docker images for vulnerabilities

### 4. Build Stage

#### Backend Image
- Builds Node.js application container
- Uses multi-stage build for optimization
- Tags with commit SHA and latest

#### Frontend Image
- Builds React application with Nginx
- Optimized production build
- Tags with commit SHA and latest

### 5. Push Stage

#### Container Registry
- Pushes images to GitLab Container Registry
- Uses built-in authentication
- Maintains both versioned and latest tags

### 6. Deploy Stage

#### Development Environment
- Automatic deployment on `develop` branch
- Uses `chat-app-dev` namespace
- Includes health checks and rollback

#### Production Environment
- Manual deployment trigger on `main` branch
- Uses `chat-app` namespace
- Includes comprehensive health monitoring

## Configuration

### Environment Variables

The following environment variables need to be configured in GitLab:

```bash
# GitLab Container Registry (automatically provided)
CI_REGISTRY
CI_REGISTRY_USER
CI_REGISTRY_PASSWORD

# Kubernetes Configuration
KUBE_CONFIG (base64 encoded kubeconfig)

# Optional: Notification Webhooks
SLACK_WEBHOOK_URL
TEAMS_WEBHOOK_URL
```

### Kubernetes Setup

1. **Install GitLab Agent** in your Kubernetes cluster
2. **Configure RBAC** for the deployment namespace
3. **Set up ingress** for external access
4. **Configure secrets** for environment variables

## Usage

### Automatic Pipeline

The pipeline runs automatically on:
- Push to `main` branch (production deployment)
- Push to `develop` branch (development deployment)
- Merge requests (validation and testing)

### Manual Deployment

Production deployments require manual approval:
1. Push to `main` branch
2. Pipeline runs through validation, testing, and building
3. Manual approval required for production deployment
4. Click "Play" button on `deploy_production` job

### Branch Strategy

- **`main`** - Production code, manual deployment
- **`develop`** - Development code, automatic deployment
- **Feature branches** - Validation and testing only

## Monitoring and Debugging

### Pipeline Artifacts

- **Test Reports**: JUnit XML format for test results
- **Coverage Reports**: HTML coverage reports
- **Security Reports**: SAST and container scanning results
- **Build Artifacts**: Docker images and build logs

### Health Checks

The pipeline includes health checks:
- Pod status verification
- Service availability
- Rollout status monitoring
- Post-deployment validation

### Troubleshooting

Common issues and solutions:

1. **Build Failures**
   - Check Docker build logs
   - Verify Dockerfile syntax
   - Check for missing dependencies

2. **Test Failures**
   - Review test output and coverage
   - Check for environment-specific issues
   - Verify test data and mocks

3. **Deployment Issues**
   - Check Kubernetes cluster connectivity
   - Verify namespace and RBAC permissions
   - Review deployment manifests

## Security Considerations

### Container Security
- Base images from official sources
- Regular security updates
- Vulnerability scanning integration
- Minimal attack surface

### Access Control
- GitLab RBAC for pipeline access
- Kubernetes RBAC for deployments
- Secret management for sensitive data
- Audit logging for all operations

### Network Security
- Internal service communication
- Ingress/egress policies
- TLS termination at load balancer
- Network policy enforcement

## Future Enhancements

### Planned Features
- [ ] Automated rollback on deployment failure
- [ ] Blue-green deployment strategy
- [ ] Canary deployment support
- [ ] Performance testing integration
- [ ] Chaos engineering tests

### Integration Opportunities
- [ ] Slack/Teams notifications
- [ ] Jira issue tracking
- [ ] Grafana metrics dashboard
- [ ] Prometheus monitoring
- [ ] ELK stack logging

## Support

For pipeline issues or questions:
1. Check pipeline logs and artifacts
2. Review this documentation
3. Consult GitLab CI/CD documentation
4. Contact the DevOps team

## Contributing

To improve the CI/CD pipeline:
1. Create a feature branch
2. Make changes and test locally
3. Submit a merge request
4. Include documentation updates
5. Request review from DevOps team
