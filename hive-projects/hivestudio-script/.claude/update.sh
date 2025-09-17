#!/bin/bash
# Claude Code Ecosystem Update Script
# Updates Claude CLI, Claude Flow, and MCP servers

set -euo pipefail

# Colors and logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

AUTO_MODE=false
CHECK_ONLY=false
FORCE_UPDATE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto|-a)
            AUTO_MODE=true
            shift
            ;;
        --check|-c)
            CHECK_ONLY=true
            shift
            ;;
        --force|-f)
            FORCE_UPDATE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--auto|-a] [--check|-c] [--force|-f] [--help|-h]"
            echo ""
            echo "Options:"
            echo "  --auto, -a    Automatic update without prompts"
            echo "  --check, -c   Check for updates only, don't install"
            echo "  --force, -f   Force update even if versions match"
            echo "  --help, -h    Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

log_info() {
    echo -e "${BLUE}[UPDATE]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

ask_user() {
    if [ "$AUTO_MODE" = true ]; then
        return 0
    fi

    local prompt="$1"
    local default="${2:-y}"

    read -p "$prompt [${default}]: " response
    response=${response:-$default}

    [[ "$response" =~ ^[Yy]([Ee][Ss])?$ ]]
}

# Update tracking
UPDATES_AVAILABLE=0
UPDATES_APPLIED=0

log_info "Starting Claude Code Ecosystem update check..."

# Create update log
UPDATE_LOG="$HOME/.claude/update-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$HOME/.claude"
exec > >(tee -a "$UPDATE_LOG") 2>&1

# Function to check and update npm package
update_npm_package() {
    local package_name="$1"
    local global="${2:-true}"
    local version_command="$3"

    log_info "Checking $package_name..."

    # Get current version
    local current_version=""
    if [ "$global" = true ]; then
        current_version=$(npm list -g "$package_name" --depth=0 2>/dev/null | grep "$package_name" | cut -d'@' -f2 || echo "not-installed")
    else
        current_version=$(npm list "$package_name" --depth=0 2>/dev/null | grep "$package_name" | cut -d'@' -f2 || echo "not-installed")
    fi

    # Get latest version
    local latest_version=$(npm view "$package_name" version 2>/dev/null || echo "unknown")

    if [ "$current_version" = "not-installed" ]; then
        log_warning "$package_name is not installed"
        if ask_user "Install $package_name $latest_version?"; then
            if [ "$CHECK_ONLY" = false ]; then
                if [ "$global" = true ]; then
                    npm install -g "$package_name@latest"
                else
                    npm install "$package_name@latest"
                fi
                log_success "$package_name installed ($latest_version)"
                ((UPDATES_APPLIED++))
            else
                log_info "Would install $package_name $latest_version"
            fi
            ((UPDATES_AVAILABLE++))
        fi
    elif [ "$current_version" != "$latest_version" ] || [ "$FORCE_UPDATE" = true ]; then
        log_warning "$package_name update available: $current_version → $latest_version"
        if ask_user "Update $package_name to $latest_version?"; then
            if [ "$CHECK_ONLY" = false ]; then
                if [ "$global" = true ]; then
                    npm install -g "$package_name@latest"
                else
                    npm install "$package_name@latest"
                fi
                log_success "$package_name updated to $latest_version"
                ((UPDATES_APPLIED++))
            else
                log_info "Would update $package_name to $latest_version"
            fi
            ((UPDATES_AVAILABLE++))
        fi
    else
        log_success "$package_name is up to date ($current_version)"
    fi
}

# Update Claude CLI
log_info "Checking Claude CLI..."
if command -v claude &> /dev/null; then
    current_claude_version=$(claude --version 2>/dev/null | head -n1 || echo "unknown")
    log_info "Current Claude CLI version: $current_claude_version"

    # Claude CLI typically updates through its own mechanism
    if ask_user "Check for Claude CLI updates?"; then
        if [ "$CHECK_ONLY" = false ]; then
            if claude update 2>/dev/null; then
                log_success "Claude CLI updated"
                ((UPDATES_APPLIED++))
            else
                log_warning "Claude CLI update not available or failed"
            fi
        else
            log_info "Would check for Claude CLI updates"
        fi
        ((UPDATES_AVAILABLE++))
    fi
else
    log_error "Claude CLI not found. Please install it first."
fi

# Update Claude Flow
update_npm_package "claude-flow@alpha" true "npx claude-flow --version"

# Update optional packages
for package in "ruv-swarm" "flow-nexus@latest"; do
    package_base=$(echo "$package" | cut -d'@' -f1)
    if npm list -g "$package_base" &> /dev/null; then
        update_npm_package "$package" true "npx $package_base --version"
    fi
done

# Update MCP server configurations
log_info "Checking MCP server configurations..."
if command -v claude &> /dev/null && claude mcp list &> /dev/null; then
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*([^[:space:]]+) ]]; then
            server_name="${BASH_REMATCH[1]}"
            log_info "Testing MCP server: $server_name"

            if ! claude mcp test "$server_name" &> /dev/null; then
                log_warning "MCP server '$server_name' is not responding"
                if ask_user "Reconfigure MCP server '$server_name'?"; then
                    if [ "$CHECK_ONLY" = false ]; then
                        # Remove and re-add the server
                        claude mcp remove "$server_name" 2>/dev/null || true

                        case "$server_name" in
                            "claude-flow")
                                claude mcp add claude-flow "npx claude-flow@alpha mcp start"
                                ;;
                            "ruv-swarm")
                                claude mcp add ruv-swarm "npx ruv-swarm mcp start"
                                ;;
                            "flow-nexus")
                                claude mcp add flow-nexus "npx flow-nexus@latest mcp start"
                                ;;
                        esac

                        log_success "MCP server '$server_name' reconfigured"
                        ((UPDATES_APPLIED++))
                    else
                        log_info "Would reconfigure MCP server '$server_name'"
                    fi
                    ((UPDATES_AVAILABLE++))
                fi
            else
                log_success "MCP server '$server_name' is responding"
            fi
        fi
    done < <(claude mcp list 2>/dev/null || echo "")
