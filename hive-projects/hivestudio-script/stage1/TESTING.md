# Stage 1 Testing Guide

This document provides comprehensive testing procedures for Stage 1 of the HiveStudio installation system.

## Overview

Stage 1 testing ensures that the system preparation phase works correctly across different environments, platforms, and configurations. Testing covers prerequisite validation, Claude Code installation, authentication verification, and handoff data creation.

## Test Categories

### 1. Pre-Installation Testing
### 2. Platform-Specific Testing
### 3. Installation Process Testing
### 4. Error Handling Testing
### 5. Handoff Mechanism Testing
### 6. Performance Testing
### 7. Security Testing

## Pre-Installation Testing

### System Prerequisites Validation

#### Test Case: Node.js Version Validation
```bash
# Test Case: PT-001
# Description: Validate Node.js version requirements
# Expected: Pass for Node.js >=18.0.0, warn for older versions

# Setup: Install different Node.js versions
test_nodejs_validation() {
    echo "Testing Node.js version validation..."

    # Test with valid version (should pass)
    docker run --rm -v $(pwd):/workspace node:20 bash -c "
        cd /workspace && ./scripts/stage1-system-preparation.sh --dry-run --check-only
    "

    # Test with old version (should warn)
    docker run --rm -v $(pwd):/workspace node:16 bash -c "
        cd /workspace && ./scripts/stage1-system-preparation.sh --dry-run --check-only
    "
}
```

#### Test Case: Missing Dependencies
```bash
# Test Case: PT-002
# Description: Handle missing system dependencies gracefully
# Expected: Clear error messages and installation guidance

test_missing_dependencies() {
    echo "Testing missing dependencies handling..."

    # Create minimal container without tools
    docker run --rm -v $(pwd):/workspace ubuntu:22.04 bash -c "
        cd /workspace
        # Test without Node.js
        ./scripts/stage1-system-preparation.sh --dry-run --check-only
        echo 'Exit code:' \$?
    "
}
```

#### Test Case: Network Connectivity
```bash
# Test Case: PT-003
# Description: Validate network connectivity requirements
# Expected: Graceful handling of network issues

test_network_connectivity() {
    echo "Testing network connectivity validation..."

    # Test with blocked network
    docker run --rm --network none -v $(pwd):/workspace node:20 bash -c "
        cd /workspace && ./scripts/stage1-system-preparation.sh --dry-run --network-check-only
    "

    # Test with limited network (e.g., no GitHub access)
    # This would require a controlled network environment
}
```

### Permission and Environment Testing

#### Test Case: Write Permissions
```bash
# Test Case: PT-004
# Description: Validate write permissions in various scenarios
# Expected: Proper permission checking and user guidance

test_write_permissions() {
    echo "Testing write permissions..."

    # Test in read-only directory
    mkdir -p /tmp/readonly-test
    cp -r . /tmp/readonly-test/
    chmod -R 555 /tmp/readonly-test

    cd /tmp/readonly-test
    ./scripts/stage1-system-preparation.sh --dry-run --permissions-check-only

    # Cleanup
    chmod -R 755 /tmp/readonly-test
    rm -rf /tmp/readonly-test
}
```

## Platform-Specific Testing

### macOS Testing

#### Test Case: macOS Environment
```bash
# Test Case: PS-001 (macOS)
# Description: Validate macOS-specific requirements and installation
# Expected: Proper detection and handling of macOS features

test_macos_environment() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Testing macOS environment..."

        # Test Xcode Command Line Tools detection
        if ! xcode-select -p &> /dev/null; then
            echo "Testing without Xcode tools (expected warning)"
        fi

        # Test Homebrew availability
        if command -v brew &> /dev/null; then
            echo "Testing with Homebrew available"
        else
            echo "Testing without Homebrew"
        fi

        ./scripts/stage1-system-preparation.sh --dry-run --platform-check-only
    else
        echo "Skipping macOS tests (not on macOS)"
    fi
}
```

### Linux Testing

