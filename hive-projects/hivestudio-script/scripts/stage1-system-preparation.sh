#!/bin/bash

# Stage 1: System Preparation and Claude Code Setup
# This runs OUTSIDE Claude Code and prepares the environment
# Purpose: Validate prerequisites, install Claude Code, launch it, verify auth

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Global error counter
ERRORS=0

# Version comparison function
version_less_than() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$1" ] && [ "$1" != "$2" ]
}

# Enhanced dependency validation
validate_system_prerequisites() {
    log "🔍 Validating system prerequisites..."

    # Core requirements
    check_requirement "Node.js" "node --version" "18.0.0"
    check_requirement "npm" "npm --version" "8.0.0"
    check_requirement "Git" "git --version" "2.0.0"
    check_requirement "curl" "curl --version" "7.0.0"

    # Platform-specific checks
    detect_platform_specific_requirements

    # Network connectivity
    validate_network_connectivity

    # Disk space
    validate_disk_space

    # Permissions
    validate_permissions

    if [ $ERRORS -gt 0 ]; then
        error "❌ $ERRORS prerequisite checks failed"
        echo ""
        echo "Please resolve the issues above before continuing."
        echo "Visit the installation guide for help: https://github.com/auitenbroek1/hivestudio-script"
        return 1
    fi

    log "✅ All prerequisites validated successfully"
    return 0
}

check_requirement() {
    local name=$1
    local command=$2
    local min_version=$3

    info "Checking $name..."

    if ! command -v ${command%% *} &> /dev/null; then
        error "❌ $name is required but not installed"
        provide_installation_instructions "$name"
        ((ERRORS++))
    else
        local version=$(${command} 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        if [ -n "$version" ] && [ -n "$min_version" ]; then
            if version_less_than "$version" "$min_version"; then
                warn "⚠️ $name version $version is below recommended $min_version"
            else
                log "✅ $name: $version"
            fi
        else
            log "✅ $name: available"
        fi
    fi
}

provide_installation_instructions() {
    local tool=$1

    case "$tool" in
        "Node.js")
            echo "  Install Node.js from: https://nodejs.org/"
            echo "  Or use a version manager like nvm: https://github.com/nvm-sh/nvm"
            ;;
        "npm")
            echo "  npm usually comes with Node.js"
            echo "  If missing, reinstall Node.js from: https://nodejs.org/"
            ;;
        "Git")
            echo "  Install Git from: https://git-scm.com/"
            echo "  macOS: 'xcode-select --install'"
            echo "  Ubuntu/Debian: 'sudo apt install git'"
            ;;
        "curl")
            echo "  Install curl:"
            echo "  macOS: Usually pre-installed"
            echo "  Ubuntu/Debian: 'sudo apt install curl'"
            ;;
    esac
}

detect_platform_specific_requirements() {
    local platform=$(uname -s)
    info "Detected platform: $platform"

    case "$platform" in
        "Darwin")
            # macOS specific checks
            if ! xcode-select -p &> /dev/null; then
                warn "⚠️ Xcode Command Line Tools not installed (recommended)"
                echo "  Run: xcode-select --install"
            fi
            ;;
        "Linux")
            # Linux specific checks
            if [ -n "$CODESPACES" ]; then
                log "✅ GitHub Codespaces environment detected"
            else
                check_linux_dependencies
            fi
            ;;
        "MINGW"*|"CYGWIN"*|"MSYS"*)
            # Windows specific checks
            warn "⚠️ Windows environment detected - limited support"
            echo "  Consider using WSL for better compatibility"
            ;;
    esac
}

check_linux_dependencies() {
    # Check for common Linux development tools
    local tools=("make" "gcc" "python3")

    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            warn "⚠️ $tool not found (may be needed for native dependencies)"
        fi
    done
}

validate_network_connectivity() {
    info "Checking network connectivity..."

    local test_urls=(
        "https://claude.ai"
        "https://registry.npmjs.org"
        "https://github.com"
    )

    for url in "${test_urls[@]}"; do
        if curl -s --connect-timeout 5 "$url" > /dev/null; then
            log "✅ Network connectivity to $(echo $url | cut -d'/' -f3)"
        else
            warn "⚠️ Cannot reach $url (may affect installation)"
        fi
    done
}

validate_disk_space() {
    info "Checking disk space..."

    # Get available disk space in MB
    local available_mb
    if command -v df &> /dev/null; then
        if [[ "$(uname)" == "Darwin" ]]; then
            available_mb=$(df -m . | tail -1 | awk '{print $4}')
        else
            available_mb=$(df -BM . | tail -1 | awk '{print $4}' | sed 's/M//')
        fi

        if [ "$available_mb" -gt 2048 ]; then
            log "✅ Disk space: ${available_mb}MB available"
        else
            warn "⚠️ Low disk space: ${available_mb}MB (recommend 2GB+)"
        fi
    else
        warn "⚠️ Cannot check disk space"
    fi
}

validate_permissions() {
    info "Checking permissions..."

    # Check if we can write to current directory
    if [ -w . ]; then
        log "✅ Write permissions in current directory"
    else
        error "❌ No write permissions in current directory"
        ((ERRORS++))
    fi

    # Check if we can create temp files
    if touch .hivestudio-temp-test 2>/dev/null; then
        rm -f .hivestudio-temp-test
        log "✅ Can create temporary files"
    else
        error "❌ Cannot create temporary files"
        ((ERRORS++))
    fi
}

# Claude Code installation with multiple strategies
install_claude_code() {
    log "🚀 Installing Claude Code application..."

    # Check if already installed
    if command -v claude &> /dev/null; then
        local version=$(claude --version 2>/dev/null || echo "unknown")
        log "✅ Claude Code already installed: $version"
        return 0
    fi

    # Multiple installation strategies
    local install_methods=(
        "npm_global"
        "homebrew"
        "curl_direct"
    )

    for method in "${install_methods[@]}"; do
        info "Trying installation method: $method"
        if attempt_installation_$method; then
            log "✅ Claude Code installed via $method"
            return 0
        else
            warn "❌ Installation via $method failed"
        fi
    done

    error "❌ Failed to install Claude Code via all methods"
    show_manual_installation_guide
    return 1
}

attempt_installation_npm_global() {
    if command -v npm &> /dev/null; then
        log "Attempting npm global installation..."
        npm install -g @anthropic-ai/claude-code 2>/dev/null
    else
        return 1
    fi
}

attempt_installation_homebrew() {
    if command -v brew &> /dev/null; then
        log "Attempting Homebrew installation..."
        brew install claude-ai/claude/claude 2>/dev/null
    else
        return 1
    fi
}

attempt_installation_curl_direct() {
    log "Attempting curl installation..."
    if curl -fsSL https://claude.ai/install.sh | sh 2>/dev/null; then
        # Add to PATH for current session
        export PATH="$PATH:$HOME/.local/bin"
        # Update shell profile for future sessions
        update_shell_profile
        return 0
    else
        return 1
    fi
}

update_shell_profile() {
    local shell_profile=""

    case "$SHELL" in
        */bash)
            shell_profile="$HOME/.bashrc"
            [ -f "$HOME/.bash_profile" ] && shell_profile="$HOME/.bash_profile"
            ;;
        */zsh)
            shell_profile="$HOME/.zshrc"
            ;;
        */fish)
            shell_profile="$HOME/.config/fish/config.fish"
            ;;
    esac

    if [ -n "$shell_profile" ] && [ -w "$shell_profile" ]; then
        if ! grep -q "/.local/bin" "$shell_profile" 2>/dev/null; then
            echo 'export PATH="$PATH:$HOME/.local/bin"' >> "$shell_profile"
            log "✅ Updated PATH in $shell_profile"
        fi
    fi
}

show_manual_installation_guide() {
    echo ""
    echo "📖 Manual Installation Guide"
    echo "============================"
    echo ""
    echo "Please install Claude Code manually using one of these methods:"
    echo ""
    echo "Method 1 - npm (recommended):"
    echo "  npm install -g @anthropic-ai/claude-code"
    echo ""
    echo "Method 2 - Homebrew (macOS):"
    echo "  brew install claude-ai/claude/claude"
    echo ""
    echo "Method 3 - Direct download:"
    echo "  curl -fsSL https://claude.ai/install.sh | sh"
    echo ""
    echo "Method 4 - Official website:"
    echo "  Visit: https://claude.ai/download"
    echo ""
    echo "After installation, re-run this script to continue."
}

# Launch Claude Code and verify
launch_claude_code() {
    log "🚀 Launching Claude Code..."

    # Verify installation first
    if ! command -v claude &> /dev/null; then
        error "❌ Claude Code not found after installation"
        return 1
    fi

    # Check if already running
    if claude status &> /dev/null; then
        log "✅ Claude Code is already running"
        return 0
    fi

    # Launch Claude Code
    info "Starting Claude Code..."

    # Try to launch in background
    claude --daemon &> /dev/null &
    local claude_pid=$!

    if [ -n "$claude_pid" ]; then

        # Wait for startup
        if wait_for_claude_startup; then
            log "✅ Claude Code launched successfully (PID: $claude_pid)"
            return 0
        else
            error "❌ Claude Code failed to start properly"
            return 1
        fi
    else
        # Fallback: launch normally and instruct user
        info "Launching Claude Code normally..."
        echo ""
        echo "🖥️ Claude Code should open now"
        echo "If it doesn't open automatically, run: claude"
        echo ""

        # Try normal launch
        claude &
        sleep 3

        if wait_for_claude_startup; then
            return 0
        else
            return 1
        fi
    fi
}

wait_for_claude_startup() {
    local timeout=60
    local elapsed=0

    info "Waiting for Claude Code to start..."

    while [ $elapsed -lt $timeout ]; do
        if claude status &> /dev/null; then
            log "✅ Claude Code is running"
            return 0
        fi
        sleep 2
        ((elapsed += 2))

        # Show progress every 10 seconds
        if [ $((elapsed % 10)) -eq 0 ]; then
            info "Still waiting... (${elapsed}s/${timeout}s)"
        fi
    done

    error "❌ Claude Code failed to start within ${timeout}s"
    echo ""
    echo "Troubleshooting:"
    echo "• Try running 'claude' manually"
    echo "• Check if ports are available"
    echo "• Restart your terminal and try again"
    return 1
}

# Authentication checkpoint
verify_authentication_checkpoint() {
    log "🔐 Verifying Claude Code authentication..."

    # Check if authenticated
    if claude auth status &> /dev/null; then
        local status=$(claude auth status --format json 2>/dev/null || echo '{}')
        log "✅ Already authenticated"
        verify_subscription_tier "$status"
    else
        show_authentication_instructions
        wait_for_authentication
    fi

    log "✅ Authentication checkpoint passed"
}

show_authentication_instructions() {
    echo ""
    echo "🔐 Claude Code Authentication Required"
    echo "====================================="
    echo ""
    echo "Claude Code needs to be authenticated before proceeding."
    echo ""
    echo "Steps:"
    echo "1. Claude Code should be running now"
    echo "2. If not open, you can open it manually"
    echo "3. Sign in with your Anthropic account"
    echo "4. Ensure you have a Pro or Max subscription"
    echo "5. Complete the authentication process"
    echo ""
    echo "💡 Tip: Pro/Max plans provide the best Claude Code experience"
    echo ""
}

wait_for_authentication() {
    local timeout=300  # 5 minutes
    local elapsed=0

    echo "⏳ Waiting for authentication (up to 5 minutes)..."
    echo "Press Ctrl+C if you need to cancel"
    echo ""

    while [ $elapsed -lt $timeout ]; do
        if claude auth status &> /dev/null; then
            log "✅ Authentication successful!"

            local status=$(claude auth status --format json 2>/dev/null || echo '{}')
            verify_subscription_tier "$status"
            return 0
        fi

        sleep 5
        ((elapsed += 5))

        # Show progress every 30 seconds
        if [ $((elapsed % 30)) -eq 0 ]; then
            info "Still waiting for authentication... (${elapsed}s/${timeout}s)"
        fi
    done

    error "❌ Authentication timeout after ${timeout}s"
    echo ""
    echo "Please:"
    echo "1. Make sure Claude Code is open"
    echo "2. Complete the sign-in process"
    echo "3. Re-run this script"
    return 1
}

verify_subscription_tier() {
    local status=$1

    # Try to extract tier from status
    local tier="unknown"
    if command -v jq &> /dev/null && [ -n "$status" ]; then
        tier=$(echo "$status" | jq -r '.subscription.tier // "unknown"' 2>/dev/null)
    fi

    case "$tier" in
        "pro"|"max")
            log "✅ Subscription tier: $tier (optimal for Claude Code)"
            ;;
        "free"|"plus")
            warn "⚠️ Current tier: $tier"
            echo "   Pro or Max subscription recommended for best Claude Code performance"
            echo "   You can continue with current tier, but may have limitations"
            ;;
        *)
            info "ℹ️ Subscription tier: $tier"
            echo "   Ensure you have access to Claude Code features"
            ;;
    esac
}

