#!/bin/bash
# Claude Code Ecosystem Validation Script
# Validates the complete ecosystem setup and health

set -euo pipefail

# Colors and logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

QUIET_MODE=false
VERBOSE_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --quiet|-q)
            QUIET_MODE=true
            shift
            ;;
        --verbose|-v)
            VERBOSE_MODE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--quiet|-q] [--verbose|-v] [--help|-h]"
            echo "Validates Claude Code Ecosystem setup"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

log_info() {
    if [ "$QUIET_MODE" = false ]; then
        echo -e "${BLUE}[VALIDATE]${NC} $1"
    fi
}

log_success() {
    if [ "$QUIET_MODE" = false ]; then
        echo -e "${GREEN}[✓]${NC} $1"
    fi
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_verbose() {
    if [ "$VERBOSE_MODE" = true ]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

# Validation results
VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0
VALIDATION_PASSED=0

validate_item() {
    local name="$1"
    local test_command="$2"
    local required="${3:-true}"

    log_verbose "Validating: $name"

    if eval "$test_command" &> /dev/null; then
        log_success "$name"
        ((VALIDATION_PASSED++))
        return 0
    else
        if [ "$required" = "true" ]; then
            log_error "$name"
            ((VALIDATION_ERRORS++))
            return 1
        else
            log_warning "$name (optional)"
            ((VALIDATION_WARNINGS++))
            return 0
        fi
    fi
}

log_info "Starting Claude Code Ecosystem validation..."

# Core System Validation
log_info "Validating core system..."
validate_item "Node.js installed" "command -v node"
validate_item "npm installed" "command -v npm"
validate_item "Git installed" "command -v git"
validate_item "Python3 available" "command -v python3" false

# Claude CLI Validation
log_info "Validating Claude CLI..."
validate_item "Claude CLI installed" "command -v claude"

if command -v claude &> /dev/null; then
    validate_item "Claude CLI authenticated" "claude auth status" false

    if claude auth status &> /dev/null; then
        log_verbose "Claude CLI version: $(claude --version 2>/dev/null || echo 'Unknown')"
    fi
fi

# Claude Flow Validation
log_info "Validating Claude Flow..."
validate_item "Claude Flow installed" "npx claude-flow --version"

if npx claude-flow --version &> /dev/null; then
    validate_item "Claude Flow SPARC modes available" "npx claude-flow sparc modes" false
fi

# MCP Servers Validation
log_info "Validating MCP servers..."
if command -v claude &> /dev/null; then
    validate_item "MCP servers configured" "claude mcp list | grep -q claude-flow"

    # Check each configured server
    if claude mcp list &> /dev/null; then
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*([^[:space:]]+) ]]; then
                server_name="${BASH_REMATCH[1]}"
                validate_item "MCP server '$server_name' responsive" "claude mcp test $server_name" false
                log_verbose "MCP server: $server_name"
            fi
        done < <(claude mcp list 2>/dev/null || echo "")
    fi
fi

# Project Structure Validation
log_info "Validating project structure..."
validate_item "package.json exists" "[ -f package.json ]"
validate_item "tsconfig.json exists" "[ -f tsconfig.json ]" false
validate_item "src/ directory exists" "[ -d src ]"
validate_item "tests/ directory exists" "[ -d tests ]" false
validate_item "docs/ directory exists" "[ -d docs ]" false

# Dependencies Validation
if [ -f "package.json" ]; then
    log_info "Validating dependencies..."
    validate_item "node_modules exists" "[ -d node_modules ]" false

    if [ -d "node_modules" ]; then
        validate_item "TypeScript available" "npx tsc --version" false
        validate_item "Jest available" "npx jest --version" false
    fi
fi

# Environment Configuration
log_info "Validating environment configuration..."
validate_item ".env.example exists" "[ -f .env.example ]" false
validate_item "Claude config directory" "[ -d $HOME/.claude ]"

