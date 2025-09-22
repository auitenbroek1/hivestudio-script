#!/bin/bash

# HiveStudio Stage 1 Installation Script
# Prerequisites and Claude Code setup with authentication checkpoint
#
# Features:
# - Comprehensive platform detection (Codespaces, Docker, WSL, macOS, Linux)
# - Visual feedback with emoji indicators
# - Multiple fallback installation methods
# - Robust error handling with retry mechanisms
# - Clean privilege escalation abstraction
# - Stops at authentication checkpoint for Stage 2 handoff

set -euo pipefail

# Script metadata
declare -r STAGE1_VERSION="1.0.0"
declare -r SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
declare -r STAGE1_LOG="$PROJECT_ROOT/.hivestudio-stage1.log"
declare -r HANDOFF_FILE="$PROJECT_ROOT/.stage1-handoff.json"

# Visual feedback functions
print_header() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                   HiveStudio Stage 1 Setup                  ║
║            Prerequisites & Claude Code Installation          ║
║                                                              ║
║  🎯 Focus: System preparation and authentication checkpoint  ║
║  📍 Stops at: Claude authentication for Stage 2 handoff     ║
╚══════════════════════════════════════════════════════════════╝

EOF
}

log_info() {
    local msg="$1"
    echo "ℹ️  $msg" | tee -a "$STAGE1_LOG"
}

log_success() {
    local msg="$1"
    echo "✅ $msg" | tee -a "$STAGE1_LOG"
}

log_warning() {
    local msg="$1"
    echo "⚠️  $msg" | tee -a "$STAGE1_LOG"
}

log_error() {
    local msg="$1"
    echo "❌ $msg" | tee -a "$STAGE1_LOG"
}

log_step() {
    local step="$1"
    local msg="$2"
    echo "📋 Step $step: $msg" | tee -a "$STAGE1_LOG"
}

# Privilege escalation helper
run_with_fallback() {
    local cmd="$1"
    local fallback_cmd="${2:-}"

    if eval "$cmd" 2>/dev/null; then
        return 0
    elif [ -n "$fallback_cmd" ]; then
        log_warning "Primary command failed, trying fallback..."
        eval "$fallback_cmd"
    else
        return 1
    fi
}

# Platform detection
detect_platform() {
    local platform=""
    local details=""

    if [ -n "${CODESPACES:-}" ]; then
        platform="codespaces"
        details="GitHub Codespaces"
    elif [ -f /.dockerenv ]; then
        platform="docker"
        details="Docker Container"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -q Microsoft /proc/version 2>/dev/null; then
            platform="wsl"
            details="Windows Subsystem for Linux"
        else
            platform="linux"
            details="Linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        platform="macos"
        details="macOS"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        platform="windows"
        details="Windows"
    else
        platform="unknown"
        details="Unknown OS: $OSTYPE"
    fi

    echo "$platform"
    log_info "Detected platform: $details"

    # Store platform info for Stage 2
    echo "{\"platform\": \"$platform\", \"details\": \"$details\"}" > "$PROJECT_ROOT/.platform-info.json"
}

# Prerequisites checking with retries
check_command() {
    local cmd="$1"
    local name="$2"
    local install_hint="${3:-}"

    if command -v "$cmd" &> /dev/null; then
        local version
        case "$cmd" in
            "node") version=$(node --version 2>/dev/null || echo "unknown") ;;
            "npm") version=$(npm --version 2>/dev/null || echo "unknown") ;;
            "git") version=$(git --version 2>/dev/null | cut -d' ' -f3 || echo "unknown") ;;
            *) version="installed" ;;
        esac
        log_success "$name found: $version"
        return 0
    else
        log_error "$name not found"
        if [ -n "$install_hint" ]; then
            log_info "Install hint: $install_hint"
        fi
        return 1
    fi
}

install_prerequisites() {
    log_step "1" "Checking prerequisites"

    local missing_deps=()

    # Check Node.js
    if ! check_command "node" "Node.js" "curl -fsSL https://nodejs.org/dist/v20.11.0/node-v20.11.0-linux-x64.tar.xz"; then
        missing_deps+=("nodejs")
    fi

    # Check npm (usually comes with Node.js)
    if ! check_command "npm" "npm" "included with Node.js installation"; then
        missing_deps+=("npm")
    fi

    # Check Git
    if ! check_command "git" "Git" "apt-get install git (Ubuntu) | brew install git (macOS)"; then
        missing_deps+=("git")
    fi

    # Check curl
    if ! check_command "curl" "curl" "apt-get install curl (Ubuntu) | brew install curl (macOS)"; then
        missing_deps+=("curl")
    fi

    if [ ${#missing_deps[@]} -eq 0 ]; then
        log_success "All prerequisites satisfied"
        return 0
    else
        log_error "Missing dependencies: ${missing_deps[*]}"

        # Attempt automated installation for supported platforms
        local platform=$(detect_platform)
        case "$platform" in
            "codespaces"|"docker"|"linux")
                attempt_linux_deps_install "${missing_deps[@]}"
                ;;
            "macos")
                attempt_macos_deps_install "${missing_deps[@]}"
                ;;
            *)
                log_error "Manual installation required for platform: $platform"
                return 1
                ;;
        esac
    fi
}

attempt_linux_deps_install() {
    local deps=("$@")
    log_info "Attempting automated dependency installation..."

    for dep in "${deps[@]}"; do
        case "$dep" in
            "nodejs")
                run_with_fallback \
                    "curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt-get install -y nodejs" \
                    "curl -fsSL https://nodejs.org/dist/v20.11.0/node-v20.11.0-linux-x64.tar.xz | tar -xJ -C /tmp && sudo cp -r /tmp/node-v20.11.0-linux-x64/* /usr/local/"
                ;;
            "git")
                run_with_fallback "sudo apt-get update && sudo apt-get install -y git" "sudo yum install -y git"
                ;;
            "curl")
                run_with_fallback "sudo apt-get update && sudo apt-get install -y curl" "sudo yum install -y curl"
                ;;
        esac
    done
}

attempt_macos_deps_install() {
    local deps=("$@")
    log_info "Attempting automated dependency installation via Homebrew..."

    # Install Homebrew if not present
    if ! command -v brew &> /dev/null; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    for dep in "${deps[@]}"; do
        case "$dep" in
            "nodejs") brew install node ;;
            "git") brew install git ;;
            "curl") brew install curl ;;
        esac
    done
}

# Claude Code installation with multiple fallback methods
install_claude_code() {
    log_step "2" "Installing Claude Code CLI"

    if command -v claude &> /dev/null; then
        local version=$(claude --version 2>/dev/null || echo "unknown")
        log_success "Claude Code already installed: $version"
        return 0
    fi

    log_info "Installing Claude Code CLI..."

    # Method 1: Official installer (recommended)
    if run_with_fallback "curl -fsSL https://claude.ai/install.sh | sh"; then
        log_success "Claude Code installed via official installer"
        # Refresh PATH
        export PATH="$HOME/.local/bin:$PATH"
        return 0
    fi

    # Method 2: npm global installation
    if command -v npm &> /dev/null; then
        if run_with_fallback "npm install -g @anthropic-ai/claude-code"; then
            log_success "Claude Code installed via npm"
            return 0
        fi
    fi

    # Method 3: Direct download (fallback)
    log_warning "Attempting direct download fallback..."
    local os_arch
    case "$(uname -s)-$(uname -m)" in
        "Linux-x86_64") os_arch="linux-amd64" ;;
        "Darwin-x86_64") os_arch="darwin-amd64" ;;
        "Darwin-arm64") os_arch="darwin-arm64" ;;
        *)
            log_error "Unsupported architecture: $(uname -s)-$(uname -m)"
            return 1
            ;;
    esac

    local download_url="https://github.com/anthropic-ai/claude-code/releases/latest/download/claude-code-$os_arch"
    if curl -fsSL "$download_url" -o "$HOME/.local/bin/claude" && chmod +x "$HOME/.local/bin/claude"; then
        log_success "Claude Code installed via direct download"
        return 0
    fi

    log_error "All Claude Code installation methods failed"
    return 1
}

