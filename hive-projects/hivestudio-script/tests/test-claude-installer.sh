#!/bin/bash

# Test Suite for Claude Code Installation Module
# Tests all installation methods, fallback strategies, and security features

set -euo pipefail

# Test configuration
readonly TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$TEST_DIR")"
readonly INSTALLER_PATH="$PROJECT_ROOT/stage1/lib/claude-installer.sh"
readonly TEST_LOG="/tmp/claude-installer-test.log"

# Color codes for test output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test logging
test_log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$timestamp] [$level] $message" >> "$TEST_LOG"

    case "$level" in
        FAIL)
            echo -e "${RED}✗ $message${NC}"
            ((TESTS_FAILED++))
            ;;
        PASS)
            echo -e "${GREEN}✓ $message${NC}"
            ((TESTS_PASSED++))
            ;;
        INFO)
            echo -e "${BLUE}ℹ $message${NC}"
            ;;
        WARN)
            echo -e "${YELLOW}⚠ $message${NC}"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Test helper functions
run_test() {
    local test_name="$1"
    local test_function="$2"

    ((TESTS_RUN++))
    test_log "INFO" "Running test: $test_name"

    if $test_function; then
        test_log "PASS" "$test_name"
        return 0
    else
        test_log "FAIL" "$test_name"
        return 1
    fi
}

# Setup test environment
setup_test_env() {
    test_log "INFO" "Setting up test environment..."

    # Create temporary directory for tests
    export TEST_TEMP_DIR=$(mktemp -d)
    export CLAUDE_CONFIG_DIR="$TEST_TEMP_DIR/.claude"
    export CLAUDE_INSTALL_DIR="$TEST_TEMP_DIR/bin"

    mkdir -p "$CLAUDE_INSTALL_DIR"
    mkdir -p "$CLAUDE_CONFIG_DIR"

    # Source the installer for testing
    if [[ -f "$INSTALLER_PATH" ]]; then
        # Temporarily disable strict error handling for sourcing
        set +e
        source "$INSTALLER_PATH"
        local source_result=$?
        set -e

        if [[ $source_result -eq 0 ]]; then
            test_log "PASS" "Installer module loaded successfully"
            return 0
        else
            test_log "FAIL" "Installer module failed to load (exit code: $source_result)"
            return 1
        fi
    else
        test_log "FAIL" "Installer module not found at $INSTALLER_PATH"
        return 1
    fi
}

