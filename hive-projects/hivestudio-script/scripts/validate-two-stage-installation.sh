#!/bin/bash

# Two-Stage Installation Validation Script
# Validates the complete two-stage installation process

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

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

validate_log() {
    echo -e "${PURPLE}[VALIDATE] $1${NC}"
}

echo "🔍 HiveStudio Two-Stage Installation Validation"
echo "==============================================="
echo ""

# Global validation counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Validation helper function
validate_check() {
    local description=$1
    local check_command=$2
    local required=${3:-true}

    ((TOTAL_CHECKS++))
    validate_log "Checking: $description"

    if eval "$check_command" &> /dev/null; then
        log "✅ PASS: $description"
        ((PASSED_CHECKS++))
        return 0
    else
        if [ "$required" = "true" ]; then
            error "❌ FAIL: $description"
            ((FAILED_CHECKS++))
        else
            warn "⚠️ WARN: $description (optional)"
            ((WARNING_CHECKS++))
        fi
        return 1
    fi
}

# Stage 1 Validation: System Prerequisites
validate_stage1_prerequisites() {
    log "🔧 Validating Stage 1 Prerequisites..."

    validate_check "Node.js installed" "command -v node"
    validate_check "npm installed" "command -v npm"
    validate_check "Git installed" "command -v git"
    validate_check "curl installed" "command -v curl"

    # Version checks
    if command -v node &> /dev/null; then
        local node_version=$(node --version | sed 's/v//')
        local min_node="18.0.0"
        if dpkg --compare-versions "$node_version" "ge" "$min_node" 2>/dev/null || [ "$(printf '%s\n' "$min_node" "$node_version" | sort -V | head -n1)" = "$min_node" ]; then
            log "✅ Node.js version $node_version meets requirement (>= $min_node)"
        else
            warn "⚠️ Node.js version $node_version below recommended $min_node"
        fi
    fi

    # Network connectivity
    validate_check "GitHub connectivity" "curl -s --connect-timeout 5 https://github.com"
    validate_check "npm registry connectivity" "curl -s --connect-timeout 5 https://registry.npmjs.org"
    validate_check "Claude.ai connectivity" "curl -s --connect-timeout 5 https://claude.ai" "false"

    echo ""
    log "Stage 1 Prerequisites validation completed"
}

# Validate Stage 1 Scripts
validate_stage1_scripts() {
    log "📝 Validating Stage 1 Scripts..."

    validate_check "Stage 1 script exists" "[ -f 'scripts/stage1-system-preparation.sh' ]"
    validate_check "Stage 1 script executable" "[ -x 'scripts/stage1-system-preparation.sh' ]"
    validate_check "Main installer exists" "[ -f 'install-ecosystem.sh' ]"
    validate_check "Main installer executable" "[ -x 'install-ecosystem.sh' ]"

    # Validate script syntax
    if [ -f "scripts/stage1-system-preparation.sh" ]; then
        validate_check "Stage 1 script syntax" "bash -n scripts/stage1-system-preparation.sh"
    fi

    if [ -f "install-ecosystem.sh" ]; then
        validate_check "Main installer syntax" "bash -n install-ecosystem.sh"
    fi

    echo ""
    log "Stage 1 Scripts validation completed"
}

# Validate Stage 2 Scripts
validate_stage2_scripts() {
    log "🧠 Validating Stage 2 Scripts..."

    validate_check "Stage 2 script exists" "[ -f 'scripts/stage2-hivestudio-install.sh' ]"
    validate_check "Stage 2 script executable" "[ -x 'scripts/stage2-hivestudio-install.sh' ]"
    validate_check "hivestudio-install command exists" "[ -f 'hivestudio-install' ]" "false"

    # Validate script syntax
    if [ -f "scripts/stage2-hivestudio-install.sh" ]; then
        validate_check "Stage 2 script syntax" "bash -n scripts/stage2-hivestudio-install.sh"
    fi

    echo ""
    log "Stage 2 Scripts validation completed"
}

# Validate Project Structure
validate_project_structure() {
    log "📁 Validating Project Structure..."

    # Essential directories
    local required_dirs=("scripts" "docs")
    for dir in "${required_dirs[@]}"; do
        validate_check "Directory exists: $dir" "[ -d '$dir' ]"
    done

    # Optional directories (will be created during installation)
    local optional_dirs=("src" "tests" "config" "examples")
    for dir in "${optional_dirs[@]}"; do
        validate_check "Directory exists: $dir" "[ -d '$dir' ]" "false"
    done

    # Essential files
    validate_check "Package.json exists" "[ -f 'package.json' ]"
    validate_check "README exists" "[ -f 'README.md' ]"
    validate_check "Claude configuration exists" "[ -f 'CLAUDE.md' ]"

    echo ""
    log "Project Structure validation completed"
}

# Validate Claude Code Integration
validate_claude_code_integration() {
    log "🤖 Validating Claude Code Integration..."

    # Check if Claude CLI is available
    validate_check "Claude CLI available" "command -v claude" "false"

    if command -v claude &> /dev/null; then
        validate_check "Claude CLI responds" "claude --version" "false"
        validate_check "Claude status check" "claude status" "false"
        validate_check "Claude auth status" "claude auth status" "false"
        validate_check "Claude MCP capability" "claude mcp --help" "false"
    else
        info "ℹ️ Claude CLI not installed - will be installed in Stage 1"
    fi

    echo ""
    log "Claude Code Integration validation completed"
}

# Validate Installation Logic
validate_installation_logic() {
    log "🔧 Validating Installation Logic..."

    # Check for critical functions in Stage 1 script
    if [ -f "scripts/stage1-system-preparation.sh" ]; then
        validate_check "Stage 1 has prerequisite validation" "grep -q 'validate_system_prerequisites' scripts/stage1-system-preparation.sh"
        validate_check "Stage 1 has Claude installation" "grep -q 'install_claude_code' scripts/stage1-system-preparation.sh"
        validate_check "Stage 1 has authentication check" "grep -q 'verify_authentication_checkpoint' scripts/stage1-system-preparation.sh"
        validate_check "Stage 1 has handoff mechanism" "grep -q 'complete_stage1_handoff' scripts/stage1-system-preparation.sh"
    fi

    # Check for critical functions in Stage 2 script
    if [ -f "scripts/stage2-hivestudio-install.sh" ]; then
        validate_check "Stage 2 has entry validation" "grep -q 'validate_stage2_entry' scripts/stage2-hivestudio-install.sh"
        validate_check "Stage 2 has intelligent installation" "grep -q 'install_with_claude_intelligence' scripts/stage2-hivestudio-install.sh"
        validate_check "Stage 2 has MCP server setup" "grep -q 'install_mcp_servers_with_intelligence' scripts/stage2-hivestudio-install.sh"
        validate_check "Stage 2 has validation suite" "grep -q 'validate_installation_with_intelligence' scripts/stage2-hivestudio-install.sh"
    fi

    echo ""
    log "Installation Logic validation completed"
}

# Validate Error Handling
validate_error_handling() {
    log "🛡️ Validating Error Handling..."

    # Check for error handling patterns in scripts
    local scripts=("scripts/stage1-system-preparation.sh" "scripts/stage2-hivestudio-install.sh" "install-ecosystem.sh")

    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            local script_name=$(basename "$script")
            validate_check "$script_name has error handling" "grep -q 'set -e' '$script'"
            validate_check "$script_name has error logging" "grep -q 'error()' '$script'"
            validate_check "$script_name has warning handling" "grep -q 'warn()' '$script'"
        fi
    done

    # Check for intelligent error handling in Stage 2
    if [ -f "scripts/stage2-hivestudio-install.sh" ]; then
        validate_check "Stage 2 has intelligent error recovery" "grep -q 'handle_mcp_installation_error' scripts/stage2-hivestudio-install.sh"
        validate_check "Stage 2 has graceful degradation" "grep -q 'prepare_graceful_degradation' scripts/stage2-hivestudio-install.sh"
    fi

    echo ""
    log "Error Handling validation completed"
}

# Test Installation Scripts (Dry Run)
test_installation_scripts() {
    log "🧪 Testing Installation Scripts (Dry Run)..."

    # Test Stage 1 script functions
    if [ -f "scripts/stage1-system-preparation.sh" ]; then
        info "Testing Stage 1 script structure..."

        # Source the script to test function definitions
        if bash -n scripts/stage1-system-preparation.sh; then
            log "✅ Stage 1 script syntax is valid"
        else
            error "❌ Stage 1 script has syntax errors"
        fi
    fi

    # Test Stage 2 script functions
    if [ -f "scripts/stage2-hivestudio-install.sh" ]; then
        info "Testing Stage 2 script structure..."

        # Source the script to test function definitions
        if bash -n scripts/stage2-hivestudio-install.sh; then
            log "✅ Stage 2 script syntax is valid"
        else
            error "❌ Stage 2 script has syntax errors"
        fi
    fi

    # Test main installer
    if [ -f "install-ecosystem.sh" ]; then
        info "Testing main installer structure..."

        if bash -n install-ecosystem.sh; then
            log "✅ Main installer syntax is valid"
        else
            error "❌ Main installer has syntax errors"
        fi
    fi

    echo ""
    log "Installation Scripts testing completed"
}

# Validate Platform Compatibility
validate_platform_compatibility() {
    log "🌐 Validating Platform Compatibility..."

    local platform=$(uname -s)
    info "Detected platform: $platform"

    case "$platform" in
        "Darwin")
            log "✅ macOS platform detected"
            validate_check "macOS dev tools available" "xcode-select -p" "false"
            ;;
        "Linux")
            log "✅ Linux platform detected"
            if [ -n "$CODESPACES" ]; then
                log "✅ GitHub Codespaces environment detected"
            fi
            ;;
        "MINGW"*|"CYGWIN"*|"MSYS"*)
            warn "⚠️ Windows environment detected - limited support"
            ;;
        *)
            warn "⚠️ Unknown platform: $platform"
            ;;
    esac

    echo ""
    log "Platform Compatibility validation completed"
}

# Generate Validation Report
generate_validation_report() {
    log "📊 Generating Validation Report..."

    local report_file="validation-report-$(date +%Y%m%d-%H%M%S).json"

    cat > "$report_file" << EOF
{
    "validation_report": {
        "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "version": "1.0.0",
        "platform": "$(uname -s)",
        "summary": {
            "total_checks": $TOTAL_CHECKS,
            "passed": $PASSED_CHECKS,
            "failed": $FAILED_CHECKS,
            "warnings": $WARNING_CHECKS,
            "success_rate": "$(( PASSED_CHECKS * 100 / TOTAL_CHECKS ))%"
        },
        "system_info": {
            "os": "$(uname -s)",
            "architecture": "$(uname -m)",
            "node_version": "$(node --version 2>/dev/null || echo 'not_installed')",
            "npm_version": "$(npm --version 2>/dev/null || echo 'not_installed')",
            "git_version": "$(git --version 2>/dev/null || echo 'not_installed')",
            "claude_available": $(command -v claude &> /dev/null && echo "true" || echo "false")
        },
        "validation_categories": {
            "stage1_prerequisites": "completed",
            "stage1_scripts": "completed",
            "stage2_scripts": "completed",
            "project_structure": "completed",
            "claude_integration": "completed",
            "installation_logic": "completed",
            "error_handling": "completed",
            "platform_compatibility": "completed"
        },
        "recommendations": [
            $([ $FAILED_CHECKS -gt 0 ] && echo '"Fix failed validation checks before installation",' || echo '')
            $([ $WARNING_CHECKS -gt 0 ] && echo '"Review warnings for optimal setup",' || echo '')
            "Run Stage 1 installation first: ./install-ecosystem.sh",
            "Follow Stage 2 instructions inside Claude Code",
            "Monitor installation progress and logs"
        ]
    }
}
EOF

    log "✅ Validation report generated: $report_file"
    return "$report_file"
}

# Main validation execution
main() {
    echo "Starting comprehensive validation of two-stage installation..."
    echo ""

    # Run all validation categories
    validate_stage1_prerequisites
    validate_stage1_scripts
    validate_stage2_scripts
    validate_project_structure
    validate_claude_code_integration
    validate_installation_logic
    validate_error_handling
    test_installation_scripts
    validate_platform_compatibility

    # Generate report
    local report_file=$(generate_validation_report)

    echo ""
    echo "🎉 Validation Summary"
    echo "===================="
    echo ""
    echo -e "Total Checks: ${BLUE}$TOTAL_CHECKS${NC}"
    echo -e "✅ Passed: ${GREEN}$PASSED_CHECKS${NC}"
    echo -e "❌ Failed: ${RED}$FAILED_CHECKS${NC}"
    echo -e "⚠️ Warnings: ${YELLOW}$WARNING_CHECKS${NC}"
    echo ""

    local success_rate=$(( PASSED_CHECKS * 100 / TOTAL_CHECKS ))
    echo -e "Success Rate: ${GREEN}${success_rate}%${NC}"

    echo ""
    if [ $FAILED_CHECKS -eq 0 ]; then
        log "🎉 All critical checks passed! Installation should succeed."
        echo ""
        echo "Next steps:"
        echo "1. Run: ./install-ecosystem.sh (Stage 1)"
        echo "2. Follow instructions to run Stage 2 inside Claude Code"
        echo "3. Enjoy intelligent development with HiveStudio!"
    else
        error "❌ $FAILED_CHECKS critical checks failed. Please fix these issues before installation."
        echo ""
        echo "Review the errors above and ensure all prerequisites are met."
    fi

    echo ""
    echo "📊 Detailed report: $report_file"
    echo ""
}

# Run validation
main "$@"