# Git Configuration
if [ -d ".git" ]; then
    log_info "Validating Git configuration..."
    validate_item "Git repository initialized" "[ -d .git ]"
    validate_item "Git hooks directory" "[ -d .git/hooks ]" false
    validate_item "Pre-commit hook" "[ -f .git/hooks/pre-commit ]" false
fi

# DevContainer Configuration
log_info "Validating DevContainer setup..."
validate_item "DevContainer configuration" "[ -f .devcontainer/devcontainer.json ]" false
validate_item "DevContainer setup script" "[ -f .devcontainer/setup.sh ]" false
validate_item "DevContainer startup script" "[ -f .devcontainer/startup.sh ]" false

# Ecosystem Scripts
log_info "Validating ecosystem scripts..."
validate_item "Ecosystem setup script" "[ -f .claude/setup-ecosystem.sh ]"
validate_item "Ecosystem validate script" "[ -f .claude/validate.sh ]"
validate_item "Ecosystem update script" "[ -f .claude/update.sh ]" false

# Script Permissions
log_info "Validating script permissions..."
for script in ".devcontainer/setup.sh" ".devcontainer/startup.sh" ".claude/setup-ecosystem.sh" ".claude/validate.sh" ".claude/update.sh"; do
    if [ -f "$script" ]; then
        validate_item "$script executable" "[ -x $script ]"
    fi
done

# Documentation
log_info "Validating documentation..."
validate_item "SETUP.md documentation" "[ -f SETUP.md ]" false
validate_item "README-ECOSYSTEM.md" "[ -f README-ECOSYSTEM.md ]" false
validate_item "CLAUDE.md configuration" "[ -f CLAUDE.md ]" false

# Performance Tests
log_info "Running performance checks..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | cut -d'v' -f2)
    REQUIRED_VERSION="18.0.0"

    if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1)" = "$REQUIRED_VERSION" ]; then
        log_success "Node.js version ($NODE_VERSION) meets requirements"
        ((VALIDATION_PASSED++))
    else
        log_warning "Node.js version ($NODE_VERSION) may be outdated (recommended: ≥$REQUIRED_VERSION)"
        ((VALIDATION_WARNINGS++))
    fi
fi

# Connectivity Tests
log_info "Testing connectivity..."
validate_item "Internet connectivity" "ping -c 1 claude.ai" false
validate_item "npm registry accessible" "npm ping" false

# Summary
echo
echo -e "${CYAN}━━━ Validation Summary ━━━${NC}"
echo -e "✓ Passed: ${GREEN}$VALIDATION_PASSED${NC}"
echo -e "⚠ Warnings: ${YELLOW}$VALIDATION_WARNINGS${NC}"
echo -e "✗ Errors: ${RED}$VALIDATION_ERRORS${NC}"

if [ $VALIDATION_ERRORS -eq 0 ]; then
    echo
    log_success "Claude Code Ecosystem validation completed successfully!"

    if [ $VALIDATION_WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}Note: Some optional features showed warnings but the ecosystem is functional.${NC}"
    fi

    # Save validation results
    if [ -d "$HOME/.claude" ]; then
        cat > "$HOME/.claude/last-validation.json" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "passed": $VALIDATION_PASSED,
  "warnings": $VALIDATION_WARNINGS,
  "errors": $VALIDATION_ERRORS,
  "status": "success"
}
EOF
    fi

    exit 0
else
    echo
    log_error "Validation failed with $VALIDATION_ERRORS error(s)!"
    echo -e "${RED}Please review the errors above and run the setup again.${NC}"

    # Save validation results
    if [ -d "$HOME/.claude" ]; then
        cat > "$HOME/.claude/last-validation.json" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "passed": $VALIDATION_PASSED,
  "warnings": $VALIDATION_WARNINGS,
  "errors": $VALIDATION_ERRORS,
  "status": "failed"
}
EOF
    fi

    exit 1
fi