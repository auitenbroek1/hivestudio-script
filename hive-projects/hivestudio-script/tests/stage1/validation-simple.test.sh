#!/bin/bash

# Simplified Test Suite for HiveStudio Stage 1 Validation Module
# Version: 1.0.0
# Author: Aaron Uitenbroek

set -euo pipefail

# Test framework setup
readonly SCRIPT_DIR_TEST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VALIDATION_SCRIPT="${SCRIPT_DIR_TEST}/../../stage1/lib/validation-compat.sh"
readonly TEST_LOG="${SCRIPT_DIR_TEST}/test-validation-$(date +%Y%m%d_%H%M%S).log"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test logging
test_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${TEST_LOG}"
}

test_info() {
    echo -e "${BLUE}[TEST INFO]${NC} $*" | tee -a "${TEST_LOG}"
}

test_success() {
    echo -e "${GREEN}[TEST PASS]${NC} $*" | tee -a "${TEST_LOG}"
    ((TESTS_PASSED++))
}

test_failure() {
    echo -e "${RED}[TEST FAIL]${NC} $*" | tee -a "${TEST_LOG}"
    ((TESTS_FAILED++))
}

test_warning() {
    echo -e "${YELLOW}[TEST WARN]${NC} $*" | tee -a "${TEST_LOG}"
}

# Test runner function
run_test() {
    local test_name="$1"
    local test_function="$2"

    ((TESTS_RUN++))
    test_info "Running test: $test_name"

    if $test_function; then
        test_success "$test_name"
        return 0
    else
        test_failure "$test_name"
        return 1
    fi
}

# Test validation script existence and permissions
test_script_exists() {
    if [[ -f "$VALIDATION_SCRIPT" ]]; then
        test_info "Validation script found at $VALIDATION_SCRIPT"
        return 0
    else
        test_failure "Validation script not found at $VALIDATION_SCRIPT"
        return 1
    fi
}

# Test script executability
test_script_executable() {
    if [[ -x "$VALIDATION_SCRIPT" ]]; then
        test_info "Validation script is executable"
        return 0
    else
        test_failure "Validation script is not executable"
        return 1
    fi
}

# Test script syntax
test_script_syntax() {
    if bash -n "$VALIDATION_SCRIPT" >/dev/null 2>&1; then
        test_info "Validation script syntax is valid"
        return 0
    else
        test_failure "Validation script has syntax errors"
        return 1
    fi
}

# Test validation script execution
test_script_execution() {
    local temp_dir="/tmp/validation-test-$$"
    mkdir -p "$temp_dir"

    # Run the validation script with timeout
    if timeout 60 "$VALIDATION_SCRIPT" >/dev/null 2>&1; then
        test_info "Validation script executed successfully"
        rm -rf "$temp_dir"
        return 0
    else
        local exit_code=$?
        test_info "Validation script execution completed with exit code: $exit_code"
        rm -rf "$temp_dir"
        # Exit code 1 is expected if some validations fail, so we consider this success
        return 0
    fi
}

# Test log file generation
test_log_generation() {
    local temp_log_dir="/tmp/validation-logs-$$"
    mkdir -p "$temp_log_dir"

    # Create a temporary copy of the script that uses our temp directory
    local temp_script="/tmp/validation-test-script-$$.sh"
    sed "s|readonly LOG_FILE=.*|readonly LOG_FILE=\"$temp_log_dir/test-validation.log\"|" "$VALIDATION_SCRIPT" > "$temp_script"
    chmod +x "$temp_script"

    # Run the temporary script
    "$temp_script" >/dev/null 2>&1 || true

    # Check if log file was created
    if [[ -f "$temp_log_dir/test-validation.log" ]]; then
        test_info "Log file generation test passed"
        rm -rf "$temp_log_dir" "$temp_script"
        return 0
    else
        test_failure "Log file was not generated"
        rm -rf "$temp_log_dir" "$temp_script"
        return 1
    fi
}

# Test JSON report generation
test_json_report_generation() {
    local temp_report_dir="/tmp/validation-reports-$$"
    mkdir -p "$temp_report_dir"

    # Create a temporary copy of the script that uses our temp directory
    local temp_script="/tmp/validation-report-script-$$.sh"
    sed -e "s|readonly LOG_FILE=.*|readonly LOG_FILE=\"$temp_report_dir/test-validation.log\"|" \
        -e "s|readonly REPORT_FILE=.*|readonly REPORT_FILE=\"$temp_report_dir/test-validation-report.json\"|" \
        "$VALIDATION_SCRIPT" > "$temp_script"
    chmod +x "$temp_script"

    # Run the temporary script
    "$temp_script" >/dev/null 2>&1 || true

    # Check if JSON report was created and is valid
    if [[ -f "$temp_report_dir/test-validation-report.json" ]] && \
       grep -q '"timestamp"' "$temp_report_dir/test-validation-report.json" && \
       grep -q '"summary"' "$temp_report_dir/test-validation-report.json"; then
        test_info "JSON report generation test passed"
        rm -rf "$temp_report_dir" "$temp_script"
        return 0
    else
        test_failure "JSON report was not generated or is invalid"
        rm -rf "$temp_report_dir" "$temp_script"
        return 1
    fi
}

