# Optimal Stage 1 Implementation Design for HiveStudio

## Executive Summary

Based on analysis of the existing HiveStudio codebase, this document provides a comprehensive design for an optimal Stage 1 implementation that adopts the best components from the current installer architecture while creating a lean, focused prerequisite validation and Claude Code installation phase.

## 1. Component Identification Matrix

### 🔴 ADOPT VERBATIM (Critical Improvements)

#### From `/scripts/stage1-system-preparation.sh` (Lines 75-98)
**check_requirement() function** - Robust dependency validation with version checking
```bash
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
```

#### From `/install/main-installer.sh` (Lines 392-430)
**install_dependencies() with retry logic** - Resilient package installation
```bash
install_dependencies() {
    info "Installing project dependencies..."

    # Ensure package.json exists
    if [ ! -f "package.json" ]; then
        warn "package.json not found, creating minimal version"
        create_minimal_package_json
    fi

    # Install dependencies with retry
    if retry_package_install "npm install" "npm dependencies"; then
        return 0
    else
        error "Failed to install npm dependencies"
        return 1
    fi
}
```

#### From `/turbo-start.sh` (Lines 130-146)
**Multiple installation methods with fallbacks** - Smart Claude CLI installation
```bash
# Try npm installation with timeout
if timeout 60 npm install -g @anthropic-ai/claude-code &>/dev/null; then
    success "Claude CLI installed via npm"
    return 0
fi

# Fallback to curl if npm fails
warn "npm installation timeout, trying curl method..."
if curl -fsSL https://claude.ai/install.sh | sh &>/dev/null; then
    export PATH="$PATH:$HOME/.local/bin"
    success "Claude CLI installed via curl"
    return 0
fi
```

### 🟡 MODIFY FOR HIVESTUDIO (Contextual Adaptations)

#### From `/install/main-installer.sh` (Lines 186-220)
**Environment detection** - Adapt for HiveStudio context
- Change project name references
- Add HiveStudio-specific environment variables
- Customize for Claude Code integration focus

#### From `/scripts/stage1-system-preparation.sh` (Lines 526-549)
**Handoff file creation** - Modify for Stage 1/Stage 2 handoff
```bash
create_handoff_file() {
    log "Creating handoff file for Stage 2..."

    cat > .hivestudio-stage1-complete << EOF
{
    "stage1_completed": true,
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "claude_code_version": "$(claude --version 2>/dev/null || echo 'unknown')",
    # ... HiveStudio-specific metadata
}
EOF
}
```

### 🔵 SKIP ENTIRELY (Unnecessary for Stage 1)

- MCP server installation (belongs in Stage 2)
- Project structure creation (belongs in Stage 2)
- Team template creation (belongs in Stage 2)
- Configuration file generation (belongs in Stage 2)
- Workflow setup (belongs in Stage 2)

## 2. Stage 1 Script Architecture Design

### Core Philosophy
- **Single Responsibility**: Only handle prerequisites and Claude Code installation
- **Fail Fast**: Stop immediately on critical failures
- **User Guidance**: Provide clear next steps for Stage 2
- **Intelligent Handoff**: Create comprehensive environment data for Stage 2

### Architecture Components

```
Stage 1 Script Architecture
├── Prerequisites Validation
│   ├── System Requirements Check
│   ├── Platform-Specific Validation
│   ├── Network Connectivity Test
│   └── Permission Verification
├── Claude Code Installation
│   ├── Installation Strategy Selection
│   ├── Multiple Method Attempts
│   ├── PATH Configuration
│   └── Verification
├── Authentication Checkpoint
│   ├── Launch Claude Code
│   ├── Wait for Authentication
│   ├── Subscription Verification
│   └── Status Validation
└── Stage 2 Preparation
    ├── Environment Data Collection
    ├── Handoff File Creation
    ├── Stage 2 Instructions
    └── Access Verification
```

## 3. Exact Code Templates with Line References

### Template 1: Main Entry Point (ADOPT from stage1-system-preparation.sh:601-642)

```bash
#!/bin/bash
# HiveStudio Stage 1: Prerequisites and Claude Code Setup
# Optimized implementation adopting best practices from existing codebase

set -e

# === ADOPT VERBATIM: Logging functions (Lines 17-31) ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }

# === ADOPT VERBATIM: Error tracking (Lines 34-39) ===
ERRORS=0
version_less_than() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$1" ] && [ "$1" != "$2" ]
}

main() {
    echo "🚀 HiveStudio Stage 1: System Preparation"
    echo "========================================="

    # Execute core Stage 1 functions
    validate_system_prerequisites || exit 1
    install_claude_code || exit 1
    launch_claude_code || exit 1
    verify_authentication_checkpoint || exit 1
    complete_stage1_handoff

    echo -e "${GREEN}🎉 Stage 1 completed successfully!${NC}"
}
```

### Template 2: Prerequisites Validation (ADOPT from stage1-system-preparation.sh:42-73)

```bash
validate_system_prerequisites() {
    log "🔍 Validating system prerequisites..."

    # === ADOPT VERBATIM: Core requirements check ===
    check_requirement "Node.js" "node --version" "18.0.0"
    check_requirement "npm" "npm --version" "8.0.0"
    check_requirement "Git" "git --version" "2.0.0"
    check_requirement "curl" "curl --version" "7.0.0"

    # === ADOPT MODIFIED: Platform detection (Lines 125-151) ===
    detect_platform_specific_requirements

    # === ADOPT VERBATIM: Network/disk/permissions (Lines 164-223) ===
    validate_network_connectivity
    validate_disk_space
    validate_permissions

    if [ $ERRORS -gt 0 ]; then
        error "❌ $ERRORS prerequisite checks failed"
        show_installation_help
        return 1
    fi

    log "✅ All prerequisites validated successfully"
}
```