#### Test Case: Ubuntu/Debian Environment
```bash
# Test Case: PS-002 (Linux)
# Description: Validate Linux-specific requirements
# Expected: Proper package manager detection and dependency handling

test_ubuntu_environment() {
    docker run --rm -v $(pwd):/workspace ubuntu:22.04 bash -c "
        apt-get update && apt-get install -y curl git
        cd /workspace
        ./scripts/stage1-system-preparation.sh --dry-run --platform-check-only
    "
}
```

#### Test Case: GitHub Codespaces Environment
```bash
# Test Case: PS-003 (Codespaces)
# Description: Validate GitHub Codespaces detection and optimization
# Expected: Proper Codespaces environment detection

test_codespaces_environment() {
    echo "Testing Codespaces environment simulation..."

    # Simulate Codespaces environment
    export CODESPACES=true
    export CODESPACE_NAME="test-codespace"

    ./scripts/stage1-system-preparation.sh --dry-run --platform-check-only

    # Cleanup
    unset CODESPACES CODESPACE_NAME
}
```

### Windows (WSL) Testing

#### Test Case: WSL Environment
```bash
# Test Case: PS-004 (WSL)
# Description: Validate Windows Subsystem for Linux compatibility
# Expected: Proper WSL detection and compatibility warnings

test_wsl_environment() {
    # This test should be run in actual WSL environment
    if grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
        echo "Testing in WSL environment..."
        ./scripts/stage1-system-preparation.sh --dry-run --platform-check-only
    else
        echo "Skipping WSL tests (not in WSL)"
    fi
}
```

## Installation Process Testing

### Claude Code Installation Testing

#### Test Case: Installation Strategy Fallback
```bash
# Test Case: IP-001
# Description: Test multiple installation strategies
# Expected: Graceful fallback between installation methods

test_installation_strategies() {
    echo "Testing Claude Code installation strategies..."

    # Create test environment without npm
    docker run --rm -v $(pwd):/workspace node:20 bash -c "
        # Remove npm to test fallback
        rm -f /usr/local/bin/npm
        cd /workspace
        ./scripts/stage1-system-preparation.sh --dry-run --install-test-only
    "
}
```

#### Test Case: Installation Verification
```bash
# Test Case: IP-002
# Description: Verify successful Claude Code installation
# Expected: Proper installation verification and version detection

test_installation_verification() {
    echo "Testing installation verification..."

    # Mock successful installation
    mkdir -p /tmp/mock-claude
    cat > /tmp/mock-claude/claude << 'EOF'
#!/bin/bash
case "$1" in
    "--version") echo "Claude Code v1.2.3" ;;
    "status") exit 0 ;;
    "auth")
        case "$2" in
            "status") exit 0 ;;
        esac
        ;;
    *) echo "Mock Claude CLI" ;;
esac
EOF
    chmod +x /tmp/mock-claude/claude

    # Test with mock installation
    PATH="/tmp/mock-claude:$PATH" ./scripts/stage1-system-preparation.sh --dry-run --verify-only

    # Cleanup
    rm -rf /tmp/mock-claude
}
```

### Authentication Testing

#### Test Case: Authentication Flow
```bash
# Test Case: IP-003
# Description: Test authentication verification process
# Expected: Proper authentication status detection

test_authentication_flow() {
    echo "Testing authentication flow..."

    # Mock authenticated state
    mkdir -p /tmp/mock-claude-auth
    cat > /tmp/mock-claude-auth/claude << 'EOF'
#!/bin/bash
case "$1 $2" in
    "auth status") exit 0 ;;  # Authenticated
    "--version") echo "Claude Code v1.2.3" ;;
    "status") exit 0 ;;
    *) echo "Mock Claude CLI" ;;
esac
EOF
    chmod +x /tmp/mock-claude-auth/claude

    PATH="/tmp/mock-claude-auth:$PATH" ./scripts/stage1-system-preparation.sh --dry-run --auth-test-only

    # Test unauthenticated state
    cat > /tmp/mock-claude-auth/claude << 'EOF'
#!/bin/bash
case "$1 $2" in
    "auth status") exit 1 ;;  # Not authenticated
    "--version") echo "Claude Code v1.2.3" ;;
    "status") exit 0 ;;
    *) echo "Mock Claude CLI" ;;
esac
EOF

    PATH="/tmp/mock-claude-auth:$PATH" ./scripts/stage1-system-preparation.sh --dry-run --auth-test-only

    # Cleanup
    rm -rf /tmp/mock-claude-auth
}
```