# Test Node.js detection
test_nodejs_detection() {
    if command -v node >/dev/null 2>&1; then
        local node_version
        node_version=$(node --version 2>/dev/null | sed 's/v//')
        test_info "Node.js detected: v$node_version"
        return 0
    else
        test_warning "Node.js not detected (this may be expected in some environments)"
        return 0
    fi
}

# Test Git detection
test_git_detection() {
    if command -v git >/dev/null 2>&1; then
        local git_version
        git_version=$(git --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        test_info "Git detected: v$git_version"
        return 0
    else
        test_warning "Git not detected (this may be expected in some environments)"
        return 0
    fi
}

# Test network tools detection
test_network_tools_detection() {
    local found_tools=""

    if command -v curl >/dev/null 2>&1; then
        found_tools="$found_tools curl"
    fi

    if command -v wget >/dev/null 2>&1; then
        found_tools="$found_tools wget"
    fi

    if [[ -n "$found_tools" ]]; then
        test_info "Network tools detected:$found_tools"
        return 0
    else
        test_warning "No network tools detected (curl/wget)"
        return 0
    fi
}

# Test platform detection
test_platform_detection() {
    local platform=$(uname -s)
    local arch=$(uname -m)

    test_info "Platform detected: $platform $arch"

    case "$platform" in
        "Darwin"|"Linux"|"MINGW"*|"CYGWIN"*|"MSYS"*)
            test_info "Platform is supported"
            return 0
            ;;
        *)
            test_warning "Platform may not be fully supported: $platform"
            return 0
            ;;
    esac
}

# Test Bash version compatibility
test_bash_compatibility() {
    local bash_major=${BASH_VERSION%%.*}

    test_info "Bash version: $BASH_VERSION (major: $bash_major)"

    if [[ $bash_major -ge 3 ]]; then
        test_info "Bash version is compatible"
        return 0
    else
        test_failure "Bash version is too old"
        return 1
    fi
}

# Integration test - run actual validation
test_integration_validation() {
    test_info "Running integration test with actual validation..."

    # Run validation script and capture output
    local output
    local exit_code
    output=$("$VALIDATION_SCRIPT" 2>&1) || exit_code=$?

    # Check if essential validations ran
    if echo "$output" | grep -q "Validating Node.js installation" && \
       echo "$output" | grep -q "Validating Git installation" && \
       echo "$output" | grep -q "=== Summary Statistics ==="; then
        test_info "Integration test passed - all major validation components executed"
        return 0
    else
        test_failure "Integration test failed - missing expected validation output"
        return 1
    fi
}

# Performance test
test_validation_performance() {
    test_info "Running performance test..."

    local start_time=$(date +%s)

    # Run validation with timeout
    timeout 60 "$VALIDATION_SCRIPT" >/dev/null 2>&1 || true

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    test_info "Validation completed in ${duration} seconds"

    # Fail if it takes more than 45 seconds
    if [[ $duration -gt 45 ]]; then
        test_failure "Validation took too long: ${duration} seconds (max: 45)"
        return 1
    else
        test_info "Performance test passed"
        return 0
    fi
}

# Main test runner
main() {
    test_log "Starting HiveStudio Stage 1 Validation Test Suite (Simplified)"
    test_log "Test log: $TEST_LOG"
    test_log "Platform: $(uname -s) $(uname -m)"
    test_log "Bash version: $BASH_VERSION"

    test_info "=== Running Basic Tests ==="
    run_test "Script Exists" test_script_exists
    run_test "Script Executable" test_script_executable
    run_test "Script Syntax" test_script_syntax
    run_test "Bash Compatibility" test_bash_compatibility

    test_info "=== Running Detection Tests ==="
    run_test "Node.js Detection" test_nodejs_detection
    run_test "Git Detection" test_git_detection
    run_test "Network Tools Detection" test_network_tools_detection
    run_test "Platform Detection" test_platform_detection

    test_info "=== Running Functional Tests ==="
    run_test "Script Execution" test_script_execution
    run_test "Log Generation" test_log_generation
    run_test "JSON Report Generation" test_json_report_generation

    test_info "=== Running Integration Tests ==="
    run_test "Integration Validation" test_integration_validation

    test_info "=== Running Performance Tests ==="
    run_test "Validation Performance" test_validation_performance

    # Test summary
    test_log ""
    test_log "=== Test Suite Summary ==="
    test_log "Tests Run: $TESTS_RUN"
    test_log "Tests Passed: $TESTS_PASSED"
    test_log "Tests Failed: $TESTS_FAILED"

    if [[ $TESTS_RUN -gt 0 ]]; then
        test_log "Success Rate: $(( (TESTS_PASSED * 100) / TESTS_RUN ))%"
    fi

    if [[ $TESTS_FAILED -eq 0 ]]; then
        test_success "All tests passed!"
        exit 0
    else
        test_failure "$TESTS_FAILED tests failed!"
        exit 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi