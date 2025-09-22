# Stage 1 to Stage 2 Handoff Specification

This document defines the handoff mechanism between Stage 1 (System Preparation) and Stage 2 (Intelligent Installation) of the HiveStudio installation process.

## Overview

The handoff mechanism ensures seamless transition from basic system preparation to intelligent, AI-assisted installation. Stage 1 creates structured data that Stage 2 consumes to make informed decisions about the installation process.

## Handoff File Structure

### Primary Handoff File: `.hivestudio-stage1-complete`

This JSON file contains all essential information for Stage 2 to proceed with intelligent installation.

```json
{
    "stage1_completed": true,
    "timestamp": "2024-01-15T14:30:00Z",
    "claude_code_version": "1.2.3",
    "system_info": {
        "os": "Darwin",
        "version": "23.1.0",
        "architecture": "arm64",
        "node_version": "v20.10.0",
        "npm_version": "10.2.3",
        "shell": "/bin/zsh",
        "codespaces": "false",
        "git_version": "git version 2.42.0"
    },
    "next_step": "Run 'hivestudio-install' inside Claude Code"
}
```

### Data Structure Specification

#### Root Level Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `stage1_completed` | boolean | ✅ | Indicates successful Stage 1 completion |
| `timestamp` | string | ✅ | ISO 8601 timestamp of completion |
| `claude_code_version` | string | ✅ | Installed Claude Code version |
| `system_info` | object | ✅ | Comprehensive system information |
| `next_step` | string | ✅ | Human-readable next step instruction |

#### System Information Object

| Property | Type | Description | Example Values |
|----------|------|-------------|----------------|
| `os` | string | Operating system name | `"Darwin"`, `"Linux"`, `"MINGW64_NT"` |
| `version` | string | OS version/kernel | `"23.1.0"`, `"5.15.0-91-generic"` |
| `architecture` | string | CPU architecture | `"arm64"`, `"x86_64"`, `"x64"` |
| `node_version` | string | Node.js version | `"v20.10.0"`, `"not_found"` |
| `npm_version` | string | npm version | `"10.2.3"`, `"not_found"` |
| `shell` | string | User's shell | `"/bin/zsh"`, `"/bin/bash"` |
| `codespaces` | string | GitHub Codespaces flag | `"true"`, `"false"` |
| `git_version` | string | Git version string | `"git version 2.42.0"` |

## Environment Variables Set by Stage 1

### Standard Environment Variables

Stage 1 sets these environment variables for Stage 2 consumption:

```bash
# System Information
export STAGE1_COMPLETION_TIME="2024-01-15T14:30:00Z"
export SYSTEM_OS="Darwin"  # or "Linux", "Windows"
export HIVESTUDIO_STAGE="1_COMPLETE"

# Installation Context
export CLAUDE_CODE_AVAILABLE="true"
export CLAUDE_AUTHENTICATED="true"
export INSTALLATION_METHOD="two_stage"

# Platform-Specific Flags
export CODESPACES="${CODESPACES:-false}"
export MACOS_TOOLS_AVAILABLE="true"  # macOS only
export WSL_ENVIRONMENT="false"       # Windows only
```

### Dynamic Environment Variables

These variables are set based on detection results:

```bash
# Tool Availability (true/false)
export NODE_AVAILABLE="true"
export NPM_AVAILABLE="true"
export GIT_AVAILABLE="true"
export CURL_AVAILABLE="true"

# Version Information
export NODE_VERSION="v20.10.0"
export NPM_VERSION="10.2.3"
export GIT_VERSION="2.42.0"

# Network Connectivity (true/false)
export GITHUB_ACCESSIBLE="true"
export NPM_REGISTRY_ACCESSIBLE="true"
export CLAUDE_AI_ACCESSIBLE="true"
```

## Files Created by Stage 1

### Primary Files

1. **`.hivestudio-stage1-complete`** (Required)
   - Main handoff data file
   - JSON format
   - Contains all essential system information

2. **`.hivestudio-install-context`** (Optional)
   - Extended context for complex installations
   - Contains environment-specific optimizations

### Temporary Files (Cleaned Up)

1. **`.hivestudio-temp-test`**
   - Used for permission testing
   - Automatically removed after test

2. **`.hivestudio-download-*`**
   - Temporary download files
   - Cleaned up on completion or failure

### Log Files (If Created)

1. **`.hivestudio-stage1.log`**
   - Detailed installation log
   - Created only if logging is enabled
   - Useful for debugging issues

## How Stage 2 Reads Handoff Data

### Entry Point Validation

Stage 2 first validates the handoff data:

```bash
# Check for handoff file
if [ ! -f ".hivestudio-stage1-complete" ]; then
    error "Stage 1 not completed - handoff file missing"
    exit 1
fi

# Validate file format
if ! jq empty .hivestudio-stage1-complete 2>/dev/null; then
    error "Invalid handoff file format"
    exit 1
fi
```

### Data Extraction Methods

#### Method 1: Environment Variable Loading
```bash
# Load Stage 1 handoff data into environment
load_stage1_handoff_data() {
    if [ -f ".hivestudio-stage1-complete" ]; then
        local handoff_data=$(cat .hivestudio-stage1-complete)

        # Extract using basic parsing (jq-free)
        export STAGE1_COMPLETION_TIME=$(echo "$handoff_data" | grep '"timestamp"' | cut -d'"' -f4)
        export SYSTEM_OS=$(echo "$handoff_data" | grep '"os"' | cut -d'"' -f4)
        export CLAUDE_VERSION=$(echo "$handoff_data" | grep '"claude_code_version"' | cut -d'"' -f4)

        log "Loaded Stage 1 handoff data from: $STAGE1_COMPLETION_TIME"
    fi
}
```

#### Method 2: Direct JSON Parsing (if jq available)
```bash
# Advanced parsing with jq
load_handoff_with_jq() {
    local handoff_file=".hivestudio-stage1-complete"

    if command -v jq &> /dev/null && [ -f "$handoff_file" ]; then
        export STAGE1_COMPLETION_TIME=$(jq -r '.timestamp' "$handoff_file")
        export SYSTEM_OS=$(jq -r '.system_info.os' "$handoff_file")
        export NODE_VERSION=$(jq -r '.system_info.node_version' "$handoff_file")
        export CODESPACES_ENV=$(jq -r '.system_info.codespaces' "$handoff_file")
    fi
}
```

### Intelligent Decision Making

Stage 2 uses handoff data for intelligent decisions:

```bash
# Platform-specific optimization
optimize_for_platform() {
    case "$SYSTEM_OS" in
        "Darwin")
            claude_log "Optimizing for macOS environment"
            use_homebrew_when_available=true
            ;;
        "Linux")
            if [ "$CODESPACES_ENV" = "true" ]; then
                claude_log "Optimizing for GitHub Codespaces"
                skip_dev_tools_check=true
            fi
            ;;
    esac
}

# Installation strategy selection
select_installation_strategy() {
    local node_major=$(echo "$NODE_VERSION" | cut -d'.' -f1 | sed 's/v//')

    if [ "$node_major" -ge 20 ]; then
        claude_log "Using modern Node.js installation strategy"
        enable_esm_modules=true
    else
        claude_log "Using legacy Node.js compatibility mode"
        enable_esm_modules=false
    fi
}
```

## Error Handling and Recovery

### Handoff File Corruption

```bash
# Validate and recover from corruption
validate_handoff_file() {
    local handoff_file=".hivestudio-stage1-complete"

    if [ ! -f "$handoff_file" ]; then
        error "Handoff file missing - Stage 1 may not have completed"
        return 1
    fi

    # Test JSON validity
    if ! python3 -m json.tool "$handoff_file" >/dev/null 2>&1; then
        warn "Handoff file corrupted - attempting recovery"
        attempt_handoff_recovery
        return $?
    fi

    return 0
}

attempt_handoff_recovery() {
    # Try to reconstruct basic handoff data
    cat > .hivestudio-stage1-complete << EOF
{
    "stage1_completed": true,
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "claude_code_version": "$(claude --version 2>/dev/null || echo 'unknown')",
    "system_info": {
        "os": "$(uname -s)",
        "version": "$(uname -r)",
        "architecture": "$(uname -m)",
        "node_version": "$(node --version 2>/dev/null || echo 'unknown')",
        "npm_version": "$(npm --version 2>/dev/null || echo 'unknown')",
        "shell": "$SHELL",
        "codespaces": "${CODESPACES:-false}",
        "git_version": "$(git --version 2>/dev/null || echo 'unknown')"
    },
    "next_step": "Continue with Stage 2 (recovered data)"
}
EOF

    warn "Handoff file reconstructed from current system state"
    return 0
}
```

### Missing Environment Variables

```bash
# Provide defaults for missing environment variables
set_handoff_defaults() {
    # System defaults
    export SYSTEM_OS="${SYSTEM_OS:-$(uname -s)}"
    export STAGE1_COMPLETION_TIME="${STAGE1_COMPLETION_TIME:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"

    # Tool availability defaults (conservative)
    export NODE_AVAILABLE="${NODE_AVAILABLE:-$(command -v node >/dev/null && echo 'true' || echo 'false')}"
    export NPM_AVAILABLE="${NPM_AVAILABLE:-$(command -v npm >/dev/null && echo 'true' || echo 'false')}"
    export GIT_AVAILABLE="${GIT_AVAILABLE:-$(command -v git >/dev/null && echo 'true' || echo 'false')}"

    # Network defaults (assume available)
    export GITHUB_ACCESSIBLE="${GITHUB_ACCESSIBLE:-true}"
    export NPM_REGISTRY_ACCESSIBLE="${NPM_REGISTRY_ACCESSIBLE:-true}"
}
```

## Data Validation Schema

### JSON Schema for Handoff File

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "required": [
        "stage1_completed",
        "timestamp",
        "claude_code_version",
        "system_info",
        "next_step"
    ],
    "properties": {
        "stage1_completed": {
            "type": "boolean",
            "const": true
        },
        "timestamp": {
            "type": "string",
            "format": "date-time"
        },
        "claude_code_version": {
            "type": "string",
            "pattern": "^[0-9]+\\.[0-9]+\\.[0-9]+.*$|unknown"
        },
        "system_info": {
            "type": "object",
            "required": [
                "os",
                "version",
                "architecture",
                "node_version",
                "npm_version",
                "shell",
                "codespaces",
                "git_version"
            ],
            "properties": {
                "os": {
                    "type": "string",
                    "enum": ["Darwin", "Linux", "MINGW64_NT", "CYGWIN_NT", "Windows"]
                },
                "version": {
                    "type": "string"
                },
                "architecture": {
                    "type": "string",
                    "enum": ["x86_64", "arm64", "x64", "i386", "aarch64"]
                },
                "node_version": {
                    "type": "string"
                },
                "npm_version": {
                    "type": "string"
                },
                "shell": {
                    "type": "string"
                },
                "codespaces": {
                    "type": "string",
                    "enum": ["true", "false"]
                },
                "git_version": {
                    "type": "string"
                }
            }
        },
        "next_step": {
            "type": "string",
            "minLength": 1
        }
    },
    "additionalProperties": false
}
```

### Validation Implementation

```bash
# Validate handoff data against schema
validate_handoff_schema() {
    local handoff_file=".hivestudio-stage1-complete"

    # Basic structure validation
    local required_fields=("stage1_completed" "timestamp" "claude_code_version" "system_info")

    for field in "${required_fields[@]}"; do
        if ! grep -q "\"$field\"" "$handoff_file"; then
            error "Missing required field: $field"
            return 1
        fi
    done

    # Validate stage1_completed is true
    if ! grep -q '"stage1_completed": *true' "$handoff_file"; then
        error "Stage 1 not marked as completed"
        return 1
    fi

    log "Handoff file validation passed"
    return 0
}
```

## Integration Examples

### Stage 2 Entry Point
```bash
# Stage 2 main function showing handoff integration
main() {
    log "Stage 2: Intelligent Installation with Claude Code"

    # 1. Validate Stage 2 entry conditions
    validate_stage2_entry || exit 1

    # 2. Load handoff data
    load_stage1_handoff_data

    # 3. Set defaults for missing data
    set_handoff_defaults

    # 4. Use handoff data for intelligent decisions
    optimize_for_platform
    select_installation_strategy

    # 5. Proceed with intelligent installation
    install_with_claude_intelligence
}
```

### Context-Aware Installation
```bash
# Use handoff data for context-aware decisions
intelligent_mcp_installation() {
    claude_log "Using Stage 1 handoff data for intelligent MCP installation"

    # Platform-specific optimization
    if [ "$SYSTEM_OS" = "Darwin" ] && [ "$NPM_AVAILABLE" = "true" ]; then
        claude_log "Optimizing for macOS with npm"
        use_npm_global_strategy=true
    elif [ "$CODESPACES_ENV" = "true" ]; then
        claude_log "Optimizing for GitHub Codespaces environment"
        use_local_installation=true
    fi

    # Network-aware installation
    if [ "$NPM_REGISTRY_ACCESSIBLE" = "false" ]; then
        claude_log "NPM registry not accessible - using alternative sources"
        enable_fallback_sources=true
    fi

    # Proceed with optimized installation
    execute_optimized_mcp_installation
}
```

## Handoff Data Lifecycle

### Creation (Stage 1)
1. System information gathering
2. Environment variable collection
3. JSON structure creation
4. File writing with atomic operation
5. Verification of written data

### Consumption (Stage 2)
1. File existence verification
2. Format validation
3. Data extraction and parsing
4. Environment variable setting
5. Context-aware decision making

### Cleanup (Post-Installation)
1. Archive handoff data for debugging
2. Remove temporary files
3. Create completion markers
4. Generate final report

## Security Considerations

### Data Sanitization
- No sensitive information stored in handoff files
- Path information validated for safety
- Environment variables filtered for security

### File Permissions
- Handoff files created with restrictive permissions
- Temporary files properly secured
- Cleanup ensures no data leakage

### Validation
- All input data validated against schema
- Malicious content detection and filtering
- Safe parsing methods used throughout

---

This specification ensures reliable, secure, and intelligent handoff between Stage 1 and Stage 2 of the HiveStudio installation process.