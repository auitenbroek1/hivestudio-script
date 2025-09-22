# HiveStudio Installation System Implementation Guide

## Overview

This guide provides step-by-step instructions for implementing and using the improved HiveStudio installation system v2.0. The new system incorporates Turbo Flow Claude best practices for resilient, progressive, and environment-aware installations.

## Quick Start

### 1. Use the New Installation System

```bash
# Run the new v2.0 installer
./install-v2.sh

# Or with options
./install-v2.sh --verbose           # Verbose logging
./install-v2.sh --core-only         # Core components only
./install-v2.sh --skip-optional     # Skip optional components
./install-v2.sh --non-interactive   # Automated mode
```

### 2. Validate Installation

```bash
# Comprehensive validation
./scripts/validate-installation.sh

# Quick validation
./scripts/validate-installation.sh --quick

# Category-specific validation
./scripts/validate-installation.sh --category system
```

## Installation Architecture

### Directory Structure

```
hivestudio-script/
├── install/                    # New installation system
│   ├── main-installer.sh      # Main orchestrator
│   ├── core/                  # Core installation modules
│   │   └── environment.sh     # Environment detection
│   ├── optional/              # Optional component installers
│   │   ├── claude-cli.sh      # Claude CLI installation
│   │   └── mcp-servers.sh     # MCP servers setup
│   └── utils/                 # Utility modules
│       ├── logger.sh          # Enhanced logging
│       ├── retry.sh           # Retry mechanisms
│       └── validate.sh        # Validation functions
├── install-v2.sh              # New installation entry point
├── scripts/
│   └── validate-installation.sh  # Validation script
└── docs/
    ├── INSTALLATION-ARCHITECTURE.md
    └── IMPLEMENTATION-GUIDE.md
```

### Key Improvements

#### 1. Progressive Installation
- **Core First**: Essential components install before optional ones
- **Graceful Degradation**: System works even if optional components fail
- **Modular Design**: Each component can be installed independently

#### 2. Environment Intelligence
- **Auto-Detection**: Identifies Codespaces, Docker, macOS, Linux
- **Adaptive Configuration**: Adjusts strategies per environment
- **Optimized Paths**: Uses best installation methods for each environment

#### 3. Error Resilience
- **Retry Mechanisms**: Automatic retry with exponential backoff
- **Circuit Breaker**: Prevents cascading failures
- **Fallback Strategies**: Multiple installation paths per component

## Implementation Details

### 1. Environment Detection

The system automatically detects and configures for:

#### GitHub Codespaces
```bash
# Detected environment variables
CODESPACES=true
GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN=...

# Automatic configurations:
# - NPM global prefix to avoid permissions
# - Skip Homebrew (not available)
# - Use npm as primary installation method
# - Non-interactive mode
```

#### Docker Containers
```bash
# Detection: /.dockerenv file or DOCKER_CONTAINER env var
# Configurations:
# - Minimal system dependencies
# - Efficient caching
# - Non-interactive installation
# - Reduced timeouts
```

#### macOS
```bash
# Detection: darwin* OSTYPE
# Configurations:
# - Xcode Command Line Tools check
# - Homebrew preference
# - Security prompt handling
# - Path optimizations
```

#### Linux
```bash
# Detection: linux-gnu* OSTYPE + /etc/os-release
# Configurations:
# - Package manager detection (apt/yum/pacman)
# - NPM global prefix setup
# - Distribution-specific optimizations
```

### 2. Installation Phases

#### Phase 1: Pre-flight Checks
```bash
# Validates:
# - Node.js 18+ availability
# - npm 8+ availability
# - Git availability
# - Network connectivity
# - Disk space (1GB minimum)
# - Memory (2GB recommended)
# - File permissions
```

#### Phase 2: Environment Configuration
```bash
# Configures:
# - Environment-specific settings
# - NPM global directories
# - PATH optimizations
# - Proxy settings (if needed)
# - Performance optimizations
```

#### Phase 3: Core Installation
```bash
# Installs:
# - Node.js validation
# - npm validation
# - Project dependencies
# - Project structure
```

#### Phase 4: Optional Components
```bash
# Installs (with graceful failure):
# - Claude CLI (multiple methods)
# - MCP servers (claude-flow, ruv-swarm, flow-nexus)
# - GitHub integration
# - Advanced features
```

#### Phase 5: Validation & Configuration
```bash
# Performs:
# - Component validation
# - Configuration file creation
# - Final health checks
# - Report generation
```

### 3. Retry Mechanisms

#### Exponential Backoff
```bash
# Network operations: 1s, 2s, 4s, 8s delays
# Package installs: 3s, 6s, 12s, 24s delays
# File operations: 1s, 2s, 3s delays (linear)
```

#### Circuit Breaker
```bash
# Opens after 5 consecutive failures
# Prevents cascading failures
# Protects system resources
# Provides clear error messages
```

#### Method Fallbacks
```bash
# Claude CLI installation order (Codespaces):
# 1. npm global
# 2. npm local
# 3. curl installation
# 4. Manual instructions

# Claude CLI installation order (macOS):
# 1. Homebrew
# 2. npm global
# 3. curl installation
# 4. Manual instructions
```

## Usage Examples

### Standard Installation
```bash
./install-v2.sh
```
- Full installation with all components
- Interactive mode with progress updates
- Automatic environment detection
- Comprehensive validation

### Quick Setup (Core Only)
```bash
./install-v2.sh --core-only --non-interactive
```
- Essential components only
- No user interaction required
- Fast installation for CI/CD
- Basic functionality guaranteed

### Development Setup
```bash
./install-v2.sh --verbose
# Followed by:
./scripts/validate-installation.sh --verbose
```
- Detailed logging for troubleshooting
- Comprehensive validation
- Development-ready environment
- Full feature set

### Codespaces Optimized
```bash
# Automatically detected and configured
./install-v2.sh --non-interactive
```
- Optimized for remote development
- No Homebrew dependency
- Fast startup
- Minimal user interaction

## Validation and Health Checks

### Validation Categories

#### System Validation
```bash
./scripts/validate-installation.sh --category system
```
- Operating system compatibility
- Memory and disk requirements
- Network connectivity
- Permission checks

#### Dependencies Validation
```bash
./scripts/validate-installation.sh --category dependencies
```
- Node.js version compliance
- npm functionality
- Package dependencies
- Global packages

#### Tools Validation
```bash
./scripts/validate-installation.sh --category tools
```
- Claude CLI installation
- MCP servers configuration
- Development tools availability

#### Functionality Validation
```bash
./scripts/validate-installation.sh --category functionality
```
- npm script execution
- Claude CLI functionality
- Project functionality
- Integration tests

### Health Check Monitoring

#### Quick Health Check
```bash
./scripts/validate-installation.sh --quick
```
- Essential components only
- Fast execution (< 30 seconds)
- Critical issues detection
- CI/CD friendly

#### Continuous Monitoring
```bash
# Add to cron or systemd timer
*/30 * * * * /path/to/hivestudio/scripts/validate-installation.sh --quick --non-interactive
```

## Troubleshooting

### Common Issues

#### 1. Node.js Version Issues
```bash
# Problem: Node.js version too old
# Solution: Update Node.js
curl -fsSL https://nodejs.org/dist/latest-v18.x/ | grep node-v18

# Or use version manager
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
nvm use 18
```

#### 2. npm Permission Issues
```bash
# Problem: npm global install fails with EACCES
# Solution: Configure npm prefix (automatic in v2.0)
npm config set prefix ~/.npm-global
export PATH=~/.npm-global/bin:$PATH
```

#### 3. Claude CLI Installation Failures
```bash
# Problem: All installation methods fail
# Solution: Manual installation
npm install -g @anthropic-ai/claude-code

# Or use local installation
npm install @anthropic-ai/claude-code
export PATH=./node_modules/.bin:$PATH
```

#### 4. MCP Server Configuration Issues
```bash
# Problem: MCP servers not loading
# Solution: Verify Claude CLI and re-install
claude mcp list
claude mcp remove claude-flow
claude mcp add claude-flow "npx claude-flow@alpha mcp start"
```

#### 5. Network Connectivity Issues
```bash
# Problem: Cannot reach npm registry
# Solution: Configure proxy or alternate registry
npm config set registry https://registry.npmjs.org/
npm config set proxy http://proxy.company.com:8080
npm config set https-proxy http://proxy.company.com:8080
```

### Environment-Specific Issues

#### GitHub Codespaces
```bash
# Issue: Claude CLI not in PATH after installation
# Solution: Update PATH and restart terminal
export PATH="$HOME/.npm-global/bin:$PATH"
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
```

#### Docker Containers
```bash
# Issue: Permission denied for global installs
# Solution: Use local installation or adjust Dockerfile
RUN npm config set prefix /usr/local
RUN npm install -g @anthropic-ai/claude-code
```

#### macOS
```bash
# Issue: Xcode Command Line Tools missing
# Solution: Install command line tools
xcode-select --install

# Issue: Homebrew not found
# Solution: Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Debugging Tips

#### Enable Verbose Logging
```bash
export HIVESTUDIO_LOG_LEVEL=0  # Debug level
./install-v2.sh --verbose
```

#### Check Installation Logs
```bash
# Default log location
tail -f /tmp/hivestudio-install.log

# Custom log location
export HIVESTUDIO_LOG_FILE="/path/to/custom.log"
./install-v2.sh
```

#### Manual Component Testing
```bash
# Test individual components
source install/utils/logger.sh
source install/optional/claude-cli.sh
install_claude_cli

# Test validation functions
source install/utils/validate.sh
validate_nodejs 18
```

## Migration from v1.0

### Backup Current Installation
```bash
# Backup current configuration
cp -r .claude .claude-backup
cp package.json package.json.backup
cp .env .env.backup 2>/dev/null || true
```

### Migration Steps
1. **Run v2.0 installer**: `./install-v2.sh`
2. **Validate installation**: `./scripts/validate-installation.sh`
3. **Update scripts**: Use new validation and setup scripts
4. **Configure environment**: Review and update .env files
5. **Test functionality**: Verify all features work as expected

### Benefits of Migration
- **Improved Reliability**: Better error handling and retry mechanisms
- **Environment Awareness**: Automatic configuration for different environments
- **Better Logging**: Comprehensive logging and debugging capabilities
- **Progressive Installation**: Core functionality available even if optional components fail
- **Validation Tools**: Built-in health checking and validation

## Advanced Configuration

### Custom Environment Variables
```bash
# Installation behavior
export HIVESTUDIO_LOG_LEVEL=0          # Debug logging
export SKIP_OPTIONAL=true              # Skip optional components
export CORE_ONLY=true                  # Core components only
export NON_INTERACTIVE=true            # No user prompts

# Component preferences
export CLAUDE_INSTALL_METHOD="npm"     # Force npm installation
export SKIP_HOMEBREW=true              # Skip Homebrew usage
export NPM_CONFIG_PREFIX="$HOME/.npm"  # Custom npm prefix

# Network configuration
export HTTP_PROXY="http://proxy:8080"  # HTTP proxy
export HTTPS_PROXY="http://proxy:8080" # HTTPS proxy
export MCP_TIMEOUT=60                  # MCP server timeout
```

### Custom Installation Paths
```bash
# Custom project structure
export HIVESTUDIO_SRC_DIR="./source"
export HIVESTUDIO_TEST_DIR="./testing"
export HIVESTUDIO_DOC_DIR="./documentation"

# Custom tool installations
export CLAUDE_CLI_PATH="/custom/path/to/claude"
export MCP_CONFIG_DIR="/custom/mcp/config"
```

## Performance Optimization

### Parallel Installation
```bash
# Enable parallel component installation
export MCP_PARALLEL=true
export NPM_CONFIG_MAXSOCKETS=15
export NPM_CONFIG_JOBS=4
```

### Caching Optimization
```bash
# Aggressive caching for faster reinstalls
export NPM_CONFIG_CACHE_MIN=86400      # 24 hours
export MCP_CACHE_ENABLED=true
export HIVESTUDIO_CACHE_DIR="/tmp/hivestudio-cache"
```

### Resource Optimization
```bash
# Memory-constrained environments
export NODE_OPTIONS="--max-old-space-size=1024"
export NPM_CONFIG_MAXSOCKETS=5
export MCP_TIMEOUT=30
```

## Integration with CI/CD

### GitHub Actions
```yaml
name: HiveStudio Setup
on: [push, pull_request]

jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install HiveStudio
        run: ./install-v2.sh --core-only --non-interactive
      - name: Validate Installation
        run: ./scripts/validate-installation.sh --quick
```

### Docker
```dockerfile
FROM node:18-alpine

WORKDIR /app
COPY . .

# Install HiveStudio with Docker optimizations
ENV DOCKER_CONTAINER=true
ENV NON_INTERACTIVE=true
RUN ./install-v2.sh --core-only

# Validate installation
RUN ./scripts/validate-installation.sh --quick

EXPOSE 3000
CMD ["npm", "start"]
```

### Jenkins
```groovy
pipeline {
    agent any
    stages {
        stage('Setup') {
            steps {
                sh './install-v2.sh --non-interactive'
                sh './scripts/validate-installation.sh'
            }
        }
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
    }
}
```

## Monitoring and Maintenance

### Automated Health Checks
```bash
#!/bin/bash
# health-check.sh - Regular system health monitoring

./scripts/validate-installation.sh --quick --non-interactive
exit_code=$?

if [ $exit_code -ne 0 ]; then
    echo "Health check failed - triggering maintenance"
    ./install-v2.sh --core-only --non-interactive
fi
```

### Log Rotation
```bash
# logrotate configuration for /etc/logrotate.d/hivestudio
/tmp/hivestudio-install.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 user group
}
```

### Update Automation
```bash
#!/bin/bash
# update-hivestudio.sh - Automated updates

# Pull latest changes
git pull origin main

# Backup current configuration
cp .env .env.backup
cp package.json package.json.backup

# Run installation with updates
./install-v2.sh --non-interactive

# Validate
if ./scripts/validate-installation.sh --quick; then
    echo "Update successful"
else
    echo "Update failed - rolling back"
    cp .env.backup .env
    cp package.json.backup package.json
    npm install
fi
```

## Support and Contributing

### Getting Help
1. **Check logs**: Review installation logs for detailed error information
2. **Run validation**: Use validation script to identify specific issues
3. **Review documentation**: Check architecture and implementation guides
4. **Search issues**: Look for similar problems in GitHub issues
5. **Create issue**: Provide detailed information and logs

### Contributing Improvements
1. **Fork repository**: Create your own copy for modifications
2. **Test changes**: Use validation scripts to verify improvements
3. **Document changes**: Update relevant documentation
4. **Submit PR**: Include detailed description and test results

### Best Practices for Extensions
- Follow modular design patterns
- Include comprehensive error handling
- Add validation functions for new components
- Maintain environment compatibility
- Document configuration options
- Include rollback procedures