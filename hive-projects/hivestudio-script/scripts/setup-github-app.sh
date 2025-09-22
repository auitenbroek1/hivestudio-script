#!/bin/bash

# GitHub App Integration Setup Script
# Based on successful implementation for auitenbroek1/hivestudio-script
# This script automates the proven steps that led to successful integration

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Helper functions
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

echo "🚀 GitHub App Integration Setup"
echo "================================="
echo ""

# Step 1: Check Prerequisites
log_info "Step 1: Checking prerequisites..."

# Check Node.js version
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        log_success "Node.js 18+ found"
    else
        log_error "Node.js 18+ required (found v$NODE_VERSION)"
        exit 1
    fi
else
    log_error "Node.js not found. Please install Node.js 18+"
    exit 1
fi

# Check npm
if command -v npm &> /dev/null; then
    log_success "npm found"
else
    log_error "npm not found"
    exit 1
fi

# Check git
if command -v git &> /dev/null; then
    log_success "Git found"
else
    log_error "Git not found"
    exit 1
fi

echo ""

# Step 2: Install Claude CLI (npm priority method)
log_info "Step 2: Installing Claude CLI..."

install_claude_cli() {
    # Method 1: npm (PRIMARY - proven to work)
    if command -v npm &> /dev/null; then
        log_info "Installing via npm (recommended method)..."
        if npm install -g @anthropic-ai/claude@latest; then
            log_success "Claude CLI installed via npm"
            return 0
        fi
    fi

    # Method 2: Homebrew (fallback)
    if command -v brew &> /dev/null; then
        log_info "Attempting Homebrew installation..."
        if brew install claude-ai/claude/claude; then
            log_success "Claude CLI installed via Homebrew"
            return 0
        fi
    fi

    # Method 3: curl (last resort)
    log_info "Attempting curl installation..."
    if curl -fsSL https://claude.ai/install.sh | sh; then
        log_success "Claude CLI installed via curl"
        return 0
    fi

    log_error "Failed to install Claude CLI"
    return 1
}

if command -v claude &> /dev/null; then
    log_success "Claude CLI already installed"
else
    install_claude_cli
fi

# Verify Claude CLI installation
if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
    log_success "Claude CLI ready (version: $CLAUDE_VERSION)"
else
    log_error "Claude CLI installation verification failed"
    exit 1
fi

echo ""

# Step 3: Create necessary directories
log_info "Step 3: Creating project structure..."

mkdir -p .github/workflows
mkdir -p docs
mkdir -p tests
mkdir -p config

log_success "Directory structure created"
echo ""

# Step 4: Check for existing workflow
log_info "Step 4: Checking for GitHub workflow..."

if [ -f ".github/workflows/claude.yml" ]; then
    log_success "GitHub workflow already exists"
else
    log_warning "GitHub workflow not found"
    echo "Please ensure .github/workflows/claude.yml exists with proper configuration"
fi

echo ""

# Step 5: Authentication setup guidance
log_info "Step 5: Authentication Setup"
echo ""
echo "Choose your authentication method:"
echo ""
echo "Option A: OAuth Token (Recommended)"
echo "  1. Run: claude setup-token"
echo "  2. Copy the token (starts with 'claude_oauth_')"
echo "  3. Add to GitHub Secrets as: CLAUDE_CODE_OAUTH_TOKEN"
echo ""
echo "Option B: API Key"
echo "  1. Visit: https://console.anthropic.com/"
echo "  2. Generate API key (starts with 'sk-ant-')"
echo "  3. Add to GitHub Secrets as: ANTHROPIC_API_KEY"
echo ""
echo "GitHub Secrets URL for this repo:"
echo "https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/settings/secrets/actions"
echo ""

# Step 6: Validation
log_info "Step 6: Running validation tests..."
echo ""

# Basic validation checks
VALIDATION_PASSED=true

# Check workflow file
if [ -f ".github/workflows/claude.yml" ]; then
    log_success "Workflow file exists"

    # Check for required permissions
    if grep -q "pull-requests: write" .github/workflows/claude.yml; then
        log_success "Pull request permissions configured"
    else
        log_warning "Missing pull-requests: write permission"
        VALIDATION_PASSED=false
    fi

    # Check for authentication
    if grep -q "ANTHROPIC_API_KEY\|CLAUDE_CODE_OAUTH_TOKEN" .github/workflows/claude.yml; then
        log_success "Authentication configuration found"
    else
        log_warning "Missing authentication configuration"
        VALIDATION_PASSED=false
    fi
else
    log_error "Workflow file missing"
    VALIDATION_PASSED=false
fi

# Check for test script
if [ -f "tests/claude-integration-test.sh" ]; then
    log_success "Integration test script exists"

    # Make it executable
    chmod +x tests/claude-integration-test.sh

    # Offer to run full tests
    echo ""
    read -p "Run full integration tests? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./tests/claude-integration-test.sh --quick
    fi
else
    log_warning "Integration test script not found"
fi

echo ""

# Step 7: Next steps
log_info "Next Steps to Complete Setup:"
echo ""
echo "1. Install Claude GitHub App:"
echo "   - Visit: https://github.com/apps/claude"
echo "   - Install for your account"
echo "   - Grant access to this repository"
echo ""
echo "2. Configure Authentication:"
echo "   - Generate OAuth token: claude setup-token"
echo "   - Add to repository secrets"
echo ""
echo "3. Test the Integration:"
echo "   - Create a test pull request"
echo "   - Verify Claude reviews it automatically"
echo ""
echo "4. Run Full Validation:"
echo "   ./tests/claude-integration-test.sh"
echo ""

# Final status
if [ "$VALIDATION_PASSED" = true ]; then
    log_success "Basic setup validation passed!"
    echo ""
    echo "🎉 Setup script completed successfully!"
    echo "Follow the 'Next Steps' above to finish the integration."
else
    log_warning "Some validation checks failed"
    echo ""
    echo "⚠️  Setup partially complete. Please address the warnings above."
fi

echo ""
echo "📚 Documentation: docs/GITHUB-APP-SUCCESS-PATH.md"
echo "🧪 Test Script: tests/claude-integration-test.sh"
echo "🔧 Support: Check docs/TESTING-GUIDE.md for troubleshooting"