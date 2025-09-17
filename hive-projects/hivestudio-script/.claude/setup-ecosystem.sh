#!/bin/bash
# Claude Code Ecosystem Main Setup Orchestrator
# Configures the complete Claude Code development environment

set -euo pipefail

# Colors and logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[ECOSYSTEM]${NC} $1"; }
log_success() { echo -e "${GREEN}[ECOSYSTEM]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[ECOSYSTEM]${NC} $1"; }
log_error() { echo -e "${RED}[ECOSYSTEM]${NC} $1"; }
log_step() { echo -e "${PURPLE}[STEP]${NC} $1"; }

# Configuration
SETUP_DIR="$HOME/.claude"
CONFIG_FILE="$SETUP_DIR/ecosystem-config.json"
LOG_FILE="$SETUP_DIR/ecosystem-setup.log"

# Create setup directory
mkdir -p "$SETUP_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

log_info "Starting Claude Code Ecosystem setup orchestration..."

# Step 1: Environment Detection
log_step "1/8 Detecting environment..."
ENVIRONMENT="local"
if [ "${CODESPACES:-}" = "true" ]; then
    ENVIRONMENT="codespace"
elif [ "${GITPOD_WORKSPACE_ID:-}" != "" ]; then
    ENVIRONMENT="gitpod"
fi
log_info "Environment detected: $ENVIRONMENT"

# Step 2: Claude CLI Configuration
log_step "2/8 Configuring Claude CLI..."
if command -v claude &> /dev/null; then
    # Check if Claude is already configured
    if ! claude auth status &> /dev/null; then
        log_warning "Claude CLI needs authentication"
        log_info "Please run 'claude auth login' to authenticate"
    else
        log_success "Claude CLI authenticated"
    fi
else
    log_error "Claude CLI not found. Please install it first."
    exit 1
fi

# Step 3: MCP Server Setup
log_step "3/8 Setting up MCP servers..."

setup_mcp_server() {
    local name="$1"
    local command="$2"

    log_info "Setting up MCP server: $name"

    # Check if server is already configured
    if claude mcp list | grep -q "$name"; then
        log_warning "MCP server '$name' already configured"
        return 0
    fi

    # Add the server
    if claude mcp add "$name" $command; then
        log_success "MCP server '$name' configured"
    else
        log_warning "Failed to configure MCP server '$name'"
        return 1
    fi
}

# Core MCP servers
setup_mcp_server "claude-flow" "npx claude-flow@alpha mcp start"

# Optional advanced servers (install if available)
if npm list -g ruv-swarm &> /dev/null || npm install -g ruv-swarm &> /dev/null; then
    setup_mcp_server "ruv-swarm" "npx ruv-swarm mcp start"
fi

if npm list -g flow-nexus &> /dev/null || npm install -g flow-nexus@latest &> /dev/null; then
    setup_mcp_server "flow-nexus" "npx flow-nexus@latest mcp start"
fi

# Step 4: Project Configuration
log_step "4/8 Setting up project configuration..."

# Create package.json if it doesn't exist
if [ ! -f "package.json" ]; then
    log_info "Creating package.json..."
    cat > package.json << EOF
{
  "name": "claude-code-project",
  "version": "1.0.0",
  "description": "Claude Code development project",
  "main": "index.js",
  "scripts": {
    "build": "tsc",
    "test": "jest",
    "lint": "eslint . --ext .ts,.js",
    "typecheck": "tsc --noEmit",
    "dev": "nodemon src/index.ts",
    "start": "node dist/index.js",
    "claude:sparc": "npx claude-flow sparc modes",
    "claude:validate": "bash .claude/validate.sh",
    "claude:update": "bash .claude/update.sh"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0",
    "ts-node": "^10.9.0",
    "nodemon": "^3.0.0",
    "jest": "^29.0.0",
    "@types/jest": "^29.0.0",
    "eslint": "^8.0.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0"
  }
}
EOF
    log_success "package.json created"
fi

# Create tsconfig.json if it doesn't exist
if [ ! -f "tsconfig.json" ]; then
    log_info "Creating tsconfig.json..."
    cat > tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "types": ["node", "jest"]
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
EOF
    log_success "tsconfig.json created"
fi

# Step 5: Directory Structure
log_step "5/8 Creating directory structure..."
mkdir -p src tests docs config scripts examples
log_success "Directory structure created"

# Step 6: Git Configuration
log_step "6/8 Configuring Git hooks..."
if [ -d ".git" ]; then
    mkdir -p .git/hooks

    # Pre-commit hook for Claude Flow
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Claude Flow pre-commit hook
if command -v npx &> /dev/null && npx claude-flow --version &> /dev/null; then
    npx claude-flow hooks pre-commit
fi
EOF
    chmod +x .git/hooks/pre-commit
    log_success "Git hooks configured"
else
    log_warning "Not a Git repository, skipping Git hooks"
fi

# Step 7: Environment Variables
log_step "7/8 Setting up environment configuration..."
if [ ! -f ".env.example" ]; then
    cat > .env.example << EOF
# Claude Code Environment Configuration
NODE_ENV=development
LOG_LEVEL=info

# Claude Configuration
CLAUDE_API_KEY=your_api_key_here
CLAUDE_MODEL=claude-3-sonnet-20240229

# Claude Flow Configuration
CLAUDE_FLOW_MODE=development
CLAUDE_FLOW_LOG_LEVEL=info

# Optional: GitHub Integration
GITHUB_TOKEN=your_github_token_here

# Optional: Custom MCP Servers
MCP_CLAUDE_FLOW_PORT=3001
MCP_RUV_SWARM_PORT=3002
MCP_FLOW_NEXUS_PORT=3003
EOF
    log_success "Environment configuration template created"
fi

# Step 8: Validation and Completion
log_step "8/8 Finalizing setup..."

# Create ecosystem configuration
cat > "$CONFIG_FILE" << EOF
{
  "version": "1.0.0",
  "environment": "$ENVIRONMENT",
  "setupDate": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "features": {
    "claudeCLI": true,
    "claudeFlow": true,
    "mcpServers": true,
    "sparc": true,
    "gitHooks": $([ -d ".git" ] && echo "true" || echo "false")
  },
  "mcpServers": [
    "claude-flow"
  ],
  "directories": [
    "src",
    "tests",
    "docs",
    "config",
    "scripts",
    "examples"
  ]
}
EOF

# Create completion marker
echo "$(date): Ecosystem setup completed successfully" > "$SETUP_DIR/setup-complete"

log_success "Claude Code Ecosystem setup completed!"
log_info "Configuration saved to: $CONFIG_FILE"
log_info "Setup log saved to: $LOG_FILE"

# Show next steps
echo
echo -e "${CYAN}🚀 Next Steps:${NC}"
echo "1. Run 'claude auth login' if not already authenticated"
echo "2. Install dependencies: npm install"
echo "3. Validate setup: .claude/validate.sh"
echo "4. Start developing with: npx claude-flow sparc modes"
echo "5. Check README-ECOSYSTEM.md for detailed usage"
echo

# Run validation
if [ -f ".claude/validate.sh" ]; then
    log_info "Running initial validation..."
    bash .claude/validate.sh
fi