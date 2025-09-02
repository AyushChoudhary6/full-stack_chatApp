#!/bin/bash

echo "🔐 GENERATING GITLAB CI/CD VARIABLES"
echo "====================================="

# Generate JWT Secret (32 characters)
JWT_SECRET=$(openssl rand -hex 16)
echo ""
echo "1. JWT_SECRET (generated):"
echo "   Value: $JWT_SECRET"

# Generate PostgreSQL password
POSTGRES_PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-16)
echo ""
echo "2. POSTGRES_PASSWORD (generated):"
echo "   Value: $POSTGRES_PASSWORD"

# Create DATABASE_URL
DATABASE_URL="postgresql://chatapp_user:$POSTGRES_PASSWORD@postgres:5432/chatapp"
echo ""
echo "3. DATABASE_URL (constructed):"
echo "   Value: $DATABASE_URL"

echo ""
echo "🚀 HOW TO SET THESE IN GITLAB:"
echo "1. Go to your GitLab project: https://gitlab.com/AyushChoudhary6/full-stack_chatApp"
echo "2. Navigate to: Settings → CI/CD → Variables"
echo "3. Click 'Add Variable' for each:"
echo ""
echo "   Variable 1:"
echo "   - Key: JWT_SECRET"
echo "   - Value: $JWT_SECRET"
echo "   - Type: Variable"
echo "   - Protected: ✓ (checked)"
echo "   - Masked: ✓ (checked)"
echo ""
echo "   Variable 2:"
echo "   - Key: POSTGRES_PASSWORD"
echo "   - Value: $POSTGRES_PASSWORD"
echo "   - Type: Variable"
echo "   - Protected: ✓ (checked)"
echo "   - Masked: ✓ (checked)"
echo ""
echo "   Variable 3:"
echo "   - Key: DATABASE_URL"
echo "   - Value: $DATABASE_URL"
echo "   - Type: Variable"
echo "   - Protected: ✓ (checked)"
echo "   - Masked: ✓ (checked)"

# Save to .env file for reference
echo ""
echo "💾 SAVING TO .env.generated FOR YOUR REFERENCE..."
cat > .env.generated << ENVEOF
# Generated GitLab Variables - $(date)
# Copy these values to GitLab CI/CD Variables

JWT_SECRET=$JWT_SECRET
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
DATABASE_URL=$DATABASE_URL

# Additional local development variables
POSTGRES_DB=chatapp
POSTGRES_USER=chatapp_user
PORT=5000
NODE_ENV=production
ENVEOF

echo "✅ Variables saved to .env.generated"
echo ""
echo "🎯 NEXT STEPS:"
echo "1. Copy the above values to GitLab Variables"
echo "2. Test your pipeline by pushing a commit"
echo "3. Check the pipeline at: https://gitlab.com/AyushChoudhary6/full-stack_chatApp/-/pipelines"