### Template 3: Claude Code Installation (ADOPT from turbo-start.sh:119-147 + main-installer.sh:451-498)

```bash
install_claude_code() {
    log "🚀 Installing Claude Code application..."

    # === ADOPT VERBATIM: Check existing installation ===
    if command -v claude &> /dev/null; then
        local version=$(claude --version 2>/dev/null || echo "unknown")
        log "✅ Claude Code already installed: $version"
        return 0
    fi

    # === ADOPT VERBATIM: Multiple strategies with fallbacks ===
    local install_methods=("npm_global" "homebrew" "curl_direct")

    for method in "${install_methods[@]}"; do
        info "Trying installation method: $method"
        if attempt_installation_$method; then
            log "✅ Claude Code installed via $method"
            return 0
        fi
    done

    error "❌ Failed to install Claude Code via all methods"
    show_manual_installation_guide
    return 1
}
```

### Template 4: Authentication Checkpoint (ADOPT from stage1-system-preparation.sh:418-510)

```bash
verify_authentication_checkpoint() {
    log "🔐 Verifying Claude Code authentication..."

    if claude auth status &> /dev/null; then
        log "✅ Already authenticated"
        return 0
    fi

    show_authentication_instructions

    # === ADOPT VERBATIM: Authentication waiting logic ===
    local timeout=300
    local elapsed=0

    while [ $elapsed -lt $timeout ]; do
        if claude auth status &> /dev/null; then
            log "✅ Authentication successful!"
            return 0
        fi
        sleep 5
        ((elapsed += 5))

        if [ $((elapsed % 30)) -eq 0 ]; then
            info "Still waiting for authentication... (${elapsed}s/${timeout}s)"
        fi
    done

    error "❌ Authentication timeout after ${timeout}s"
    return 1
}
```

## 4. Implementation Priority Framework

### 🔴 MUST-HAVE (Critical for Stage 1 Success)
1. **Prerequisites validation with error counting** (stage1-system-preparation.sh:75-98)
2. **Multiple Claude Code installation methods** (turbo-start.sh:130-146)
3. **Authentication checkpoint with timeout** (stage1-system-preparation.sh:452-485)
4. **Comprehensive handoff file creation** (stage1-system-preparation.sh:526-549)

### 🟡 NICE-TO-HAVE (Enhanced User Experience)
1. **Platform-specific guidance** (stage1-system-preparation.sh:125-151)
2. **Network connectivity validation** (stage1-system-preparation.sh:164-180)
3. **Subscription tier verification** (stage1-system-preparation.sh:487-510)
4. **Enhanced error messages with solutions** (stage1-system-preparation.sh:100-123)

### 🔵 SKIP FOR STAGE 1 (Belongs in Stage 2)
1. MCP server installation
2. Project structure creation
3. Package.json generation
4. Team templates
5. Workflow configuration

## 5. Integration Points with Stage 2

### Handoff Data Structure
```json
{
    "stage1_completed": true,
    "timestamp": "2024-01-15T10:30:00Z",
    "claude_code_version": "1.2.3",
    "system_info": {
        "os": "Darwin",
        "node_version": "v18.17.0",
        "npm_version": "9.6.7",
        "shell": "/bin/zsh",
        "codespaces": "false"
    },
    "installation_methods": {
        "claude_code": "npm_global",
        "retry_count": 1
    },
    "authentication": {
        "verified": true,
        "subscription_tier": "pro"
    },
    "next_step": "Run Stage 2 inside Claude Code"
}
```

### Stage 2 Trigger Command
```bash
# Inside Claude Code:
./scripts/stage2-hivestudio-install.sh

# OR simplified alias:
hivestudio-install
```

## 6. Key Improvements from Existing Code

### Performance Optimizations
- **Parallel validation checks** where possible
- **Timeout mechanisms** for network operations
- **Circuit breaker pattern** for failed installations
- **Cached dependency checks** to avoid redundant operations

### Error Handling Enhancements
- **Comprehensive error context** collection
- **Specific recovery guidance** per error type
- **Graceful degradation** for optional components
- **User-friendly error messages** with actionable solutions

### User Experience Improvements
- **Progress indicators** with percentage completion
- **Clear separation** between stages
- **Intelligent guidance** for different environments
- **Comprehensive validation** before proceeding

## 7. Final Implementation Recommendation

### Stage 1 Script Structure (350-400 lines)
```
stage1-system-preparation.sh
├── Header & Setup (50 lines)
├── Prerequisites Validation (100 lines)
├── Claude Code Installation (100 lines)
├── Authentication Checkpoint (75 lines)
└── Stage 2 Handoff (75 lines)
```

### Core Functions to Implement
1. `validate_system_prerequisites()` - ADOPT from existing with HiveStudio context
2. `install_claude_code()` - ADOPT multi-method approach from turbo-start.sh
3. `verify_authentication_checkpoint()` - ADOPT timeout logic from stage1-system-preparation.sh
4. `complete_stage1_handoff()` - MODIFY handoff structure for HiveStudio

### Success Criteria
- ✅ All prerequisites validated
- ✅ Claude Code installed and running
- ✅ Authentication verified
- ✅ Comprehensive handoff data created
- ✅ Clear Stage 2 instructions provided
- ✅ Stop execution - no complex installation in Stage 1

This design provides a lean, focused Stage 1 that leverages the best practices from the existing codebase while maintaining clear separation of concerns between prerequisite setup and complex installation tasks.