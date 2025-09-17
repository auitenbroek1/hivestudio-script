#!/bin/bash
# Claude Code Ecosystem Setup Script
# Runs once during container creation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Error handler
handle_error() {
    log_error "Setup failed at line $1"
    exit 1
}

trap 'handle_error $LINENO' ERR

log_info "Starting Claude Code Ecosystem setup..."

# Create setup log
SETUP_LOG="/tmp/claude-ecosystem-setup.log"
exec > >(tee -a "$SETUP_LOG") 2>&1

# Update system packages
log_info "Updating system packages..."
sudo apt-get update -qq
sudo apt-get install -y curl wget git build-essential python3-pip jq unzip

# Install Node.js tools
log_info "Installing Node.js global packages..."
npm install -g npm@latest
npm install -g typescript ts-node nodemon
npm install -g @types/node

# Install Claude CLI
log_info "Installing Claude CLI..."
if ! command -v claude &> /dev/null; then
    curl -fsSL https://claude.ai/install.sh | bash
    export PATH="$HOME/.claude/bin:$PATH"
    echo 'export PATH="$HOME/.claude/bin:$PATH"' >> ~/.bashrc
    log_success "Claude CLI installed"
else
    log_warning "Claude CLI already installed"
fi

# Install Claude Flow
log_info "Installing Claude Flow..."
npm install -g claude-flow@alpha

# Install Bun (optional fast runtime)
log_info "Installing Bun runtime..."
if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
    echo 'export PATH="$HOME/.bun/bin:$PATH"' >> ~/.bashrc
    log_success "Bun installed"
else
    log_warning "Bun already installed"
fi

# Setup workspace permissions
log_info "Setting up workspace permissions..."
sudo chown -R vscode:vscode /workspaces
sudo chmod -R 755 /workspaces

# Create Claude configuration directory
log_info "Setting up Claude configuration..."
mkdir -p ~/.claude
mkdir -p ~/.cache/claude

# Install project dependencies if package.json exists
if [ -f "package.json" ]; then
    log_info "Installing project dependencies..."
    npm install
    log_success "Project dependencies installed"
fi

# Run the main ecosystem setup
log_info "Running main ecosystem setup..."
if [ -f ".claude/setup-ecosystem.sh" ]; then
    bash .claude/setup-ecosystem.sh
else
    log_warning "Main ecosystem setup script not found, skipping..."
fi

# Set executable permissions on scripts
log_info "Setting executable permissions..."
find .devcontainer -name "*.sh" -exec chmod +x {} \;
find .claude -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

# Create completion marker
echo "$(date): Claude Code Ecosystem setup completed" > ~/.claude/setup-complete

log_success "Claude Code Ecosystem setup completed successfully!"
log_info "Setup log saved to: $SETUP_LOG"
log_info "You can now use 'claude' and 'npx claude-flow' commands"

# Show installed versions
log_info "Installed versions:"
echo "  Node.js: $(node --version)"
echo "  npm: $(npm --version)"
echo "  Claude CLI: $(claude --version 2>/dev/null || echo 'Not configured')"
echo "  Claude Flow: $(npx claude-flow --version 2>/dev/null || echo 'Installed')"
echo "  Bun: $(bun --version 2>/dev/null || echo 'Not available')"