fi

# Update project dependencies
if [ -f "package.json" ]; then
    log_info "Checking project dependencies..."

    if [ -f "package-lock.json" ] && ask_user "Update project dependencies?"; then
        if [ "$CHECK_ONLY" = false ]; then
            npm update
            log_success "Project dependencies updated"
            ((UPDATES_APPLIED++))
        else
            log_info "Would update project dependencies"
        fi
        ((UPDATES_AVAILABLE++))
    fi
fi

# Update ecosystem scripts
log_info "Checking ecosystem scripts..."
ECOSYSTEM_VERSION="1.0.0"
current_ecosystem_version="unknown"

if [ -f "$HOME/.claude/ecosystem-config.json" ]; then
    current_ecosystem_version=$(jq -r '.version // "unknown"' "$HOME/.claude/ecosystem-config.json" 2>/dev/null || echo "unknown")
fi

if [ "$current_ecosystem_version" != "$ECOSYSTEM_VERSION" ] || [ "$FORCE_UPDATE" = true ]; then
    log_info "Ecosystem scripts version: $current_ecosystem_version"
    if ask_user "Update ecosystem configuration to version $ECOSYSTEM_VERSION?"; then
        if [ "$CHECK_ONLY" = false ]; then
            # Update the configuration file
            if [ -f "$HOME/.claude/ecosystem-config.json" ]; then
                jq ".version = \"$ECOSYSTEM_VERSION\" | .lastUpdate = \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"" \
                   "$HOME/.claude/ecosystem-config.json" > "/tmp/ecosystem-config.json" && \
                mv "/tmp/ecosystem-config.json" "$HOME/.claude/ecosystem-config.json"
            fi
            log_success "Ecosystem configuration updated"
            ((UPDATES_APPLIED++))
        else
            log_info "Would update ecosystem configuration"
        fi
        ((UPDATES_AVAILABLE++))
    fi
fi

# Run validation after updates
if [ "$CHECK_ONLY" = false ] && [ $UPDATES_APPLIED -gt 0 ]; then
    log_info "Running validation after updates..."
    if [ -f ".claude/validate.sh" ]; then
        bash .claude/validate.sh --quiet || log_warning "Validation completed with warnings"
    fi
fi

# Summary
echo
echo -e "${CYAN}━━━ Update Summary ━━━${NC}"
echo -e "Updates available: ${YELLOW}$UPDATES_AVAILABLE${NC}"

if [ "$CHECK_ONLY" = false ]; then
    echo -e "Updates applied: ${GREEN}$UPDATES_APPLIED${NC}"

    if [ $UPDATES_APPLIED -gt 0 ]; then
        log_success "Claude Code Ecosystem updated successfully!"
        echo "Update log saved to: $UPDATE_LOG"

        # Save update status
        cat > "$HOME/.claude/last-update.json" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "updatesAvailable": $UPDATES_AVAILABLE,
  "updatesApplied": $UPDATES_APPLIED,
  "status": "success"
}
EOF
    else
        log_info "No updates were applied"
    fi
else
    echo -e "Mode: ${BLUE}Check only${NC}"

    if [ $UPDATES_AVAILABLE -gt 0 ]; then
        echo
        log_info "Run without --check to apply updates"
    else
        log_success "Everything is up to date!"
    fi
fi

log_info "Update check completed"