#!/bin/bash
# Claude Code Ecosystem Startup Script
# Runs every time the container starts

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[STARTUP]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[STARTUP]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[STARTUP]${NC} $1"
}

log_info "Starting Claude Code Ecosystem..."

# Ensure PATH includes Claude and Bun
export PATH="$HOME/.claude/bin:$HOME/.bun/bin:$PATH"

# Start background services if needed
if command -v claude-flow &> /dev/null; then
    # Check if Claude Flow daemon should be running
    if ! pgrep -f "claude-flow" > /dev/null; then
        log_info "Starting Claude Flow background services..."
        # Only start if explicitly configured
        if [ -f ".claude-flow-config.json" ]; then
            npx claude-flow daemon start --silent || log_warning "Claude Flow daemon not started"
        fi
    fi
fi

# Validate ecosystem
if [ -f ".claude/validate.sh" ]; then
    log_info "Running ecosystem validation..."
    bash .claude/validate.sh --quiet || log_warning "Validation completed with warnings"
fi

# Show welcome message
if [ -f "README-ECOSYSTEM.md" ]; then
    log_success "Claude Code Ecosystem ready!"
    echo
    echo "📚 Quick Start:"
    echo "  • Run 'claude --help' to see available commands"
    echo "  • Run 'npx claude-flow sparc modes' to see SPARC modes"
    echo "  • Check README-ECOSYSTEM.md for detailed instructions"
    echo "  • Use '.claude/validate.sh' to check ecosystem health"
    echo
else
    log_success "Claude Code Ecosystem started"
fi

# Update last startup time
echo "$(date): Container started" >> ~/.claude/startup.log

log_success "Startup complete!"