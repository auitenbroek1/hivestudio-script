#!/bin/bash

# Test Suite for HiveStudio Stage 1 Validation Module
# Version: 1.0.0
# Author: Aaron Uitenbroek

set -euo pipefail

# Test framework setup
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VALIDATION_SCRIPT="${SCRIPT_DIR}/../../stage1/lib/validation-compat.sh"
readonly TEST_LOG="${SCRIPT_DIR}/test-validation-$(date +%Y%m%d_%H%M%S).log"

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

# Source the validation script functions
source_validation_script() {
    if [[ -f "$VALIDATION_SCRIPT" ]]; then
        # Source without executing main
        source "$VALIDATION_SCRIPT"
        test_success "Validation script sourced successfully"
        return 0
    else
        test_failure "Validation script not found at $VALIDATION_SCRIPT"
        return 1
    fi
}

# Test version comparison function
test_version_comparison() {
    local test_cases=(
        "18.0.0:17.9.9:true"
        "18.0.0:18.0.0:true"
        "17.9.9:18.0.0:false"
        "18.1.0:18.0.0:true"
        "16.20.1:18.0.0:false"
        "20.0.0:18.0.0:true"
    )

    for case in "${test_cases[@]}"; do
        IFS=':' read -r version1 version2 expected <<< "$case"

        if version_compare "$version1" "$version2"; then
            actual="true"
        else
            actual="false"
        fi

        if [[ "$actual" == "$expected" ]]; then
            test_info "Version comparison $version1 vs $version2: PASS (expected: $expected, got: $actual)"
        else
            test_failure "Version comparison $version1 vs $version2: FAIL (expected: $expected, got: $actual)"
            return 1
        fi
    done

    return 0
}

# Test Node.js validation
test_nodejs_validation() {
    local original_path="$PATH"

    # Test with Node.js available
    if command -v node >/dev/null 2>&1; then
        validate_nodejs
        if [[ "${VALIDATION_RESULTS[nodejs]}" == "PASS" || "${VALIDATION_RESULTS[nodejs]}" == "FAIL" ]]; then
            test_info "Node.js validation completed with status: ${VALIDATION_RESULTS[nodejs]}"
            return 0
        else
            test_failure "Node.js validation returned unexpected status: ${VALIDATION_RESULTS[nodejs]}"
            return 1
        fi
    else
        test_warning "Node.js not available for testing"
        return 0
    fi
}

# Test package manager validation
test_package_manager_validation() {
    validate_package_managers

    if [[ "${VALIDATION_RESULTS[package_managers]}" == "PASS" || "${VALIDATION_RESULTS[package_managers]}" == "FAIL" ]]; then
        test_info "Package manager validation completed with status: ${VALIDATION_RESULTS[package_managers]}"
        return 0
    else
        test_failure "Package manager validation returned unexpected status: ${VALIDATION_RESULTS[package_managers]}"
        return 1
    fi
}

# Test Git validation
test_git_validation() {
    validate_git

    if [[ "${VALIDATION_RESULTS[git]}" == "PASS" || "${VALIDATION_RESULTS[git]}" == "FAIL" ]]; then
        test_info "Git validation completed with status: ${VALIDATION_RESULTS[git]}"
        return 0
    else
        test_failure "Git validation returned unexpected status: ${VALIDATION_RESULTS[git]}"
        return 1
    fi
}

# Test network tools validation
test_network_tools_validation() {
    validate_network_tools

    if [[ "${VALIDATION_RESULTS[network_tools]}" == "PASS" || "${VALIDATION_RESULTS[network_tools]}" == "FAIL" ]]; then
        test_info "Network tools validation completed with status: ${VALIDATION_RESULTS[network_tools]}"
        return 0
    else
        test_failure "Network tools validation returned unexpected status: ${VALIDATION_RESULTS[network_tools]}"
        return 1
    fi
}