## Error Handling Testing

### Network Error Testing

#### Test Case: Network Failures
```bash
# Test Case: EH-001
# Description: Test handling of network connectivity issues
# Expected: Graceful error handling and user guidance

test_network_errors() {
    echo "Testing network error handling..."

    # Test with no network
    docker run --rm --network none -v $(pwd):/workspace node:20 bash -c "
        cd /workspace
        timeout 30 ./scripts/stage1-system-preparation.sh --dry-run
        echo 'Network test exit code:' \$?
    "
}
```

### Permission Error Testing

#### Test Case: Permission Denied Scenarios
```bash
# Test Case: EH-002
# Description: Test handling of permission issues
# Expected: Clear error messages and recovery suggestions

test_permission_errors() {
    echo "Testing permission error handling..."

    # Create read-only environment
    mkdir -p /tmp/permission-test
    cp -r . /tmp/permission-test/
    chmod -R 444 /tmp/permission-test/scripts/

    cd /tmp/permission-test
    ./scripts/stage1-system-preparation.sh --dry-run

    # Cleanup
    chmod -R 755 /tmp/permission-test
    rm -rf /tmp/permission-test
}
```

### Installation Failure Testing

#### Test Case: Claude Installation Failures
```bash
# Test Case: EH-003
# Description: Test handling of Claude Code installation failures
# Expected: Multiple fallback attempts and clear failure messages

test_installation_failures() {
    echo "Testing installation failure handling..."

    # Mock failing installation
    mkdir -p /tmp/mock-fail
    cat > /tmp/mock-fail/npm << 'EOF'
#!/bin/bash
echo "npm: installation failed"
exit 1
EOF
    chmod +x /tmp/mock-fail/npm

    PATH="/tmp/mock-fail:$PATH" ./scripts/stage1-system-preparation.sh --dry-run --install-test-only

    # Cleanup
    rm -rf /tmp/mock-fail
}
```

## Handoff Mechanism Testing

### Handoff File Creation Testing

#### Test Case: Handoff Data Generation
```bash
# Test Case: HM-001
# Description: Test handoff file creation and format
# Expected: Valid JSON with all required fields

test_handoff_creation() {
    echo "Testing handoff file creation..."

    # Run Stage 1 in test mode
    ./scripts/stage1-system-preparation.sh --dry-run --handoff-test-only

    # Validate handoff file
    if [ -f ".hivestudio-stage1-complete" ]; then
        echo "Handoff file created successfully"

        # Validate JSON format
        if command -v jq &> /dev/null; then
            jq empty .hivestudio-stage1-complete
            echo "JSON format validation: $?"
        else
            python3 -m json.tool .hivestudio-stage1-complete > /dev/null
            echo "JSON format validation: $?"
        fi

        # Check required fields
        required_fields=("stage1_completed" "timestamp" "claude_code_version" "system_info")
        for field in "${required_fields[@]}"; do
            if grep -q "\"$field\"" .hivestudio-stage1-complete; then
                echo "✅ Required field present: $field"
            else
                echo "❌ Missing required field: $field"
            fi
        done

        # Cleanup test file
        rm -f .hivestudio-stage1-complete
    else
        echo "❌ Handoff file not created"
    fi
}
```

### Handoff Data Validation Testing

#### Test Case: Data Integrity
```bash
# Test Case: HM-002
# Description: Test handoff data integrity and schema compliance
# Expected: All data fields properly formatted and valid

test_handoff_validation() {
    echo "Testing handoff data validation..."

    # Create test handoff file
    cat > .hivestudio-stage1-complete << 'EOF'
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
EOF

    # Test Stage 2 handoff reading
    if [ -f "scripts/stage2-hivestudio-install.sh" ]; then
        # Test handoff data loading
        source scripts/stage2-hivestudio-install.sh
        load_stage1_handoff_data

        # Verify environment variables are set
        if [ -n "$STAGE1_COMPLETION_TIME" ]; then
            echo "✅ Handoff data loaded successfully"
        else
            echo "❌ Handoff data loading failed"
        fi
    fi

    # Cleanup
    rm -f .hivestudio-stage1-complete
}
```

## Performance Testing

### Installation Speed Testing

#### Test Case: Installation Performance
```bash
# Test Case: PT-001
# Description: Measure installation time and resource usage
# Expected: Reasonable installation time and resource consumption

test_installation_performance() {
    echo "Testing installation performance..."

    # Measure installation time
    start_time=$(date +%s)
    ./scripts/stage1-system-preparation.sh --dry-run --performance-test
    end_time=$(date +%s)

    duration=$((end_time - start_time))
    echo "Installation duration: ${duration} seconds"

    # Check if duration is reasonable (< 300 seconds for normal conditions)
    if [ $duration -lt 300 ]; then
        echo "✅ Installation performance acceptable"
    else
        echo "⚠️ Installation took longer than expected: ${duration}s"
    fi
}
```

### Resource Usage Testing

#### Test Case: Memory and CPU Usage
```bash
# Test Case: PT-002
# Description: Monitor resource usage during installation
# Expected: Reasonable memory and CPU consumption

test_resource_usage() {
    echo "Testing resource usage..."

    # Start resource monitoring
    if command -v top &> /dev/null; then
        # Monitor resources in background
        top -l 1 -n 0 | grep "PhysMem\|CPU usage" > resource_before.txt &

        # Run installation
        ./scripts/stage1-system-preparation.sh --dry-run --resource-test

        top -l 1 -n 0 | grep "PhysMem\|CPU usage" > resource_after.txt

        echo "Resource usage comparison:"
        echo "Before:"
        cat resource_before.txt
        echo "After:"
        cat resource_after.txt

        # Cleanup
        rm -f resource_before.txt resource_after.txt
    fi
}
```

## Security Testing

### Input Validation Testing

#### Test Case: Malicious Input Handling
```bash
# Test Case: ST-001
# Description: Test handling of malicious or invalid inputs
# Expected: Proper input sanitization and validation

test_input_validation() {
    echo "Testing input validation..."

    # Test with special characters in environment
    export MALICIOUS_VAR="'; rm -rf / #"
    export XSS_VAR="<script>alert('xss')</script>"

    ./scripts/stage1-system-preparation.sh --dry-run --input-test-only

    # Cleanup
    unset MALICIOUS_VAR XSS_VAR
}
```

### File Permission Testing

#### Test Case: Secure File Creation
```bash
# Test Case: ST-002
# Description: Verify secure file creation and permissions
# Expected: Proper file permissions and no information leakage

test_file_security() {
    echo "Testing file security..."

    # Run Stage 1 and check created files
    ./scripts/stage1-system-preparation.sh --dry-run --security-test

    # Check handoff file permissions
    if [ -f ".hivestudio-stage1-complete" ]; then
        permissions=$(stat -c %a .hivestudio-stage1-complete 2>/dev/null || stat -f %A .hivestudio-stage1-complete)
        echo "Handoff file permissions: $permissions"

        # Should be readable by user only (600) or similar
        if [[ "$permissions" =~ ^[67][0-9][0-9]$ ]]; then
            echo "✅ Secure file permissions"
        else
            echo "⚠️ File permissions may be too permissive: $permissions"
        fi

        # Cleanup
        rm -f .hivestudio-stage1-complete
    fi
}
```

## Validation Checklist

### Pre-Test Setup
- [ ] Clean environment prepared
- [ ] Required dependencies available (Docker, Node.js versions)
- [ ] Network access configured
- [ ] Test data and mocks prepared

### Core Functionality Tests
- [ ] Prerequisites validation works correctly
- [ ] Platform detection functions properly
- [ ] Network connectivity checks are accurate
- [ ] Claude Code installation succeeds
- [ ] Authentication verification works
- [ ] Handoff file creation is successful

