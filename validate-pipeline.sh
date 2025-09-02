#!/bin/bash

# =============================================================================
# Pipeline Validation Script
# =============================================================================
# This script validates your CI/CD pipeline configuration

echo "============================================================================="
echo "CI/CD Pipeline Validation"
echo "============================================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# Function to print status
print_status() {
    local status=$1
    local message=$2
    
    case $status in
        "PASS")
            echo -e "${GREEN}✓ PASS${NC}: $message"
            ((CHECKS_PASSED++))
            ;;
        "FAIL")
            echo -e "${RED}✗ FAIL${NC}: $message"
            ((CHECKS_FAILED++))
            ;;
        "WARN")
            echo -e "${YELLOW}⚠ WARN${NC}: $message"
            ((CHECKS_WARNING++))
            ;;
    esac
}

echo "Validating pipeline configuration..."
echo ""

# Check if .gitlab-ci.yml exists and is valid
if [ -f ".gitlab-ci.yml" ]; then
    print_status "PASS" ".gitlab-ci.yml file exists"
    
    # Basic YAML syntax check (if yq is available)
    if command -v yq &> /dev/null; then
        if yq eval '.' .gitlab-ci.yml > /dev/null 2>&1; then
            print_status "PASS" ".gitlab-ci.yml has valid YAML syntax"
        else
            print_status "FAIL" ".gitlab-ci.yml has invalid YAML syntax"
        fi
    else
        print_status "WARN" "yq not available - cannot validate YAML syntax"
    fi
else
    print_status "FAIL" ".gitlab-ci.yml file is missing"
fi

# Check Kubernetes manifests
echo ""
echo "Checking Kubernetes manifests..."

k8s_files=("backend-deployment.yml" "frontend-deployment.yml" "backend-service.yml" "frontend-service.yml" "ingress.yml" "configmap.yml")

for file in "${k8s_files[@]}"; do
    if [ -f "k8s/$file" ]; then
        print_status "PASS" "k8s/$file exists"
        
        # Basic YAML syntax check
        if command -v yq &> /dev/null; then
            if yq eval '.' "k8s/$file" > /dev/null 2>&1; then
                print_status "PASS" "k8s/$file has valid YAML syntax"
            else
                print_status "FAIL" "k8s/$file has invalid YAML syntax"
            fi
        fi
    else
        print_status "FAIL" "k8s/$file is missing"
    fi
done

# Check Dockerfiles
echo ""
echo "Checking Dockerfiles..."

if [ -f "backend/Dockerfile" ]; then
    print_status "PASS" "Backend Dockerfile exists"
else
    print_status "FAIL" "Backend Dockerfile is missing"
fi

if [ -f "frontend/Dockerfile" ]; then
    print_status "PASS" "Frontend Dockerfile exists"
else
    print_status "FAIL" "Frontend Dockerfile is missing"
fi

# Check package.json files
echo ""
echo "Checking package.json files..."

if [ -f "backend/package.json" ]; then
    print_status "PASS" "Backend package.json exists"
    
    # Check for required scripts
    if grep -q '"test"' backend/package.json; then
        print_status "PASS" "Backend has test script"
    else
        print_status "WARN" "Backend missing test script"
    fi
    
    if grep -q '"lint"' backend/package.json; then
        print_status "PASS" "Backend has lint script"
    else
        print_status "WARN" "Backend missing lint script"
    fi
else
    print_status "FAIL" "Backend package.json is missing"
fi

if [ -f "frontend/package.json" ]; then
    print_status "PASS" "Frontend package.json exists"
    
    # Check for build script
    if grep -q '"build"' frontend/package.json; then
        print_status "PASS" "Frontend has build script"
    else
        print_status "FAIL" "Frontend missing build script"
    fi
else
    print_status "FAIL" "Frontend package.json is missing"
fi

# Check environment configuration
echo ""
echo "Checking environment configuration..."

if [ -f ".env.example" ]; then
    print_status "PASS" ".env.example file exists"
else
    print_status "WARN" ".env.example file is missing (recommended)"
fi

if [ -f "setup-gitlab-variables.sh" ]; then
    print_status "PASS" "GitLab variables setup script exists"
    
    if [ -x "setup-gitlab-variables.sh" ]; then
        print_status "PASS" "Setup script is executable"
    else
        print_status "WARN" "Setup script is not executable"
    fi
else
    print_status "FAIL" "GitLab variables setup script is missing"
fi

# Check documentation
echo ""
echo "Checking documentation..."

if [ -f "CI_CD_PIPELINE_DOCS.md" ]; then
    print_status "PASS" "CI/CD documentation exists"
else
    print_status "WARN" "CI/CD documentation is missing"
fi

if [ -f "README.md" ]; then
    print_status "PASS" "README.md exists"
else
    print_status "WARN" "README.md is missing"
fi

# Git configuration check
echo ""
echo "Checking Git configuration..."

if git rev-parse --git-dir > /dev/null 2>&1; then
    print_status "PASS" "Git repository initialized"
    
    # Check for GitLab remote
    if git remote -v | grep -q gitlab; then
        print_status "PASS" "GitLab remote configured"
    else
        print_status "WARN" "GitLab remote not found"
    fi
else
    print_status "FAIL" "Not a Git repository"
fi

# Summary
echo ""
echo "============================================================================="
echo "Validation Summary"
echo "============================================================================="
echo -e "${GREEN}Passed: $CHECKS_PASSED${NC}"
echo -e "${YELLOW}Warnings: $CHECKS_WARNING${NC}"
echo -e "${RED}Failed: $CHECKS_FAILED${NC}"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All critical checks passed! Your pipeline is ready.${NC}"
    exit 0
else
    echo -e "${RED}✗ Some critical checks failed. Please fix the issues above.${NC}"
    exit 1
fi