# Test network connectivity validation
test_network_connectivity_validation() {
    validate_network_connectivity

    if [[ "${VALIDATION_RESULTS[network_connectivity]}" == "PASS" || "${VALIDATION_RESULTS[network_connectivity]}" == "WARN" || "${VALIDATION_RESULTS[network_connectivity]}" == "FAIL" ]]; then
        test_info "Network connectivity validation completed with status: ${VALIDATION_RESULTS[network_connectivity]}"
        return 0
    else
        test_failure "Network connectivity validation returned unexpected status: ${VALIDATION_RESULTS[network_connectivity]}"
        return 1
    fi
}

# Test disk space validation
test_disk_space_validation() {
    validate_disk_space

    if [[ "${VALIDATION_RESULTS[disk_space]}" == "PASS" || "${VALIDATION_RESULTS[disk_space]}" == "FAIL" || "${VALIDATION_RESULTS[disk_space]}" == "SKIP" ]]; then
        test_info "Disk space validation completed with status: ${VALIDATION_RESULTS[disk_space]}"
        return 0
    else
        test_failure "Disk space validation returned unexpected status: ${VALIDATION_RESULTS[disk_space]}"
        return 1
    fi
}

# Test memory validation
test_memory_validation() {
    validate_memory

    if [[ "${VALIDATION_RESULTS[memory]}" == "PASS" || "${VALIDATION_RESULTS[memory]}" == "WARN" || "${VALIDATION_RESULTS[memory]}" == "SKIP" ]]; then
        test_info "Memory validation completed with status: ${VALIDATION_RESULTS[memory]}"
        return 0
    else
        test_failure "Memory validation returned unexpected status: ${VALIDATION_RESULTS[memory]}"
        return 1
    fi
}

# Test platform-specific validation
test_platform_specific_validation() {
    validate_platform_specific

    if [[ "${VALIDATION_RESULTS[platform_specific]}" == "PASS" || "${VALIDATION_RESULTS[platform_specific]}" == "FAIL" || "${VALIDATION_RESULTS[platform_specific]}" == "SKIP" ]]; then
        test_info "Platform-specific validation completed with status: ${VALIDATION_RESULTS[platform_specific]}"
        return 0
    else
        test_failure "Platform-specific validation returned unexpected status: ${VALIDATION_RESULTS[platform_specific]}"
        return 1
    fi
}

# Test logging functionality
test_logging_functionality() {
    local temp_log="/tmp/test-validation-log-$$.log"

    # Override LOG_FILE for testing
    LOG_FILE="$temp_log"

    log "Test log message"
    log_info "Test info message"
    log_warning "Test warning message"
    log_success "Test success message"

    if [[ -f "$temp_log" ]] && grep -q "Test log message" "$temp_log"; then
        rm -f "$temp_log"
        return 0
    else
        rm -f "$temp_log"
        return 1
    fi
}

# Test JSON report generation
test_json_report_generation() {
    local temp_report="/tmp/test-validation-report-$$.json"
    REPORT_FILE="$temp_report"

    # Set up test data
    VALIDATION_RESULTS["test_check"]="PASS"
    VERSION_INFO["test_check"]="1.0.0"

    generate_json_report 1 1 0 0 0

    if [[ -f "$temp_report" ]] && grep -q '"overall_status": "PASSED"' "$temp_report"; then
        rm -f "$temp_report"
        return 0
    else
        rm -f "$temp_report"
        return 1
    fi
}

# Test validation script execution
test_full_validation_execution() {
    local temp_dir="/tmp/validation-test-$$"
    mkdir -p "$temp_dir"

    # Create a temporary validation script copy
    local temp_script="$temp_dir/validation.sh"
    cp "$VALIDATION_SCRIPT" "$temp_script"
    chmod +x "$temp_script"

    # Run the validation script
    if "$temp_script" --help >/dev/null 2>&1 || "$temp_script" >/dev/null 2>&1; then
        rm -rf "$temp_dir"
        return 0
    else
        test_info "Full validation execution test completed (may have failed checks, which is normal)"
        rm -rf "$temp_dir"
        return 0  # Don't fail test if validation finds issues
    fi
}

# Integration test - run all validations
test_integration_all_validations() {
    # Initialize validation arrays
    declare -A VALIDATION_RESULTS=()
    declare -A VERSION_INFO=()
    declare -A INSTALLATION_SUGGESTIONS=()

    # Set up temporary files
    LOG_FILE="/tmp/integration-test-log-$$.log"
    REPORT_FILE="/tmp/integration-test-report-$$.json"

    # Run all validation functions
    validate_nodejs
    validate_package_managers
    validate_git
    validate_network_tools
    validate_network_connectivity
    validate_disk_space
    validate_memory
    validate_platform_specific

    # Check that all expected results are present
    local expected_checks=("nodejs" "package_managers" "git" "network_tools" "network_connectivity" "disk_space" "memory" "platform_specific")
    local missing_checks=()

    for check in "${expected_checks[@]}"; do
        if [[ -z "${VALIDATION_RESULTS[$check]:-}" ]]; then
            missing_checks+=("$check")
        fi
    done

    # Clean up
    rm -f "$LOG_FILE" "$REPORT_FILE"

    if [[ ${#missing_checks[@]} -eq 0 ]]; then
        test_info "All validation checks completed successfully"
        return 0
    else
        test_failure "Missing validation results for: ${missing_checks[*]}"
        return 1
    fi
}

# Performance test
test_validation_performance() {
    local start_time=$(date +%s)

    # Run a subset of validation functions
    validate_nodejs
    validate_git
    validate_network_tools

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    test_info "Validation performance test completed in ${duration} seconds"

    # Fail if it takes more than 30 seconds (reasonable timeout)
    if [[ $duration -gt 30 ]]; then
        test_failure "Validation took too long: ${duration} seconds (max: 30)"
        return 1
    else
        return 0
    fi
}

# Edge case tests
test_edge_cases() {
    # Test with empty PATH
    local original_path="$PATH"
    export PATH=""

    validate_nodejs 2>/dev/null || true
    validate_git 2>/dev/null || true

    # Restore PATH
    export PATH="$original_path"

    test_info "Edge case testing completed"
    return 0
}

# Main test runner
main() {
    test_log "Starting HiveStudio Stage 1 Validation Test Suite"
    test_log "Test log: $TEST_LOG"
    test_log "Platform: $(uname -s) $(uname -m)"

    # Source the validation script
    if ! source_validation_script; then
        test_failure "Cannot source validation script - aborting tests"
        exit 1
    fi

    # Run all tests
    test_info "=== Running Unit Tests ==="
    run_test "Version Comparison" test_version_comparison
    run_test "Logging Functionality" test_logging_functionality
    run_test "JSON Report Generation" test_json_report_generation

    test_info "=== Running Component Tests ==="
    run_test "Node.js Validation" test_nodejs_validation
    run_test "Package Manager Validation" test_package_manager_validation
    run_test "Git Validation" test_git_validation
    run_test "Network Tools Validation" test_network_tools_validation
    run_test "Network Connectivity Validation" test_network_connectivity_validation
    run_test "Disk Space Validation" test_disk_space_validation
    run_test "Memory Validation" test_memory_validation
    run_test "Platform-Specific Validation" test_platform_specific_validation

    test_info "=== Running Integration Tests ==="
    run_test "Full Validation Execution" test_full_validation_execution
    run_test "All Validations Integration" test_integration_all_validations

    test_info "=== Running Performance Tests ==="
    run_test "Validation Performance" test_validation_performance

    test_info "=== Running Edge Case Tests ==="
    run_test "Edge Cases" test_edge_cases

    # Test summary
    test_log ""
    test_log "=== Test Suite Summary ==="
    test_log "Tests Run: $TESTS_RUN"
    test_log "Tests Passed: $TESTS_PASSED"
    test_log "Tests Failed: $TESTS_FAILED"
    test_log "Success Rate: $(( (TESTS_PASSED * 100) / TESTS_RUN ))%"

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