### Platform Coverage
- [ ] macOS testing completed
- [ ] Linux (Ubuntu/Debian) testing completed
- [ ] GitHub Codespaces testing completed
- [ ] WSL testing completed (if applicable)

### Error Scenarios
- [ ] Network failure handling tested
- [ ] Permission error handling tested
- [ ] Installation failure recovery tested
- [ ] Invalid input handling tested

### Performance and Security
- [ ] Installation performance measured
- [ ] Resource usage monitored
- [ ] Input validation tested
- [ ] File security verified

### Integration Testing
- [ ] Handoff mechanism tested
- [ ] Stage 2 integration verified
- [ ] End-to-end workflow tested

## Automated Testing Script

### Complete Test Suite
```bash
#!/bin/bash
# Stage 1 Automated Test Suite

echo "🧪 HiveStudio Stage 1 Test Suite"
echo "================================"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test runner function
run_test() {
    local test_name=$1
    local test_function=$2

    echo ""
    echo "Running test: $test_name"
    echo "$(printf '=%.0s' {1..50})"

    ((TOTAL_TESTS++))

    if $test_function; then
        echo "✅ PASSED: $test_name"
        ((PASSED_TESTS++))
    else
        echo "❌ FAILED: $test_name"
        ((FAILED_TESTS++))
    fi
}

# Run all tests
main() {
    echo "Starting comprehensive Stage 1 testing..."

    # Prerequisites tests
    run_test "Node.js Version Validation" test_nodejs_validation
    run_test "Missing Dependencies" test_missing_dependencies
    run_test "Write Permissions" test_write_permissions

    # Platform tests
    run_test "macOS Environment" test_macos_environment
    run_test "Ubuntu Environment" test_ubuntu_environment
    run_test "Codespaces Environment" test_codespaces_environment

    # Installation tests
    run_test "Installation Strategies" test_installation_strategies
    run_test "Installation Verification" test_installation_verification
    run_test "Authentication Flow" test_authentication_flow

    # Error handling tests
    run_test "Network Errors" test_network_errors
    run_test "Permission Errors" test_permission_errors
    run_test "Installation Failures" test_installation_failures

    # Handoff tests
    run_test "Handoff Creation" test_handoff_creation
    run_test "Handoff Validation" test_handoff_validation

    # Performance tests
    run_test "Installation Performance" test_installation_performance
    run_test "Resource Usage" test_resource_usage

    # Security tests
    run_test "Input Validation" test_input_validation
    run_test "File Security" test_file_security

    # Summary
    echo ""
    echo "🎉 Test Suite Complete"
    echo "====================="
    echo "Total Tests: $TOTAL_TESTS"
    echo "Passed: $PASSED_TESTS"
    echo "Failed: $FAILED_TESTS"
    echo "Success Rate: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%"

    if [ $FAILED_TESTS -eq 0 ]; then
        echo ""
        echo "🎉 All tests passed! Stage 1 is ready for production."
        exit 0
    else
        echo ""
        echo "❌ Some tests failed. Please review and fix issues."
        exit 1
    fi
}

# Load test functions
source "$(dirname "$0")/test-functions.sh" 2>/dev/null || echo "Test functions not found - using inline definitions"

# Run the test suite
main "$@"
```

## Continuous Integration Testing

### GitHub Actions Workflow
```yaml
name: Stage 1 Testing

on:
  push:
    paths:
      - 'scripts/stage1-system-preparation.sh'
      - 'stage1/**'
  pull_request:
    paths:
      - 'scripts/stage1-system-preparation.sh'
      - 'stage1/**'

jobs:
  test-stage1:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
        node-version: [18, 20, 22]

    runs-on: ${{ matrix.os }}

    steps:
    - uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}

    - name: Run Stage 1 Tests
      run: |
        chmod +x scripts/stage1-system-preparation.sh
        ./stage1/test-suite.sh

    - name: Validate Handoff Data
      run: |
        if [ -f ".hivestudio-stage1-complete" ]; then
          echo "Handoff file created successfully"
          cat .hivestudio-stage1-complete
        fi
```

---

This comprehensive testing guide ensures Stage 1 works reliably across all supported platforms and scenarios.