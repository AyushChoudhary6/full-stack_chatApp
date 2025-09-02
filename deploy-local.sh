#!/bin/bash

echo "🚀 LOCAL DEPLOYMENT FROM GITLAB REGISTRY"
echo "========================================"

# Get the latest commit SHA from GitLab
echo "📡 Fetching latest commit info..."
LATEST_COMMIT=$(git rev-parse --short HEAD)
echo "Latest commit: $LATEST_COMMIT"

# GitLab registry URLs
REGISTRY_BASE="registry.gitlab.com/ayushrjchoudhary2005/full-stack_chatapp"
BACKEND_IMAGE="$REGISTRY_BASE/backend:$LATEST_COMMIT"
FRONTEND_IMAGE="$REGISTRY_BASE/frontend:$LATEST_COMMIT"

echo ""
echo "🐳 DOCKER IMAGES TO PULL:"
echo "Backend:  $BACKEND_IMAGE"
echo "Frontend: $FRONTEND_IMAGE"
echo ""

# Check if user is logged in to GitLab registry
echo "🔐 Checking GitLab registry login..."
if ! docker info | grep -q "registry.gitlab.com"; then
    echo "⚠️  Please login to GitLab registry first:"
    echo "   docker login registry.gitlab.com"
    echo "   Username: your-gitlab-username"
    echo "   Password: your-gitlab-access-token"
    echo ""
    read -p "🔑 Login now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker login registry.gitlab.com
    else
        echo "❌ Cannot proceed without registry login"
        exit 1
    fi
fi

# Pull the latest images
echo "📥 Pulling images from GitLab registry..."
docker pull $BACKEND_IMAGE || {
    echo "❌ Failed to pull backend image. Check if the image exists in registry."
    echo "💡 You may need to run the GitLab pipeline first to build and push images."
    exit 1
}

docker pull $FRONTEND_IMAGE || {
    echo "❌ Failed to pull frontend image. Check if the image exists in registry."
    echo "💡 You may need to run the GitLab pipeline first to build and push images."
    exit 1
}

# Create docker-compose file for local deployment
echo "📝 Creating local docker-compose file..."
cat > docker-compose.local.yml << EOF
version: '3.8'

services:
  postgres:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: chatapp
      POSTGRES_USER: chatapp_user
      POSTGRES_PASSWORD: 8gaq834qizIYaG3c
    volumes:
      - postgres_data_local:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U chatapp_user -d chatapp"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    image: $BACKEND_IMAGE
    environment:
      DATABASE_URL: postgresql://chatapp_user:8gaq834qizIYaG3c@postgres:5432/chatapp
      JWT_SECRET: b7f3795f5cd50589b62ab5794272a413
      PORT: 5000
      NODE_ENV: production
    ports:
      - "5000:5000"
    depends_on:
      postgres:
        condition: service_healthy
    restart: unless-stopped

  frontend:
    image: $FRONTEND_IMAGE
    ports:
      - "3000:80"
    depends_on:
      - backend
    restart: unless-stopped

volumes:
  postgres_data_local:
EOF

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose -f docker-compose.local.yml down || true

# Start the services
echo "🚀 Starting services locally..."
docker-compose -f docker-compose.local.yml up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 15

# Check service status
echo ""
echo "📊 SERVICE STATUS:"
docker-compose -f docker-compose.local.yml ps

# Display access URLs
echo ""
echo "🎉 DEPLOYMENT COMPLETE!"
echo "======================="
echo "🌐 Frontend:    http://localhost:3000"
echo "🔗 Backend API: http://localhost:5000"
echo "🗄️ Database:   localhost:5432"
echo "📊 Health:     http://localhost:5000/health"
echo ""
echo "💡 To stop services: docker-compose -f docker-compose.local.yml down"
echo "📝 To view logs: docker-compose -f docker-compose.local.yml logs -f"
