# HiveStudio Stage 1: System Preparation

This directory contains documentation for Stage 1 of the HiveStudio installation system.

## Overview

Stage 1 is the first phase of the two-stage HiveStudio installation process. It focuses on system preparation and ensuring all prerequisites are met before handing off to Stage 2 for the intelligent installation.

## Purpose and Scope

### What Stage 1 Does ✅

- **System Prerequisites Validation**: Validates Node.js, npm, Git, curl, and other essential tools
- **Platform Detection**: Identifies the operating system and applies platform-specific checks
- **Network Connectivity Testing**: Verifies access to npm registry, GitHub, and Claude.ai
- **Claude Code Installation**: Installs Claude Code CLI using multiple strategies
- **Authentication Verification**: Ensures Claude Code is properly authenticated
- **Environment Preparation**: Sets up the environment for Stage 2 handoff
- **Handoff Data Creation**: Generates structured data for Stage 2 consumption

### What Stage 1 Doesn't Do ❌

- **MCP Server Installation**: Deferred to Stage 2 for intelligent handling
- **Project Structure Creation**: Handled by Stage 2 with Claude intelligence
- **Complex Error Recovery**: Basic error handling only; intelligent recovery in Stage 2
- **Integration Configuration**: Stage 2 handles with contextual awareness
- **Advanced Features Setup**: Claude Code features configured in Stage 2

## Prerequisites

Before running Stage 1, ensure you have:

- **Operating System**: macOS, Linux, or Windows (with WSL recommended)
- **Internet Connection**: Required for downloading dependencies
- **Administrative Privileges**: May be needed for global package installation
- **Disk Space**: At least 2GB available space
- **Terminal Access**: Command line interface required

### Minimum System Requirements

| Component | Minimum Version | Recommended |
|-----------|----------------|-------------|
| Node.js   | 18.0.0         | 20.0.0+     |
| npm       | 8.0.0          | 9.0.0+      |
| Git       | 2.0.0          | 2.40.0+     |
| curl      | 7.0.0          | Latest      |

## Usage Instructions

### Direct Execution

```bash
# Run Stage 1 directly
./scripts/stage1-system-preparation.sh
```

### Via Main Installer

```bash
# Run complete two-stage installation
./install-ecosystem.sh
```

### Verification Before Running

```bash
# Validate installation readiness
./scripts/validate-two-stage-installation.sh
```

## Installation Process Flow

### Phase 1: Prerequisites Validation
1. **System Requirements Check**
   - Node.js version validation
   - npm availability and version
   - Git installation and version
   - curl availability for downloads

2. **Platform-Specific Validation**
   - macOS: Xcode Command Line Tools
   - Linux: Development tools and libraries
   - Windows: WSL compatibility checks

3. **Network Connectivity Tests**
   - GitHub accessibility
   - npm registry connectivity
   - Claude.ai service availability

4. **Permissions and Disk Space**
   - Write permissions in current directory
   - Temporary file creation capability
   - Available disk space verification

### Phase 2: Claude Code Installation

1. **Installation Strategy Selection**
   - Primary: npm global installation
   - Fallback 1: Homebrew (macOS)
   - Fallback 2: Direct curl installation

2. **Installation Execution**
   - Attempt each strategy sequentially
   - Verify successful installation
   - Update system PATH if necessary

3. **Post-Installation Verification**
   - Claude CLI availability
   - Version information retrieval
   - Basic functionality testing

### Phase 3: Claude Code Launch and Authentication

1. **Launch Process**
   - Start Claude Code application
   - Background daemon initialization
   - Startup completion verification

2. **Authentication Checkpoint**
   - Authentication status verification
   - Subscription tier detection
   - User guidance for manual steps

3. **Readiness Confirmation**
   - Full functionality verification
   - Service availability confirmation

### Phase 4: Handoff Preparation

1. **Environment Data Collection**
   - System information gathering
   - Installation status documentation
   - Configuration metadata creation

2. **Handoff File Generation**
   - Structured JSON data creation
   - Timestamp and version information
   - Stage 2 instruction preparation

3. **User Guidance Display**
   - Clear next steps presentation
   - Stage 2 execution instructions
   - Benefit explanation for Claude Code usage

## Troubleshooting Guide

### Common Issues

#### 1. Node.js Not Found
```bash
# Install Node.js via nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install --lts
nvm use --lts
```

#### 2. npm Permission Issues
```bash
# Fix npm global permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

#### 3. Claude Code Installation Fails
```bash
# Manual installation methods
# Method 1: Direct npm
npm install -g @anthropic-ai/claude-code

# Method 2: Homebrew (macOS)
brew install claude-ai/claude/claude

