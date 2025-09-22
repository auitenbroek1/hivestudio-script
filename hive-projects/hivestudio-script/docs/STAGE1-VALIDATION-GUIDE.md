# Stage 1 Library - Validation Module

## Overview

The Stage 1 validation module provides comprehensive prerequisite checking for HiveStudio installation. It validates system requirements, dependencies, and environment setup to ensure a smooth installation process.

## Features

### Core Validations

- **Node.js**: Version 18+ requirement checking
- **Package Managers**: npm, yarn, pnpm, bun detection
- **Git**: Installation and configuration validation
- **Network Tools**: curl/wget availability
- **Network Connectivity**: External service accessibility
- **System Resources**: Disk space and memory checking
- **Platform-Specific**: macOS, Linux, Windows/WSL requirements

### Advanced Features

- **Detailed Reporting**: JSON and text output formats
- **Installation Suggestions**: Automatic remediation guidance
- **Version Detection**: Comprehensive version information
- **Cross-Platform**: Support for macOS, Linux, Windows/WSL
- **Performance Optimized**: Fast execution with parallel checks

## Usage

### Basic Validation

```bash
# Run full validation
./stage1/lib/validation.sh

# Check specific component (when sourced)
source ./stage1/lib/validation.sh
validate_nodejs
```

### Integration Example

```bash
#!/bin/bash

# Source validation functions
source ./stage1/lib/validation.sh

# Set up logging
setup_logging

# Run specific validations
validate_nodejs
validate_git
validate_disk_space

# Generate report
generate_summary_report
```

## Output Files

### Log Files
- **Location**: `./logs/validation-YYYYMMDD_HHMMSS.log`
- **Format**: Timestamped entries with colored output
- **Content**: Detailed validation steps and results

### JSON Reports
- **Location**: `./logs/validation-report-YYYYMMDD_HHMMSS.json`
- **Format**: Structured JSON with validation results
- **Content**: Machine-readable validation data

## Validation Checks

### System Requirements

| Check | Minimum | Recommended | Platform |
|-------|---------|-------------|----------|
| Node.js | 18.0.0 | Latest LTS | All |
| Disk Space | 5GB | 10GB+ | All |
| Memory | 4GB | 8GB+ | All |
| Network | Basic | Broadband | All |

### Platform-Specific

#### macOS
- Xcode Command Line Tools
- Homebrew (recommended)

#### Linux
- Build essentials (gcc, g++, make)
- Package manager (apt, yum, dnf, pacman)

#### Windows/WSL
- WSL2 (recommended over WSL1)
- Windows Subsystem for Linux

## Return Codes

| Code | Status | Description |
|------|--------|-------------|
| 0 | SUCCESS | All validations passed |
| 1 | FAILED | Critical validations failed |

## Configuration

### Environment Variables

```bash
# Override minimum requirements
export MIN_NODE_VERSION="20.0.0"
export MIN_DISK_SPACE_GB="10"
export MIN_MEMORY_GB="8"

# Custom log locations
export VALIDATION_LOG_DIR="/custom/log/path"
```

### Customization

```bash
# Add custom validation
validate_custom_requirement() {
    log_info "Validating custom requirement..."

    if command -v custom_tool >/dev/null 2>&1; then
        VALIDATION_RESULTS["custom"]="PASS"
        log_success "Custom requirement met"
    else
        VALIDATION_RESULTS["custom"]="FAIL"
        log_error "Custom requirement not met"
        INSTALLATION_SUGGESTIONS["custom"]="Install custom_tool"
    fi
}
```

## Testing

### Run Test Suite

```bash
# Execute all tests
./tests/stage1/validation.test.sh

# Run specific test categories
source ./tests/stage1/validation.test.sh
test_nodejs_validation
test_integration_all_validations
```

### Test Coverage

- **Unit Tests**: Individual function validation
- **Integration Tests**: End-to-end validation flow
- **Performance Tests**: Execution speed validation
- **Edge Cases**: Error condition handling

## API Reference

### Main Functions

#### `validate_nodejs()`
Validates Node.js installation and version requirements.

**Sets**:
- `VALIDATION_RESULTS["nodejs"]`: "PASS" | "FAIL"
- `VERSION_INFO["nodejs"]`: Version string or "Not installed"
- `INSTALLATION_SUGGESTIONS["nodejs"]`: Installation guidance (if needed)

#### `validate_package_managers()`
Detects available package managers (npm, yarn, pnpm, bun).

**Sets**:
- `VALIDATION_RESULTS["package_managers"]`: "PASS" | "FAIL"
- `VERSION_INFO["{manager}"]`: Version for each detected manager

#### `validate_git()`
Validates Git installation and configuration.

**Sets**:
- `VALIDATION_RESULTS["git"]`: "PASS" | "FAIL"
- `VERSION_INFO["git"]`: Git version
- `INSTALLATION_SUGGESTIONS["git_config"]`: Configuration guidance

#### `validate_network_connectivity()`
Tests connectivity to essential services.

**Tests**:
- npm registry (registry.npmjs.org)
- GitHub (github.com, api.github.com)

**Sets**:
- `VALIDATION_RESULTS["network_connectivity"]`: "PASS" | "WARN" | "FAIL"

#### `generate_summary_report()`
Creates comprehensive validation report.

**Outputs**:
- Console summary with colored status indicators
- JSON report file with structured data
- Installation suggestions for failed checks

### Utility Functions

#### `version_compare(version1, version2)`
Semantic version comparison utility.

**Returns**:
- `0`: version1 >= version2
- `1`: version1 < version2

#### `log(), log_info(), log_warning(), log_error(), log_success()`
Logging functions with timestamp and color formatting.

## Troubleshooting

### Common Issues

#### Node.js Version Too Old
```bash
# Solution 1: Update via package manager
brew install node  # macOS
sudo apt update && sudo apt install nodejs npm  # Ubuntu

# Solution 2: Use Node Version Manager
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install node
```

#### Missing Build Tools
```bash
# macOS
xcode-select --install

# Ubuntu/Debian
sudo apt-get install build-essential

# RHEL/CentOS
sudo yum groupinstall 'Development Tools'
```

#### Network Connectivity Issues
```bash
# Check proxy settings
echo $HTTP_PROXY
echo $HTTPS_PROXY

# Test direct connectivity
curl -I https://registry.npmjs.org
```

### Debug Mode

```bash
# Enable verbose logging
set -x
./stage1/lib/validation.sh

# Check specific function
bash -x -c 'source ./stage1/lib/validation.sh; validate_nodejs'
```

## Contributing

### Adding New Validations

1. Create validation function following naming convention
2. Set appropriate `VALIDATION_RESULTS`, `VERSION_INFO`, and `INSTALLATION_SUGGESTIONS`
3. Add logging with appropriate levels
4. Include platform-specific logic if needed
5. Add corresponding test cases

### Validation Function Template

```bash
validate_new_component() {
    log_info "Validating new component..."

    if command -v new_component >/dev/null 2>&1; then
        local version
        version=$(new_component --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        VERSION_INFO["new_component"]="$version"
        VALIDATION_RESULTS["new_component"]="PASS"
        log_success "New component v${version} is available"
    else
        VALIDATION_RESULTS["new_component"]="FAIL"
        VERSION_INFO["new_component"]="Not installed"
        log_error "New component is not installed"
        INSTALLATION_SUGGESTIONS["new_component"]="Install new component: package_manager install new_component"
    fi
}
```

## License

MIT License - see project root for details.