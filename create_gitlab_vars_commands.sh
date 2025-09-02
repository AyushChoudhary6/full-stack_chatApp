#!/bin/bash

# GitLab Project ID (you need to set this)
PROJECT_ID="your_gitlab_project_id"
GITLAB_TOKEN="your_gitlab_token"

echo "# Commands to set GitLab CI/CD Variables"
echo "# Replace PROJECT_ID and GITLAB_TOKEN with your actual values"
echo "# Get Project ID from: GitLab Project > Settings > General"
echo "# Get Token from: GitLab Profile > Access Tokens"
echo ""

# Array of variables with their security settings
declare -A vars=(
    ["CI_DOCKER_USER"]="false,false"
    ["CI_DOCKER_PASSWORD"]="true,false"  # masked
    ["KUBE_SERVER"]="false,false"
    ["KUBE_NAMESPACE"]="false,false"
    ["KUBE_CA_PEM"]="false,true"  # protected
    ["KUBE_TOKEN"]="true,true"    # masked + protected
    ["MONGODB_URI"]="true,false"  # masked
    ["JWT_SECRET"]="true,false"   # masked
    ["CLOUDINARY_CLOUD_NAME"]="false,false"
    ["CLOUDINARY_API_KEY"]="false,false"
    ["CLOUDINARY_API_SECRET"]="true,false"  # masked
    ["DOMAIN_NAME"]="false,false"
    ["BACKEND_REPLICAS"]="false,false"
    ["FRONTEND_REPLICAS"]="false,false"
)

for var in "${!vars[@]}"; do
    IFS=',' read -r masked protected <<< "${vars[$var]}"
    echo "# Add $var"
    echo "curl --request POST \\"
    echo "  --header \"PRIVATE-TOKEN: \$GITLAB_TOKEN\" \\"
    echo "  --header \"Content-Type: application/json\" \\"
    echo "  --data '{\"key\": \"$var\", \"value\": \"YOUR_VALUE_HERE\", \"masked\": $masked, \"protected\": $protected}' \\"
    echo "  \"https://gitlab.com/api/v4/projects/\$PROJECT_ID/variables\""
    echo ""
done

echo "# Alternative: Use GitLab UI"
echo "# Go to: Project Settings > CI/CD > Variables > Add Variable"
