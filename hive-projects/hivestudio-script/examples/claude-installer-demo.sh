#!/bin/bash

# Claude Code Installer Demonstration
# Shows the various features and fallback strategies of the installation module

set -euo pipefail

# Get script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly INSTALLER_PATH="$PROJECT_ROOT/stage1/lib/claude-installer.sh"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Demo logging
demo_log() {
    local level="$1"
    shift
    local message="$*"

    case "$level" in
        INFO)
            echo -e "${BLUE}[DEMO] $message${NC}"
            ;;
        SUCCESS)
            echo -e "${GREEN}[DEMO] $message${NC}"
            ;;
        WARN)
            echo -e "${YELLOW}[DEMO] $message${NC}"
            ;;
        ERROR)
            echo -e "${RED}[DEMO] $message${NC}"
            ;;
        *)
            echo "[DEMO] $message"
            ;;
    esac
}

# Load installer module
load_installer() {
    demo_log "INFO" "Loading Claude Code installer module..."

    if [[ -f "$INSTALLER_PATH" ]]; then
        source "$INSTALLER_PATH"
        demo_log "SUCCESS" "Installer module loaded successfully"
        return 0
    else
        demo_log "ERROR" "Installer module not found at $INSTALLER_PATH"
        return 1
    fi
}

# Demo platform detection
demo_platform_detection() {
    demo_log "INFO" "Demonstrating platform detection..."

    local platform
    if platform=$(detect_platform 2>/dev/null); then
        demo_log "SUCCESS" "Detected platform: $platform"

        # Show details
        echo
        echo "Platform Details:"
        echo "  Operating System: $(uname -s)"
        echo "  Architecture: $(uname -m)"
        echo "  Normalized: $platform"
        echo
    else
        demo_log "ERROR" "Platform detection failed"
        return 1
    fi
}

# Demo retry logic
demo_retry_logic() {
    demo_log "INFO" "Demonstrating retry logic with exponential backoff..."

    # Create a function that fails twice then succeeds
    local attempt_count=0
    demo_failing_command() {
        ((attempt_count++))
        demo_log "INFO" "Command attempt #$attempt_count"

        if [[ $attempt_count -lt 3 ]]; then
            demo_log "WARN" "Command failed (simulated)"
            return 1
        else
            demo_log "SUCCESS" "Command succeeded"
            return 0
        fi
    }

    echo
    demo_log "INFO" "Testing retry with max 3 attempts, starting with 1s delay..."

    if retry_with_backoff 3 1 demo_failing_command; then
        demo_log "SUCCESS" "Retry logic worked correctly (succeeded after $attempt_count attempts)"
    else
        demo_log "ERROR" "Retry logic failed"
        return 1
    fi
    echo
}

# Demo download function (mock)
demo_download_function() {
    demo_log "INFO" "Demonstrating secure download with checksum verification..."

    # Create temporary directory for demo
    local temp_dir
    temp_dir=$(mktemp -d)

    # Create a test file
    local test_content="This is a test file for download demonstration"
    local source_file="$temp_dir/source.txt"
    local dest_file="$temp_dir/downloaded.txt"

    echo "$test_content" > "$source_file"

    # Calculate checksum
    local checksum
    if command -v shasum >/dev/null 2>&1; then
        checksum=$(echo -n "$test_content" | shasum -a 256 | cut -d' ' -f1)
    elif command -v sha256sum >/dev/null 2>&1; then
        checksum=$(echo -n "$test_content" | sha256sum | cut -d' ' -f1)
    else
        demo_log "WARN" "No checksum utility available for demo"
        rm -rf "$temp_dir"
        return 0
    fi

    echo
    demo_log "INFO" "Source file created with content: '$test_content'"
    demo_log "INFO" "Expected checksum: $checksum"

    # Demo the download with verification
    if secure_download "file://$source_file" "$dest_file" "$checksum"; then
        if [[ -f "$dest_file" && "$(cat "$dest_file")" == "$test_content" ]]; then
            demo_log "SUCCESS" "Download and verification completed successfully"
        else
            demo_log "ERROR" "Download succeeded but content verification failed"
        fi
    else
        demo_log "ERROR" "Download failed"
    fi

    # Cleanup
    rm -rf "$temp_dir"
    echo
}

# Demo installation methods overview
demo_installation_methods() {
    demo_log "INFO" "Installation methods available (in priority order):"

    echo
    echo "1. Direct Download (platform-specific binaries)"
    echo "   - Downloads latest release from GitHub"
    echo "   - Platform detection: $(detect_platform 2>/dev/null || echo 'unknown')"
    echo "   - Verifies checksums when available"
    echo

    echo "2. NPM Global Installation"
    if command -v npm >/dev/null 2>&1; then
        echo "   - npm is available: ✓"
        echo "   - npm version: $(npm --version 2>/dev/null || echo 'unknown')"
    else
        echo "   - npm is not available: ✗"
    fi
    echo

    echo "3. Homebrew (macOS only)"
    if [[ "$(uname -s)" == "Darwin" ]]; then
        if command -v brew >/dev/null 2>&1; then
            echo "   - macOS detected: ✓"
            echo "   - Homebrew available: ✓"
            echo "   - brew version: $(brew --version 2>/dev/null | head -1 || echo 'unknown')"
        else
            echo "   - macOS detected: ✓"
            echo "   - Homebrew available: ✗"
        fi
    else
        echo "   - Not macOS: ✗"
    fi
    echo

    echo "4. Package Managers (Linux)"
    if [[ "$(uname -s)" == "Linux" ]]; then
        echo "   - Linux detected: ✓"
        if command -v apt-get >/dev/null 2>&1; then
            echo "   - apt-get available: ✓"
        elif command -v yum >/dev/null 2>&1; then
            echo "   - yum available: ✓"
        elif command -v dnf >/dev/null 2>&1; then
            echo "   - dnf available: ✓"
        else
            echo "   - No supported package manager found: ✗"
        fi
    else
        echo "   - Not Linux: ✗"
    fi
    echo

    echo "5. Manual Installation"
    echo "   - Always available as final fallback"
    echo "   - Provides step-by-step instructions"
    echo
}

# Demo security features
demo_security_features() {
    demo_log "INFO" "Security features demonstration..."

    echo
    echo "Security Features:"
    echo "  ✓ Checksum verification (SHA-256)"
    echo "  ✓ Signature validation (when available)"
    echo "  ✓ Secure temporary file handling"
    echo "  ✓ Platform validation"
    echo "  ✓ Download timeout protection"
    echo "  ✓ Retry limits to prevent infinite loops"
    echo

    # Test with a wrong checksum
    local temp_dir
    temp_dir=$(mktemp -d)
    local test_file="$temp_dir/test.txt"
    echo "test content" > "$test_file"

    demo_log "INFO" "Testing checksum verification with wrong checksum..."

    # This should fail
    if secure_download "file://$test_file" "$temp_dir/output" "wrong_checksum" 2>/dev/null; then
        demo_log "ERROR" "Security check failed - should have rejected wrong checksum"
    else
        demo_log "SUCCESS" "Security check correctly rejected wrong checksum"
    fi

    rm -rf "$temp_dir"
    echo
}

# Demo configuration and logging
demo_configuration() {
    demo_log "INFO" "Configuration and logging features..."

    echo
    echo "Configuration:"
    echo "  • Install directory: ${CLAUDE_INSTALL_DIR:-/usr/local/bin}"
    echo "  • Config directory: ${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
    echo "  • Log file: ${LOG_FILE:-$HOME/.claude/install.log}"
    echo "  • Temp directory: ${TEMP_DIR:-$(mktemp -d)}"
    echo

    echo "Logging Features:"
    echo "  ✓ Timestamped log entries"
    echo "  ✓ Multiple log levels (INFO, WARN, ERROR, SUCCESS)"
    echo "  ✓ Colored console output"
    echo "  ✓ Persistent log file"
    echo "  ✓ Installation metrics tracking"
    echo
}

# Main demo function
main() {
    echo
    demo_log "INFO" "Claude Code Installer Module Demonstration"
    echo "=================================================="
    echo

    # Load the installer module
    if ! load_installer; then
        demo_log "ERROR" "Failed to load installer module"
        exit 1
    fi

    echo
    echo "Running demonstrations..."
    echo

    # Run individual demos
    demo_platform_detection
    demo_retry_logic
    demo_download_function
    demo_installation_methods
    demo_security_features
    demo_configuration

    echo
    demo_log "SUCCESS" "All demonstrations completed successfully!"
    echo
    demo_log "INFO" "To actually install Claude Code, run:"
    demo_log "INFO" "  source $INSTALLER_PATH && install_claude_code"
    echo
    demo_log "INFO" "Or run the installer directly:"
    demo_log "INFO" "  $INSTALLER_PATH"
    echo
}

# Run demo if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi