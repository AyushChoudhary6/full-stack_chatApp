#!/bin/bash

echo "🏠 LOCAL DEVELOPMENT DEPLOYMENT"
echo "================================"

# Check if .env.local exists, if not create it
if [ ! -f .env.local ]; then
    echo "📝 Creating .env.local file..."
    cat > .env.local << EOF
# Local Development Environment Variables
DATABASE_URL=postgresql://chatapp_user:chatapp_password@postgres:5432/chatapp
JWT_SECRET=b7f3795f5cd50589b62ab5794272a413
POSTGRES_DB=chatapp
POSTGRES_USER=chatapp_user
POSTGRES_PASSWORD=chatapp_password
NODE_ENV=development
PORT=5000
EOF
    echo "✅ Created .env.local"
fi

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose -f docker-compose.dev.yml down || true

# Start development services
echo "🚀 Starting development services..."
docker-compose -f docker-compose.dev.yml up -d --build

# Wait for services
echo "⏳ Waiting for services to start..."
sleep 20

# Check status
echo ""
echo "📊 SERVICE STATUS:"
docker-compose -f docker-compose.dev.yml ps

echo ""
echo "🎉 LOCAL DEVELOPMENT READY!"
echo "============================"
echo "🌐 Frontend:    http://localhost:3000"
echo "🔗 Backend API: http://localhost:5000"
echo "🗄️ Database:   localhost:5432"
echo ""
echo "💡 To stop: docker-compose -f docker-compose.dev.yml down"
echo "📝 To view logs: docker-compose -f docker-compose.dev.yml logs -f"
echo "🔄 To rebuild: docker-compose -f docker-compose.dev.yml up -d --build"