# Method 3: Direct download
curl -fsSL https://claude.ai/install.sh | sh
```

#### 4. Network Connectivity Issues
```bash
# Test connectivity
curl -I https://github.com
curl -I https://registry.npmjs.org
curl -I https://claude.ai

# Configure proxy if needed
npm config set proxy http://proxy.company.com:8080
npm config set https-proxy http://proxy.company.com:8080
```

#### 5. Authentication Problems
- **Solution**: Ensure Claude Code is open and complete sign-in process
- **Check**: Verify Pro/Max subscription for optimal experience
- **Retry**: Authentication status check with `claude auth status`

### Error Codes and Solutions

| Error Code | Description | Solution |
|------------|-------------|----------|
| EXIT_1     | Prerequisites failed | Install missing dependencies |
| EXIT_2     | Claude installation failed | Try manual installation methods |
| EXIT_3     | Launch failed | Check port availability, restart terminal |
| EXIT_4     | Authentication failed | Complete Claude Code sign-in process |

### Platform-Specific Notes

#### macOS
- **Xcode Command Line Tools**: Run `xcode-select --install` if missing
- **Homebrew**: Preferred for package management
- **Permissions**: Use `sudo` carefully, prefer user-level installations

#### Linux (Ubuntu/Debian)
```bash
# Install dependencies
sudo apt update
sudo apt install curl git build-essential

# For GitHub Codespaces
# Dependencies are typically pre-installed
```

#### Windows (WSL)
```bash
# Use WSL 2 for best compatibility
wsl --install -d Ubuntu

# Install Node.js in WSL
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Performance Optimization

#### Speeding Up Installation
1. **Use Package Manager**: Prefer Homebrew on macOS
2. **Clear npm Cache**: Run `npm cache clean --force`
3. **Use Fast Internet**: Ensure stable, high-speed connection
4. **Close Other Applications**: Free up system resources

#### Resource Management
- **Memory**: Ensure at least 4GB available RAM
- **CPU**: Installation benefits from multi-core processors
- **Storage**: SSD recommended for faster I/O operations

## Validation and Testing

### Pre-Installation Validation
```bash
# Run comprehensive validation
./scripts/validate-two-stage-installation.sh

# Check specific components
node --version
npm --version
git --version
curl --version
```

### Post-Installation Verification
```bash
# Verify Claude Code installation
claude --version
claude status
claude auth status

# Check handoff file
cat .hivestudio-stage1-complete
```

### Environment Testing
```bash
# Test network connectivity
curl -s https://github.com >/dev/null && echo "GitHub: OK"
curl -s https://registry.npmjs.org >/dev/null && echo "npm: OK"

# Test write permissions
touch .test-write && rm .test-write && echo "Write: OK"
```

## Integration with Stage 2

Stage 1 creates essential handoff data that Stage 2 relies on:

- **System Information**: OS, versions, architecture
- **Installation Status**: What was successfully installed
- **Configuration Data**: Environment variables and settings
- **Next Steps**: Clear instructions for Stage 2 execution

See [HANDOFF-SPEC.md](./HANDOFF-SPEC.md) for detailed handoff mechanism documentation.

## Security Considerations

### Safe Installation Practices
- **Verify Sources**: Only download from official repositories
- **Check Signatures**: Validate package integrity when possible
- **Use HTTPS**: All downloads use secure connections
- **Minimize Privileges**: Avoid unnecessary sudo usage

### Data Protection
- **No Secrets Storage**: Stage 1 doesn't store sensitive data
- **Temporary Files**: Cleaned up automatically
- **Permissions**: Proper file permission setting

## Support and Resources

### Documentation
- [HANDOFF-SPEC.md](./HANDOFF-SPEC.md): Stage 1 to Stage 2 handoff details
- [TESTING.md](./TESTING.md): Comprehensive testing procedures
- [Main README](../README.md): Project overview and setup

### Getting Help
1. **Check Logs**: Review console output for specific errors
2. **Run Validation**: Use validation script for diagnosis
3. **Manual Steps**: Follow manual installation guides
4. **Community Support**: GitHub Issues for persistent problems

### Related Scripts
- `scripts/stage1-system-preparation.sh`: Main Stage 1 script
- `scripts/validate-two-stage-installation.sh`: Validation utility
- `install-ecosystem.sh`: Complete two-stage installer

## Changelog

### Version 1.0.0
- Initial two-stage installation system
- Comprehensive prerequisite validation
- Multi-strategy Claude Code installation
- Intelligent error handling and recovery
- Platform-specific optimizations
- Structured handoff mechanism

---

**Next Step**: After successful Stage 1 completion, proceed to Stage 2 by running `hivestudio-install` inside Claude Code for intelligent installation with AI assistance.