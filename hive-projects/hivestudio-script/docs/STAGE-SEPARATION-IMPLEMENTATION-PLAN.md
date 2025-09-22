# HiveStudio Two-Stage Installation Implementation Plan

## Overview

This implementation plan separates the installation into two distinct stages to maximize success by leveraging Claude Code's intelligence for complex tasks while providing robust dependency management outside of Claude Code.

## Architecture Decision

**Stage 1 (Outside Claude)**: Dependency validation, Claude Code installation, and launch
**Stage 2 (Inside Claude Code)**: Complex installation tasks using Claude Code's intelligence

## Stage 1: System Preparation (Outside Claude Code)

### Purpose
- Validate system prerequisites
- Install Claude Code application
- Launch Claude Code
- Verify authentication checkpoint
- Prepare environment for Stage 2

### Implementation Details

#### 1.1 Enhanced Dependency Checker

Create `scripts/stage1-dependency-checker.sh`:
```bash
#!/bin/bash

# Stage 1: System Preparation and Claude Code Setup
# This runs OUTSIDE Claude Code and prepares the environment

set -e

# Enhanced dependency validation
validate_system_prerequisites() {
    local errors=0

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
    validate_disk_space "2GB"

    # Permissions
    validate_permissions

    return $errors
}

check_requirement() {
    local name=$1
    local command=$2
    local min_version=$3

    if ! command -v ${command%% *} &> /dev/null; then
        error "❌ $name is required but not installed"
        provide_installation_instructions "$name"
        ((errors++))
    else
        local version=$(${command} | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        if version_less_than "$version" "$min_version"; then
            warn "⚠️ $name version $version is below recommended $min_version"
        else
            log "✅ $name: $version"
        fi
    fi
}
```

#### 1.2 Claude Code Installation Automation

```bash
install_claude_code() {
    log "Installing Claude Code application..."

    # Multiple installation strategies
    local install_methods=(
        "npm_global"
        "homebrew"
        "curl_direct"
        "manual_download"
    )

    for method in "${install_methods[@]}"; do
        if attempt_installation_$method; then
            log "✅ Claude Code installed via $method"
            return 0
        fi
    done

    error "Failed to install Claude Code via all methods"
    show_manual_installation_guide
    return 1
}

attempt_installation_npm_global() {
    if command -v npm &> /dev/null; then
        npm install -g @anthropic-ai/claude-code
    fi
}

attempt_installation_homebrew() {
    if command -v brew &> /dev/null; then
        brew install claude-ai/claude/claude
    fi
}

attempt_installation_curl_direct() {
    curl -fsSL https://claude.ai/install.sh | sh
    export PATH="$PATH:$HOME/.local/bin"
}
```

#### 1.3 Claude Code Launch and Verification

```bash
launch_claude_code() {
    log "Launching Claude Code..."

    # Verify installation
    if ! command -v claude &> /dev/null; then
        error "Claude Code not found after installation"
        return 1
    fi

    # Launch Claude Code in background
    claude --daemon &
    local claude_pid=$!

    # Wait for startup
    wait_for_claude_startup

    # Verify session
    verify_claude_session

    return 0
}

wait_for_claude_startup() {
    local timeout=60
    local elapsed=0

    while [ $elapsed -lt $timeout ]; do
        if claude status &> /dev/null; then
            log "✅ Claude Code is running"
            return 0
        fi
        sleep 2
        ((elapsed += 2))
    done

    error "Claude Code failed to start within ${timeout}s"
    return 1
}
```

#### 1.4 Authentication Checkpoint

```bash
verify_authentication_checkpoint() {
    log "Verifying Claude Code authentication..."

    # Check if authenticated
    if ! claude auth status &> /dev/null; then
        show_authentication_instructions
        wait_for_authentication
    fi

    # Verify Pro/Max plan
    verify_subscription_tier

    log "✅ Authentication verified"
}

show_authentication_instructions() {
    echo "🔐 Claude Code Authentication Required"
    echo "================================="
    echo ""
    echo "Please complete authentication in Claude Code:"
    echo "1. Claude Code should have opened automatically"
    echo "2. Sign in with your Anthropic account"
    echo "3. Ensure you have a Pro or Max subscription plan"
    echo "4. Press ENTER when authentication is complete"
    echo ""
    read -p "Press ENTER to continue..."
}

verify_subscription_tier() {
    local tier=$(claude auth status --format json | jq -r '.subscription.tier')

    case "$tier" in
        "pro"|"max")
            log "✅ Subscription tier: $tier"
            ;;
        *)
            warn "⚠️ Pro or Max subscription recommended for best performance"
            echo "Current tier: $tier"
            echo "Consider upgrading for access to Claude Code's full capabilities"
            ;;
    esac
}
```

## Stage 2: HiveStudio Installation (Inside Claude Code)