# Complete Stage 1 and prepare handoff
complete_stage1_handoff() {
    log "✅ Stage 1 completed successfully"

    # Create handoff file with environment info
    create_handoff_file

    # Show Stage 2 instructions
    show_stage2_instructions

    # Ensure Claude Code is accessible
    ensure_claude_code_accessible
}

create_handoff_file() {
    log "Creating handoff file for Stage 2..."

    cat > .hivestudio-stage1-complete << EOF
{
    "stage1_completed": true,
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "claude_code_version": "$(claude --version 2>/dev/null || echo 'unknown')",
    "system_info": {
        "os": "$(uname -s)",
        "version": "$(uname -r)",
        "architecture": "$(uname -m)",
        "node_version": "$(node --version 2>/dev/null || echo 'not_found')",
        "npm_version": "$(npm --version 2>/dev/null || echo 'not_found')",
        "shell": "$SHELL",
        "codespaces": "${CODESPACES:-false}",
        "git_version": "$(git --version 2>/dev/null || echo 'not_found')"
    },
    "next_step": "Run 'hivestudio-install' inside Claude Code"
}
EOF

    log "✅ Handoff file created: .hivestudio-stage1-complete"
}

show_stage2_instructions() {
    echo ""
    echo "🎉 Stage 1 Complete - System Ready!"
    echo "===================================="
    echo ""
    echo "Your system is now prepared for HiveStudio installation."
    echo "Claude Code is running and authenticated."
    echo ""
    echo "📝 NEXT STEP - Inside Claude Code:"
    echo ""
    echo "   1. Open Claude Code (should already be running)"
    echo "   2. Navigate to this project directory"
    echo "   3. Run this command:"
    echo ""
    echo -e "      ${GREEN}hivestudio-install${NC}"
    echo ""
    echo "✨ Stage 2 will leverage Claude Code's intelligence to:"
    echo "   • Install MCP servers automatically"
    echo "   • Handle any errors intelligently"
    echo "   • Configure all integrations"
    echo "   • Validate the complete setup"
    echo "   • Provide contextual help if needed"
    echo ""
    echo "💡 Benefits of running Stage 2 inside Claude Code:"
    echo "   • Intelligent error analysis and recovery"
    echo "   • Automatic problem-solving"
    echo "   • Contextual guidance for your environment"
    echo "   • Learning from successful installations"
    echo ""
}

ensure_claude_code_accessible() {
    if claude status &> /dev/null; then
        log "✅ Claude Code is accessible and ready"

        # Try to show Claude Code if possible
        if command -v open &> /dev/null; then
            # macOS
            open -a "Claude Code" . 2>/dev/null || true
        elif command -v xdg-open &> /dev/null; then
            # Linux
            xdg-open . 2>/dev/null || true
        fi
    else
        warn "⚠️ Claude Code may not be accessible"
        echo "   You may need to start it manually with: claude"
    fi
}

# Main execution
main() {
    echo "🚀 HiveStudio Stage 1: System Preparation"
    echo "========================================="
    echo ""
    echo "This stage will:"
    echo "• ✅ Validate system prerequisites"
    echo "• 🚀 Install Claude Code"
    echo "• 🔐 Verify authentication"
    echo "• 📋 Prepare for Stage 2"
    echo ""

    # Execute all Stage 1 steps
    if ! validate_system_prerequisites; then
        error "❌ Prerequisites validation failed"
        exit 1
    fi

    if ! install_claude_code; then
        error "❌ Claude Code installation failed"
        exit 1
    fi

    if ! launch_claude_code; then
        error "❌ Claude Code launch failed"
        exit 1
    fi

    if ! verify_authentication_checkpoint; then
        error "❌ Authentication verification failed"
        exit 1
    fi

    complete_stage1_handoff

    echo ""
    echo -e "${GREEN}🎉 Stage 1 completed successfully!${NC}"
    echo -e "${BLUE}Ready for Stage 2 - follow the instructions above${NC}"
    echo ""
}

# Run Stage 1
main "$@"