# Cleanup test environment
cleanup_test_env() {
    test_log "INFO" "Cleaning up test environment..."

    if [[ -n "${TEST_TEMP_DIR:-}" && -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Test 1: Platform Detection
test_platform_detection() {
    test_log "INFO" "Testing platform detection..."

    local platform
    if platform=$(detect_platform); then
        test_log "INFO" "Detected platform: $platform"

        # Validate platform format
        if [[ "$platform" =~ ^(darwin|linux|windows)-(amd64|arm64|386|arm)$ ]]; then
            return 0
        else
            test_log "FAIL" "Invalid platform format: $platform"
            return 1
        fi
    else
        test_log "FAIL" "Platform detection failed"
        return 1
    fi
}

# Test 2: Retry Logic
test_retry_logic() {
    test_log "INFO" "Testing retry logic with exponential backoff..."

    # Test command that fails twice then succeeds
    local attempt_count=0
    test_command() {
        ((attempt_count++))
        if [[ $attempt_count -lt 3 ]]; then
            return 1  # Fail first two attempts
        else
            return 0  # Succeed on third attempt
        fi
    }

    if retry_with_backoff 3 1 test_command; then
        if [[ $attempt_count -eq 3 ]]; then
            return 0
        else
            test_log "FAIL" "Retry logic didn't attempt correct number of times: $attempt_count"
            return 1
        fi
    else
        test_log "FAIL" "Retry logic failed when it should have succeeded"
        return 1
    fi
}

# Test 3: Download Function (Mock)
test_download_function() {
    test_log "INFO" "Testing secure download function..."

    # Create a mock file to "download"
    local test_content="test file content"
    local test_file="$TEST_TEMP_DIR/test_download"
    local mock_url="file://$TEST_TEMP_DIR/mock_source"

    # Create mock source file
    echo "$test_content" > "${mock_url#file://}"

    # Test download without checksum
    if secure_download "$mock_url" "$test_file"; then
        if [[ -f "$test_file" && "$(cat "$test_file")" == "$test_content" ]]; then
            test_log "INFO" "Download without checksum verification passed"
        else
            test_log "FAIL" "Downloaded file content doesn't match"
            return 1
        fi
    else
        test_log "FAIL" "Download function failed"
        return 1
    fi

    # Test download with correct checksum
    local checksum
    if command -v sha256sum >/dev/null 2>&1; then
        checksum=$(echo -n "$test_content" | sha256sum | cut -d' ' -f1)
    elif command -v shasum >/dev/null 2>&1; then
        checksum=$(echo -n "$test_content" | shasum -a 256 | cut -d' ' -f1)
    else
        test_log "WARN" "No checksum utility available, skipping checksum test"
        return 0
    fi

    rm -f "$test_file"
    echo "$test_content" > "${mock_url#file://}"

    if secure_download "$mock_url" "$test_file" "$checksum"; then
        test_log "INFO" "Download with correct checksum passed"
        return 0
    else
        test_log "FAIL" "Download with checksum verification failed"
        return 1
    fi
}

# Test 4: Installation Method Priority
test_installation_priority() {
    test_log "INFO" "Testing installation method priority..."

    # Mock installation methods to test priority
    install_direct_download() { test_log "INFO" "Direct download attempted"; return 1; }
    install_npm_global() { test_log "INFO" "NPM global attempted"; return 1; }
    install_homebrew() { test_log "INFO" "Homebrew attempted"; return 1; }
    install_package_manager() { test_log "INFO" "Package manager attempted"; return 0; }
    install_manual() { test_log "INFO" "Manual instructions attempted"; return 1; }

    # Override verification to always pass for this test
    verify_installation() { return 0; }
    post_install_setup() { return 0; }

    # Export mock functions
    export -f install_direct_download install_npm_global install_homebrew
    export -f install_package_manager install_manual verify_installation post_install_setup

    if install_claude_code >/dev/null 2>&1; then
        if [[ "${INSTALL_METHOD:-}" == "Package Manager (Linux)" ]]; then
            return 0
        else
            test_log "FAIL" "Wrong installation method was successful: ${INSTALL_METHOD:-none}"
            return 1
        fi
    else
        test_log "FAIL" "Installation should have succeeded with package manager"
        return 1
    fi
}

# Test 5: Security Features
test_security_features() {
    test_log "INFO" "Testing security features..."

    # Test checksum verification failure
    local test_file="$TEST_TEMP_DIR/security_test"
    local wrong_checksum="0000000000000000000000000000000000000000000000000000000000000000"

    echo "test content" > "$test_file"

    # This should fail due to wrong checksum
    if secure_download "file://$test_file" "$TEST_TEMP_DIR/output" "$wrong_checksum" 2>/dev/null; then
        test_log "FAIL" "Security check should have failed with wrong checksum"
        return 1
    else
        test_log "INFO" "Security check correctly failed with wrong checksum"
        return 0
    fi
}

# Test 6: Error Handling
test_error_handling() {
    test_log "INFO" "Testing error handling..."

    # Test with non-existent URL
    if secure_download "https://nonexistent.example.com/file" "$TEST_TEMP_DIR/nonexistent" 2>/dev/null; then
        test_log "FAIL" "Download should have failed for non-existent URL"
        return 1
    else
        test_log "INFO" "Error handling correctly failed for non-existent URL"
        return 0
    fi
}

# Test 7: Configuration Generation
test_config_generation() {
    test_log "INFO" "Testing configuration generation..."

    # Mock successful installation
    export INSTALL_METHOD="Test Method"

    if post_install_setup; then
        local config_file="$CLAUDE_CONFIG_DIR/config.json"
        if [[ -f "$config_file" ]]; then
            if grep -q "Test Method" "$config_file"; then
                return 0
            else
                test_log "FAIL" "Configuration doesn't contain installation method"
                return 1
            fi
        else
            test_log "FAIL" "Configuration file was not created"
            return 1
        fi
    else
        test_log "FAIL" "Post-installation setup failed"
        return 1
    fi
}

# Test 8: Logging System
test_logging_system() {
    test_log "INFO" "Testing logging system..."

    local test_log_file="$TEST_TEMP_DIR/test.log"
    export LOG_FILE="$test_log_file"

    # Test different log levels
    log "INFO" "Test info message"
    log "WARN" "Test warning message"
    log "ERROR" "Test error message"
    log "SUCCESS" "Test success message"

    if [[ -f "$test_log_file" ]]; then
        local log_content
        log_content=$(cat "$test_log_file")

        if [[ "$log_content" =~ "Test info message" ]] && \
           [[ "$log_content" =~ "Test warning message" ]] && \
           [[ "$log_content" =~ "Test error message" ]] && \
           [[ "$log_content" =~ "Test success message" ]]; then
            return 0
        else
            test_log "FAIL" "Not all log messages were written correctly"
            return 1
        fi
    else
        test_log "FAIL" "Log file was not created"
        return 1
    fi
}

# Main test runner
run_all_tests() {
    test_log "INFO" "Starting Claude Code Installer test suite..."
    test_log "INFO" "Test log: $TEST_LOG"

    # Initialize test log
    echo "Claude Code Installer Test Suite - $(date)" > "$TEST_LOG"

    # Setup test environment
    setup_test_env
    local setup_result=$?
    if [[ $setup_result -ne 0 ]]; then
        test_log "FAIL" "Failed to setup test environment (exit code: $setup_result)"
        return 1
    fi

    # Run tests
    run_test "Platform Detection" test_platform_detection
    run_test "Retry Logic with Exponential Backoff" test_retry_logic
    run_test "Secure Download Function" test_download_function
    run_test "Installation Method Priority" test_installation_priority
    run_test "Security Features" test_security_features
    run_test "Error Handling" test_error_handling
    run_test "Configuration Generation" test_config_generation
    run_test "Logging System" test_logging_system

    # Cleanup
    cleanup_test_env

    # Print test results
    echo
    test_log "INFO" "Test suite completed"
    test_log "INFO" "Tests run: $TESTS_RUN"
    test_log "INFO" "Tests passed: $TESTS_PASSED"
    test_log "INFO" "Tests failed: $TESTS_FAILED"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        test_log "PASS" "All tests passed successfully!"
        return 0
    else
        test_log "FAIL" "$TESTS_FAILED test(s) failed"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests "$@"
fi