#!/bin/bash

# Environment Setup Utility
# Sets up development environment variables and configurations

echo "🔧 Setting up development environment..."

# Create .env template if it doesn't exist
if [ ! -f ".env" ]; then
    cat > .env << 'ENVEOF'
# Development Environment Configuration
NODE_ENV=development
PORT=3000

# Claude Configuration
CLAUDE_API_KEY=your_claude_api_key_here

# Database Configuration
DATABASE_URL=your_database_url_here

# External APIs
API_BASE_URL=https://api.example.com

# Debug Settings
DEBUG=true
LOG_LEVEL=info
ENVEOF
    echo "📝 Created .env template - please fill in your values"
fi

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    cat > .gitignore << 'GITEOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
logs
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Build outputs
dist/
build/
*.tgz

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Claude Flow
.claude-flow/
.claude/memory/
GITEOF
    echo "📝 Created .gitignore"
fi

echo "✅ Environment setup completed"