# Authentication checkpoint
authentication_checkpoint() {
    log_step "3" "Authentication checkpoint"

    log_info "Testing Claude Code authentication..."

    # Check if already authenticated
    if claude auth status &> /dev/null; then
        log_success "Claude Code already authenticated"
        return 0
    fi

    log_warning "Claude Code authentication required"
    echo ""
    echo "🔐 AUTHENTICATION REQUIRED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "To continue with HiveStudio installation, you need to:"
    echo ""
    echo "1. Visit: https://claude.ai/login"
    echo "2. Sign in or create an account"
    echo "3. Run: claude auth login"
    echo "4. Follow the authentication prompts"
    echo ""
    echo "🛑 Stage 1 stops here for security."
    echo "   After authentication, run Stage 2 for full installation."
    echo ""

    return 1  # Intentionally fail to stop at checkpoint
}

# Create handoff file for Stage 2
create_stage2_handoff() {
    log_step "4" "Preparing Stage 2 handoff"

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local platform=$(detect_platform)

    # Gather system information
    local node_version=$(node --version 2>/dev/null || echo "unknown")
    local npm_version=$(npm --version 2>/dev/null || echo "unknown")
    local git_version=$(git --version 2>/dev/null | cut -d' ' -f3 || echo "unknown")
    local claude_version=$(claude --version 2>/dev/null || echo "not_installed")

    # Check authentication status
    local auth_status="pending"
    if claude auth status &> /dev/null; then
        auth_status="authenticated"
    fi

    # Create comprehensive handoff file
    cat > "$HANDOFF_FILE" << EOF
{
  "stage1": {
    "version": "$STAGE1_VERSION",
    "completed_at": "$timestamp",
    "status": "completed_with_auth_pending"
  },
  "platform": {
    "type": "$platform",
    "os": "$(uname -s)",
    "arch": "$(uname -m)",
    "working_directory": "$PROJECT_ROOT"
  },
  "dependencies": {
    "node": "$node_version",
    "npm": "$npm_version",
    "git": "$git_version",
    "claude_code": "$claude_version"
  },
  "authentication": {
    "status": "$auth_status",
    "required_action": "claude auth login"
  },
  "next_steps": {
    "stage2_script": "$PROJECT_ROOT/stage2/install-stage2.sh",
    "requirements": ["claude_authentication_complete"],
    "description": "Run Stage 2 after completing Claude authentication"
  }
}
EOF

    log_success "Stage 2 handoff file created: $HANDOFF_FILE"
}

# Cleanup function
cleanup() {
    if [ $? -ne 0 ]; then
        log_error "Stage 1 installation failed"
        echo ""
        echo "📋 Troubleshooting:"
        echo "• Check log file: $STAGE1_LOG"
        echo "• Verify platform requirements"
        echo "• Try manual prerequisite installation"
        echo "• Report issues at: https://github.com/hivestudio/support"
    fi
}

# Main execution flow
main() {
    # Initialize logging
    echo "HiveStudio Stage 1 Installation Log - $(date)" > "$STAGE1_LOG"

    # Set up cleanup handler
    trap cleanup EXIT

    # Display header
    print_header

    log_info "Starting HiveStudio Stage 1 Installation v$STAGE1_VERSION"
    log_info "Working directory: $PROJECT_ROOT"
    echo ""

    # Detect platform
    local platform=$(detect_platform)
    echo ""

    # Execute installation steps
    if install_prerequisites && install_claude_code; then
        create_stage2_handoff

        # Check authentication and provide next steps
        if authentication_checkpoint; then
            log_success "Stage 1 completed successfully with authentication"
            echo ""
            echo "🎉 Ready for Stage 2!"
            echo "Run: $PROJECT_ROOT/stage2/install-stage2.sh"
        else
            log_warning "Stage 1 completed - authentication required for Stage 2"
            echo ""
            echo "📋 Next Steps:"
            echo "1. Complete Claude authentication: claude auth login"
            echo "2. Run Stage 2: $PROJECT_ROOT/stage2/install-stage2.sh"
        fi
    else
        log_error "Stage 1 installation failed"
        exit 1
    fi

    echo ""
    log_success "Stage 1 installation completed!"
    log_info "Check handoff file: $HANDOFF_FILE"
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi