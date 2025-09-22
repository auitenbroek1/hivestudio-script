#!/bin/bash

# HiveStudio Installation Validation Script
# Comprehensive validation and health checking for HiveStudio installation

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source validation utilities if available
if [ -f "$PROJECT_ROOT/install/utils/logger.sh" ]; then
    source "$PROJECT_ROOT/install/utils/logger.sh"
    source "$PROJECT_ROOT/install/utils/validate.sh"
else
    # Fallback logging functions
    info() { echo "[INFO] $1"; }
    warn() { echo "[WARN] $1" >&2; }
    error() { echo "[ERROR] $1" >&2; }
    success() { echo "[SUCCESS] $1"; }
fi

# Validation categories
declare -a VALIDATION_CATEGORIES=(
    "system"
    "dependencies"
    "structure"
    "configuration"
    "tools"
    "functionality"
)

# Results tracking
declare -A VALIDATION_RESULTS=()
declare TOTAL_CHECKS=0
declare PASSED_CHECKS=0
declare FAILED_CHECKS=0
declare WARNING_CHECKS=0

# Main validation function
main() {
    echo "🔍 HiveStudio Installation Validation"
    echo "======================================"
    echo ""

    # Process arguments
    local quick_mode=false
    local verbose_mode=false
    local category=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --quick|-q)
                quick_mode=true
                shift
                ;;
            --verbose|-v)
                verbose_mode=true
                shift
                ;;
            --category|-c)
                category="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                warn "Unknown option: $1"
                shift
                ;;
        esac
    done

    # Set verbose logging if requested
    if [ "$verbose_mode" = true ]; then
        export HIVESTUDIO_LOG_LEVEL=0
    fi

    # Run validations
    if [ "$quick_mode" = true ]; then
        run_quick_validation
    elif [ -n "$category" ]; then
        run_category_validation "$category"
    else
        run_full_validation
    fi

    # Generate report
    generate_validation_report

    # Exit with appropriate code
    if [ $FAILED_CHECKS -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Show help
show_help() {
    cat << EOF
HiveStudio Installation Validation

Usage: $0 [OPTIONS]

Options:
    --quick, -q         Run quick validation (essential checks only)
    --verbose, -v       Enable verbose output
    --category, -c CAT  Run specific category validation
    --help, -h          Show this help message

Categories:
    system             System requirements and environment
    dependencies       Node.js, npm, and package dependencies
    structure          Project structure and files
    configuration      Configuration files and settings
    tools              Claude CLI and MCP servers
    functionality      Functional tests

Examples:
    $0                 # Full validation
    $0 --quick         # Quick validation
    $0 -c system       # System validation only
    $0 --verbose       # Verbose validation

EOF
}

# Run quick validation
run_quick_validation() {
    info "Running quick validation..."

    validate_essential_commands
    validate_basic_structure
    validate_package_json

    info "Quick validation completed"
}

# Run category validation
run_category_validation() {
    local category="$1"

    info "Running validation for category: $category"

    case "$category" in
        "system")
            validate_system_requirements
            ;;
        "dependencies")
            validate_dependencies
            ;;
        "structure")
            validate_project_structure
            ;;
        "configuration")
            validate_configuration_files
            ;;
        "tools")
            validate_tools_installation
            ;;
        "functionality")
            validate_functionality
            ;;
        *)
            error "Unknown validation category: $category"
            exit 1
            ;;
    esac
}

# Run full validation
run_full_validation() {
    info "Running full validation..."

    for category in "${VALIDATION_CATEGORIES[@]}"; do
        echo ""
        info "=== Validating: $category ==="
        run_category_validation "$category"
    done

    info "Full validation completed"
}

# Validate essential commands
validate_essential_commands() {
    info "Checking essential commands..."

    check_command_with_version "node" "18" "Node.js"
    check_command_with_version "npm" "8" "npm"
    check_command_simple "git" "Git"
}

# Validate system requirements
validate_system_requirements() {
    info "Validating system requirements..."

    # Operating system
    record_check "os" "success" "Operating system: $(uname -s) $(uname -r)"

    # Architecture
    record_check "arch" "success" "Architecture: $(uname -m)"

    # Memory
    check_memory_requirements

    # Disk space
    check_disk_space_requirements

    # Network connectivity
    check_network_connectivity
}

# Validate dependencies
validate_dependencies() {
    info "Validating dependencies..."

    # Node.js version
    check_command_with_version "node" "18" "Node.js"

    # npm version
    check_command_with_version "npm" "8" "npm"

    # Package dependencies
    validate_package_dependencies

    # Global packages
    check_global_packages
}

# Validate project structure
validate_project_structure() {
    info "Validating project structure..."

    local required_dirs=("src" "tests" "docs" "config" "scripts")
    local optional_dirs=("examples" ".claude" "install")

    # Check required directories
    for dir in "${required_dirs[@]}"; do
        if [ -d "$dir" ]; then
            record_check "dir_$dir" "success" "Directory exists: $dir"
        else
            record_check "dir_$dir" "warning" "Missing directory: $dir"
        fi
    done

    # Check optional directories
    for dir in "${optional_dirs[@]}"; do
        if [ -d "$dir" ]; then
            record_check "opt_dir_$dir" "success" "Optional directory exists: $dir"
        else
            record_check "opt_dir_$dir" "info" "Optional directory missing: $dir"
        fi
    done

    # Check important files
    check_important_files
}

# Validate configuration files
validate_configuration_files() {
    info "Validating configuration files..."

    # package.json
    if [ -f "package.json" ]; then
        if validate_json_file "package.json"; then
            record_check "package_json" "success" "package.json is valid"
            check_package_json_content
        else
            record_check "package_json" "error" "package.json is invalid JSON"
        fi
    else
        record_check "package_json" "error" "package.json not found"
    fi

    # .gitignore
    if [ -f ".gitignore" ]; then
        record_check "gitignore" "success" ".gitignore exists"
    else
        record_check "gitignore" "warning" ".gitignore not found"
    fi

    # Environment files
    check_environment_files
}

# Validate tools installation
validate_tools_installation() {
    info "Validating tools installation..."

    # Claude CLI
    check_claude_cli_installation

    # MCP servers
    check_mcp_servers_installation

    # Development tools
    check_development_tools
}

# Validate functionality
validate_functionality() {
    info "Validating functionality..."

    # npm functionality
    test_npm_functionality

    # Claude functionality
    test_claude_functionality

    # Project functionality
    test_project_functionality
}

# Helper functions

check_command_with_version() {
    local cmd="$1"
    local min_version="$2"
    local name="$3"

    if command -v "$cmd" &> /dev/null; then
        local version
        case "$cmd" in
            "node")
                version=$(node --version | sed 's/v//' | cut -d'.' -f1)
                ;;
            "npm")
                version=$(npm --version | cut -d'.' -f1)
                ;;
            *)
                version="unknown"
                ;;
        esac

        if [ "$version" != "unknown" ] && [ "$version" -ge "$min_version" ]; then
            record_check "$cmd" "success" "$name version $version (>= $min_version)"
        else
            record_check "$cmd" "error" "$name version $version (< $min_version required)"
        fi
    else
        record_check "$cmd" "error" "$name not found"
    fi
}

check_command_simple() {
    local cmd="$1"
    local name="$2"

    if command -v "$cmd" &> /dev/null; then
        local version
        version=$($cmd --version 2>/dev/null | head -1 || echo "installed")
        record_check "$cmd" "success" "$name found ($version)"
    else
        record_check "$cmd" "error" "$name not found"
    fi
}

check_memory_requirements() {
    local min_memory_mb=2048
    local total_memory_mb

    if [[ "$OSTYPE" == "darwin"* ]]; then
        total_memory_mb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024)}' || echo 0)
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        total_memory_mb=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print int($2/1024)}' || echo 0)
    else
        total_memory_mb=0
    fi

    if [ "$total_memory_mb" -ge "$min_memory_mb" ]; then
        record_check "memory" "success" "Memory: ${total_memory_mb}MB (>= ${min_memory_mb}MB)"
    elif [ "$total_memory_mb" -gt 0 ]; then
        record_check "memory" "warning" "Memory: ${total_memory_mb}MB (< ${min_memory_mb}MB recommended)"
    else
        record_check "memory" "info" "Memory: Unable to determine"
    fi
}

check_disk_space_requirements() {
    local min_space_mb=1000

    if command -v df &> /dev/null; then
        local available_mb
        if [[ "$OSTYPE" == "darwin"* ]]; then
            available_mb=$(df -m . | tail -1 | awk '{print $4}')
        else
            available_mb=$(df -m . | tail -1 | awk '{print $4}')
        fi

        if [ "$available_mb" -ge "$min_space_mb" ]; then
            record_check "disk_space" "success" "Disk space: ${available_mb}MB (>= ${min_space_mb}MB)"
        else
            record_check "disk_space" "warning" "Disk space: ${available_mb}MB (< ${min_space_mb}MB recommended)"
        fi
    else
        record_check "disk_space" "info" "Disk space: Unable to determine"
    fi
}

check_network_connectivity() {
    if curl -s --connect-timeout 10 https://www.npmjs.com > /dev/null; then
        record_check "network" "success" "Network connectivity verified"
    else
        record_check "network" "warning" "Network connectivity issues detected"
    fi
}

validate_package_dependencies() {
    if [ -f "package.json" ]; then
        if npm list --depth=0 > /dev/null 2>&1; then
            record_check "npm_deps" "success" "Package dependencies satisfied"
        else
            record_check "npm_deps" "warning" "Package dependency issues detected"
        fi
    else
        record_check "npm_deps" "info" "No package.json to validate"
    fi
}

check_global_packages() {
    local global_packages=("@anthropic-ai/claude-code")

    for package in "${global_packages[@]}"; do
        if npm list -g "$package" > /dev/null 2>&1; then
            record_check "global_$package" "success" "Global package installed: $package"
        else
            record_check "global_$package" "info" "Global package not installed: $package"
        fi
    done
}

check_important_files() {
    local important_files=("README.md" "CLAUDE.md" ".gitignore")

    for file in "${important_files[@]}"; do
        if [ -f "$file" ]; then
            record_check "file_$file" "success" "Important file exists: $file"
        else
            record_check "file_$file" "warning" "Important file missing: $file"
        fi
    done
}

validate_json_file() {
    local file="$1"

    if python3 -m json.tool "$file" > /dev/null 2>&1; then
        return 0
    elif node -e "JSON.parse(require('fs').readFileSync('$file', 'utf8'))" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

check_package_json_content() {
    # Check for essential fields
    if command -v node &> /dev/null; then
        local has_name has_version has_scripts

        has_name=$(node -e "console.log(!!require('./package.json').name)" 2>/dev/null || echo false)
        has_version=$(node -e "console.log(!!require('./package.json').version)" 2>/dev/null || echo false)
        has_scripts=$(node -e "console.log(!!require('./package.json').scripts)" 2>/dev/null || echo false)

        if [ "$has_name" = "true" ]; then
            record_check "pkg_name" "success" "package.json has name field"
        else
            record_check "pkg_name" "warning" "package.json missing name field"
        fi

        if [ "$has_version" = "true" ]; then
            record_check "pkg_version" "success" "package.json has version field"
        else
            record_check "pkg_version" "warning" "package.json missing version field"
        fi

        if [ "$has_scripts" = "true" ]; then
            record_check "pkg_scripts" "success" "package.json has scripts section"
        else
            record_check "pkg_scripts" "warning" "package.json missing scripts section"
        fi
    fi
}

check_environment_files() {
    if [ -f ".env" ]; then
        record_check "env_file" "success" ".env file exists"
    else
        record_check "env_file" "info" ".env file not found (may be optional)"
    fi

    if [ -f ".env.example" ]; then
        record_check "env_example" "success" ".env.example exists"
    else
        record_check "env_example" "info" ".env.example not found"
    fi
}

check_claude_cli_installation() {
    if command -v claude &> /dev/null; then
        local version
        version=$(claude --version 2>/dev/null || echo "unknown")
        record_check "claude_cli" "success" "Claude CLI installed ($version)"

        # Test basic functionality
        if claude --help > /dev/null 2>&1; then
            record_check "claude_help" "success" "Claude CLI help command works"
        else
            record_check "claude_help" "warning" "Claude CLI help command failed"
        fi
    else
        record_check "claude_cli" "info" "Claude CLI not installed (optional)"
    fi
}

check_mcp_servers_installation() {
    if command -v claude &> /dev/null; then
        if claude mcp list > /dev/null 2>&1; then
            local mcp_count
            mcp_count=$(claude mcp list 2>/dev/null | wc -l)
            record_check "mcp_servers" "success" "MCP servers configured ($mcp_count found)"
        else
            record_check "mcp_servers" "info" "No MCP servers configured"
        fi
    else
        record_check "mcp_servers" "info" "Cannot check MCP servers (Claude CLI not available)"
    fi
}

check_development_tools() {
    local dev_tools=("code" "vim" "nano")

    for tool in "${dev_tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            record_check "dev_tool_$tool" "success" "Development tool available: $tool"
            break
        fi
    done
}

test_npm_functionality() {
    if command -v npm &> /dev/null; then
        if npm --version > /dev/null 2>&1; then
            record_check "npm_func" "success" "npm basic functionality works"
        else
            record_check "npm_func" "error" "npm basic functionality failed"
        fi
    else
        record_check "npm_func" "error" "npm not available for testing"
    fi
}

test_claude_functionality() {
    if command -v claude &> /dev/null; then
        if claude --version > /dev/null 2>&1; then
            record_check "claude_func" "success" "Claude CLI basic functionality works"
        else
            record_check "claude_func" "warning" "Claude CLI basic functionality failed"
        fi
    else
        record_check "claude_func" "info" "Claude CLI not available for testing"
    fi
}

test_project_functionality() {
    # Test if we can run npm scripts
    if [ -f "package.json" ] && command -v npm &> /dev/null; then
        if npm run --silent 2>/dev/null | grep -q "available"; then
            record_check "project_scripts" "success" "Project scripts available"
        else
            record_check "project_scripts" "info" "No npm scripts defined or npm run failed"
        fi
    else
        record_check "project_scripts" "info" "Cannot test project scripts"
    fi
}

# Record validation result
record_check() {
    local key="$1"
    local status="$2"
    local message="$3"

    VALIDATION_RESULTS["$key"]="$status:$message"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    case "$status" in
        "success")
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
            success "$message"
            ;;
        "warning")
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
            warn "$message"
            ;;
        "error")
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            error "$message"
            ;;
        "info")
            info "$message"
            ;;
    esac
}

# Generate validation report
generate_validation_report() {
    echo ""
    echo "======================================"
    echo "🔍 Validation Report"
    echo "======================================"
    echo ""
    echo "Summary:"
    echo "  Total Checks: $TOTAL_CHECKS"
    echo "  Passed: $PASSED_CHECKS"
    echo "  Warnings: $WARNING_CHECKS"
    echo "  Failed: $FAILED_CHECKS"
    echo ""

    if [ $FAILED_CHECKS -eq 0 ] && [ $WARNING_CHECKS -eq 0 ]; then
        success "✅ All validations passed!"
        echo ""
        echo "Your HiveStudio installation is ready for use."
    elif [ $FAILED_CHECKS -eq 0 ]; then
        warn "⚠️ Validation completed with warnings"
        echo ""
        echo "Your installation is functional but some optional components"
        echo "may not be available or configured optimally."
    else
        error "❌ Validation failed with $FAILED_CHECKS critical issues"
        echo ""
        echo "Please resolve the failed checks before using HiveStudio."
        echo "Run with --verbose for detailed error information."
    fi

    echo ""
    echo "Next steps:"
    if [ $FAILED_CHECKS -eq 0 ]; then
        echo "• Run 'npm start' to begin development"
        echo "• Check 'docs/' for usage guides"
        echo "• Configure .env file with your API keys"
    else
        echo "• Fix the failed validation checks"
        echo "• Re-run validation: $0"
        echo "• Check installation logs for details"
    fi
    echo ""
}

# Run main function
main "$@"