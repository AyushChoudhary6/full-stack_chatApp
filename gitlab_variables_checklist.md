# GitLab CI/CD Variables Setup Checklist

## Location
**GitLab Project → Settings → CI/CD → Variables → Add Variable**

## Variables to Add (14 total)

### 🐳 Docker Registry Configuration
| Variable | Value | Protect | Mask |
|----------|-------|---------|------|
| `CI_DOCKER_USER` | your_docker_hub_username | ❌ | ❌ |
| `CI_DOCKER_PASSWORD` | your_docker_hub_password | ❌ | ✅ |

### ☸️ Kubernetes Cluster Configuration  
| Variable | Value | Protect | Mask |
|----------|-------|---------|------|
| `KUBE_SERVER` | https://your-k8s-api:6443 | ❌ | ❌ |
| `KUBE_NAMESPACE` | chatapp | ❌ | ❌ |
| `KUBE_CA_PEM` | base64_ca_certificate | ✅ | ❌ |
| `KUBE_TOKEN` | service_account_token | ✅ | ✅ |

### 🗄️ Application Secrets
| Variable | Value | Protect | Mask |
|----------|-------|---------|------|
| `MONGODB_URI` | mongodb+srv://user:pass@host/db | ❌ | ✅ |
| `JWT_SECRET` | 32_char_secret_key | ❌ | ✅ |
| `CLOUDINARY_CLOUD_NAME` | your_cloud_name | ❌ | ❌ |
| `CLOUDINARY_API_KEY` | your_api_key | ❌ | ❌ |
| `CLOUDINARY_API_SECRET` | your_api_secret | ❌ | ✅ |

### 🌐 Deployment Configuration
| Variable | Value | Protect | Mask |
|----------|-------|---------|------|
| `DOMAIN_NAME` | yourdomain.com | ❌ | ❌ |
| `BACKEND_REPLICAS` | 3 | ❌ | ❌ |
| `FRONTEND_REPLICAS` | 3 | ❌ | ❌ |

## Security Flags Explanation
- **✅ Protect**: Variable only available on protected branches (main/master)
- **✅ Mask**: Variable value hidden in pipeline logs
- **❌**: Standard variable with no special protection

## Quick Setup Commands (Alternative)
```bash
# Set these environment variables first
export GITLAB_TOKEN="your_personal_access_token"
export PROJECT_ID="your_gitlab_project_id"

# Then run these curl commands (replace YOUR_VALUE_HERE with actual values)
# ... (API commands would be listed here)
```