### Purpose
- Leverage Claude Code's intelligence for complex installation tasks
- Handle errors intelligently
- Configure MCP servers
- Set up HiveStudio components
- Validate complete setup

### Implementation Details

#### 2.1 Stage 2 Entry Command

Create a simple command that users run WITHIN Claude Code:

```bash
# Command user runs in Claude Code
hivestudio-install
```

This maps to: `scripts/stage2-hivestudio-install.sh`

#### 2.2 Claude Code Intelligence Integration

```bash
#!/bin/bash
# scripts/stage2-hivestudio-install.sh
# This runs INSIDE Claude Code and leverages Claude's intelligence

# Claude Code can:
# 1. Analyze errors intelligently
# 2. Suggest fixes automatically
# 3. Handle complex dependency resolution
# 4. Provide contextual help
# 5. Recover from failures gracefully

install_with_claude_intelligence() {
    log "🧠 Using Claude Code intelligence for installation..."

    # Let Claude Code handle complex MCP server setup
    claude_install_mcp_servers

    # Let Claude Code configure integrations
    claude_configure_integrations

    # Let Claude Code validate setup
    claude_validate_configuration
}

claude_install_mcp_servers() {
    log "Installing MCP servers with Claude intelligence..."

    # Claude Code can automatically:
    # - Detect network issues and retry
    # - Handle version conflicts
    # - Suggest alternative installation methods
    # - Fix permission issues
    # - Resolve dependency conflicts

    local mcp_servers=(
        "claude-flow:npx claude-flow@alpha mcp start"
        "ruv-swarm:npx ruv-swarm mcp start"
        "flow-nexus:npx flow-nexus@latest mcp start"
    )

    for server_config in "${mcp_servers[@]}"; do
        local name="${server_config%%:*}"
        local command="${server_config#*:}"

        install_mcp_server_with_intelligence "$name" "$command"
    done
}

install_mcp_server_with_intelligence() {
    local name=$1
    local command=$2

    log "Installing MCP server: $name"

    # Try installation
    if ! claude mcp add "$name" "$command"; then
        # Let Claude Code analyze the error and suggest fixes
        handle_mcp_installation_error "$name" "$command"
    fi
}

handle_mcp_installation_error() {
    local name=$1
    local command=$2

    # Claude Code can intelligently:
    # - Analyze the specific error
    # - Suggest fixes (permission, network, version issues)
    # - Try alternative installation methods
    # - Provide contextual help

    log "⚠️ Installation failed for $name, analyzing with Claude intelligence..."

    # Claude Code provides intelligent error analysis
    claude analyze-error "MCP server installation failed: $name with command: $command"

    # Claude Code can suggest and try fixes automatically
    claude suggest-fix "mcp-installation-error" "$name" "$command"
}
```

#### 2.3 Error Handling Strategy

```bash
# Error handling that leverages Claude Code's intelligence
handle_installation_error() {
    local component=$1
    local error_details=$2

    # Claude Code can:
    # 1. Analyze error logs intelligently
    # 2. Search for solutions in its knowledge base
    # 3. Suggest specific fixes for the user's environment
    # 4. Provide step-by-step recovery instructions
    # 5. Learn from successful resolutions

    log "🔍 Claude Code analyzing error for: $component"

    # Pass error to Claude Code for intelligent analysis
    claude error-analysis \
        --component "$component" \
        --error "$error_details" \
        --environment "$(get_environment_info)" \
        --suggest-fixes
}

get_environment_info() {
    # Gather comprehensive environment info for Claude Code
    cat << EOF
{
    "os": "$(uname -s)",
    "version": "$(uname -r)",
    "architecture": "$(uname -m)",
    "node_version": "$(node --version 2>/dev/null || echo 'not_found')",
    "npm_version": "$(npm --version 2>/dev/null || echo 'not_found')",
    "shell": "$SHELL",
    "codespaces": "${CODESPACES:-false}",
    "git_version": "$(git --version 2>/dev/null || echo 'not_found')"
}
EOF
}
```

## Seamless Handoff Mechanism

### 3.1 Stage 1 to Stage 2 Transition

