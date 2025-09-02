# GitLab CI/CD Variables Setup Guide

## 🔐 Required Variables

Your pipeline needs exactly **3 variables** to work. I've generated secure values for you:

### Step 1: Go to GitLab Variables Page
1. Open your project: https://gitlab.com/AyushChoudhary6/full-stack_chatApp
2. Go to **Settings** → **CI/CD** → **Variables**
3. Click **"Add Variable"** for each of the following:

### Step 2: Add These 3 Variables

#### Variable 1: JWT_SECRET
```
Key: JWT_SECRET
Value: b7f3795f5cd50589b62ab5794272a413
Type: Variable
Protected: ✅ (checked)
Masked: ✅ (checked)
```

#### Variable 2: POSTGRES_PASSWORD
```
Key: POSTGRES_PASSWORD
Value: 8gaq834qizIYaG3c
Type: Variable
Protected: ✅ (checked)
Masked: ✅ (checked)
```

#### Variable 3: DATABASE_URL
```
Key: DATABASE_URL
Value: postgresql://chatapp_user:8gaq834qizIYaG3c@postgres:5432/chatapp
Type: Variable
Protected: ✅ (checked)
Masked: ✅ (checked)
```

## 🚀 After Setting Variables

1. **Test the pipeline**: Make any small change and push to trigger the pipeline
2. **Monitor progress**: Check https://gitlab.com/AyushChoudhary6/full-stack_chatApp/-/pipelines
3. **Access your app**: After successful deployment:
   - Frontend: http://localhost:3000
   - Backend: http://localhost:5000
   - Database: localhost:5432

## 🔧 Pipeline Overview

- **Test Stage**: Runs backend tests with PostgreSQL, builds frontend
- **Build Stage**: Creates Docker images locally
- **Deploy Stage**: Deploys using Docker Compose on your local machine

## ⚠️ Important Notes

- All variables are **masked** for security
- Pipeline runs on your **local GitLab Runner**
- No cloud deployment - everything runs on your PC
- PostgreSQL replaces MongoDB
- Cloudinary has been completely removed