```bash
# At the end of Stage 1
complete_stage1_handoff() {
    log "✅ Stage 1 completed successfully"
    log "🚀 Ready for Stage 2 - HiveStudio installation"

    # Create handoff file with environment info
    create_handoff_file

    # Show Stage 2 instructions
    show_stage2_instructions

    # Open Claude Code if not already open
    ensure_claude_code_open
}

create_handoff_file() {
    cat > .hivestudio-stage1-complete << EOF
{
    "stage1_completed": true,
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "claude_code_version": "$(claude --version)",
    "system_info": $(get_environment_info),
    "next_step": "Run 'hivestudio-install' inside Claude Code"
}
EOF
}

show_stage2_instructions() {
    echo ""
    echo "🎉 Stage 1 Complete - System Ready!"
    echo "=================================="
    echo ""
    echo "Claude Code is now running and authenticated."
    echo ""
    echo "📝 NEXT STEP - Inside Claude Code:"
    echo "   1. Claude Code should be open"
    echo "   2. Run this command in Claude Code:"
    echo ""
    echo "      hivestudio-install"
    echo ""
    echo "   3. Claude Code will handle the complex installation intelligently"
    echo ""
    echo "✨ Claude Code will:"
    echo "   • Install MCP servers automatically"
    echo "   • Handle any errors intelligently"
    echo "   • Configure all integrations"
    echo "   • Validate the complete setup"
    echo ""
}
```

### 3.2 Stage 2 Entry Validation

```bash
# At the start of Stage 2 (inside Claude Code)
validate_stage2_entry() {
    # Verify Stage 1 was completed
    if [ ! -f ".hivestudio-stage1-complete" ]; then
        error "Stage 1 not completed. Please run the system preparation script first."
        exit 1
    fi

    # Verify Claude Code environment
    if [ -z "$CLAUDE_CODE_SESSION" ]; then
        error "Not running inside Claude Code. Please run this command in Claude Code."
        exit 1
    fi

    # Load Stage 1 handoff data
    load_stage1_handoff_data

    log "✅ Stage 2 entry validated"
}

load_stage1_handoff_data() {
    local handoff_data=$(cat .hivestudio-stage1-complete)
    export STAGE1_COMPLETION_TIME=$(echo "$handoff_data" | jq -r '.timestamp')
    export SYSTEM_INFO=$(echo "$handoff_data" | jq -r '.system_info')

    log "Loaded Stage 1 handoff data from: $STAGE1_COMPLETION_TIME"
}
```

## Modified Script Structure

### 4.1 New Script Organization

```
scripts/
├── stage1-system-preparation.sh      # NEW: Runs outside Claude Code
├── stage2-hivestudio-install.sh      # NEW: Runs inside Claude Code
├── dependency-checker.sh             # ENHANCED: Comprehensive validation
├── claude-code-installer.sh          # NEW: Claude Code installation
├── authentication-checkpoint.sh      # NEW: Auth verification
├── validation-suite.sh               # ENHANCED: Complete validation
└── install-ecosystem.sh              # MODIFIED: Now calls stage1 script
```

### 4.2 User Journey

```bash
# User runs this outside Claude Code
./install-ecosystem.sh

# Which internally:
# 1. Runs Stage 1 preparation
# 2. Launches Claude Code
# 3. Instructs user to run Stage 2 command inside Claude Code

# User then runs inside Claude Code:
hivestudio-install

# Which leverages Claude Code's intelligence for complex tasks
```

### 4.3 Modified install-ecosystem.sh

```bash
#!/bin/bash
# Modified install-ecosystem.sh - Now orchestrates two-stage installation

echo "🚀 HiveStudio Two-Stage Installation"
echo "===================================="

# Stage 1: System preparation (outside Claude Code)
log "Starting Stage 1: System Preparation"
if ! ./scripts/stage1-system-preparation.sh; then
    error "Stage 1 failed. Please check the errors above."
    exit 1
fi

log "✅ Stage 1 completed successfully"
log "📋 Please follow the instructions above to complete Stage 2 inside Claude Code"
```

## Benefits of This Approach

### 5.1 Leverages Claude Code's Strengths
- **Intelligent error analysis**: Claude Code can understand and suggest fixes for complex errors
- **Contextual help**: Provides specific guidance based on the user's environment
- **Adaptive installation**: Can try multiple approaches based on what works
- **Learning capability**: Improves over time based on successful installations

### 5.2 Robust Foundation
- **Comprehensive validation**: Stage 1 ensures all prerequisites are met
- **Clean separation**: Clear responsibilities between stages
- **Graceful degradation**: Can handle partial failures intelligently
- **User guidance**: Clear instructions at each step

### 5.3 Error Recovery
- **Stage 1 errors**: Traditional bash error handling with clear instructions
- **Stage 2 errors**: Claude Code's intelligence for complex problem-solving
- **Partial failures**: Can resume from where it left off
- **Learning from failures**: Claude Code improves its approach over time

## Implementation Priority

1. **Phase 1**: Create Stage 1 system preparation script
2. **Phase 2**: Modify existing install-ecosystem.sh to call Stage 1
3. **Phase 3**: Create Stage 2 script with Claude Code integration
4. **Phase 4**: Test on different platforms and environments
5. **Phase 5**: Add comprehensive error handling and recovery

This approach maximizes success by using the right tool for each stage: robust system-level validation outside Claude Code, and intelligent complex installation inside Claude Code.