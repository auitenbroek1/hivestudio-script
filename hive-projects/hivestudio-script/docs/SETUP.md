# Claude Code Ecosystem Setup Guide

A comprehensive guide for setting up the complete Claude Code development environment with SPARC methodology, Claude Flow orchestration, and MCP server integration.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation Methods](#installation-methods)
- [Configuration](#configuration)
- [Validation](#validation)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)
- [Advanced Features](#advanced-features)

## Overview

The Claude Code Ecosystem provides a complete development environment that combines:

- **Claude CLI**: Official Anthropic CLI for Claude interactions
- **Claude Flow**: Advanced orchestration with SPARC methodology
- **MCP Servers**: Model Context Protocol for extended capabilities
- **DevContainer**: GitHub Codespaces integration
- **SPARC Framework**: Systematic development methodology

### Key Features

- 🚀 **Parallel Agent Execution**: 2.8-4.4x speed improvement
- 🧠 **Neural Pattern Training**: 27+ neural models for optimization
- 📊 **Performance Analytics**: Comprehensive metrics and bottleneck analysis
- 🔗 **GitHub Integration**: Automated workflows and code review
- 🛡️ **Self-Healing**: Automatic error recovery and optimization
- 💾 **Cross-Session Memory**: Persistent context and learning

## Prerequisites

### System Requirements

- **Operating System**: Linux, macOS, or Windows (WSL2)
- **Node.js**: Version 18.0.0 or higher
- **npm**: Version 8.0.0 or higher
- **Git**: Version 2.0.0 or higher
- **Python**: Version 3.8+ (optional, for advanced features)

### Account Requirements

- **Anthropic Account**: For Claude CLI authentication
- **GitHub Account**: For repository integration (optional)
- **Flow-Nexus Account**: For cloud features (optional)

## Installation Methods

### Method 1: GitHub Codespaces (Recommended)

The ecosystem is pre-configured for GitHub Codespaces with automatic setup:

1. **Create Codespace**:
   ```bash
   # Click "Create codespace" button in GitHub repo
   # Or use CLI:
   gh codespace create
   ```

2. **Automatic Setup**: The devcontainer automatically runs:
   - `.devcontainer/setup.sh` - Initial setup
   - `.claude/setup-ecosystem.sh` - Ecosystem configuration
   - `.devcontainer/startup.sh` - Service startup

3. **Verification**:
   ```bash
   .claude/validate.sh
   ```

### Method 2: Local Development

For local development environments:

1. **Clone Repository**:
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. **Run Setup**:
   ```bash
   chmod +x .claude/setup-ecosystem.sh
   .claude/setup-ecosystem.sh
   ```

3. **Install Dependencies**:
   ```bash
   npm install
   ```

### Method 3: Manual Installation

Step-by-step manual setup:

1. **Install Claude CLI**:
   ```bash
   curl -fsSL https://claude.ai/install.sh | bash
   export PATH="$HOME/.claude/bin:$PATH"
   ```

2. **Install Claude Flow**:
   ```bash
   npm install -g claude-flow@alpha
   ```

3. **Configure MCP Servers**:
   ```bash
   claude mcp add claude-flow "npx claude-flow@alpha mcp start"
   ```

4. **Setup Project Structure**:
   ```bash
   mkdir -p src tests docs config scripts examples
   ```

## Configuration

### Claude CLI Authentication

1. **Login to Claude**:
   ```bash
   claude auth login
   ```

2. **Verify Authentication**:
   ```bash
   claude auth status
   ```

### MCP Server Configuration

The ecosystem supports multiple MCP servers:

#### Core Servers (Required)

```bash
# Claude Flow (required)
claude mcp add claude-flow "npx claude-flow@alpha mcp start"
```

#### Optional Servers

```bash
# RUV Swarm (enhanced coordination)
npm install -g ruv-swarm
claude mcp add ruv-swarm "npx ruv-swarm mcp start"

# Flow Nexus (cloud features)
npm install -g flow-nexus@latest
claude mcp add flow-nexus "npx flow-nexus@latest mcp start"
```

### Environment Variables

Create `.env` file based on `.env.example`:

```bash
cp .env.example .env
```

Key configuration options:

```env
# Claude Configuration
CLAUDE_API_KEY=your_api_key_here
CLAUDE_MODEL=claude-3-sonnet-20240229

# Claude Flow Configuration
CLAUDE_FLOW_MODE=development
CLAUDE_FLOW_LOG_LEVEL=info

# GitHub Integration (optional)
GITHUB_TOKEN=your_github_token_here
```

### Project Configuration

#### TypeScript Configuration

The ecosystem includes a pre-configured `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "declaration": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
```

#### Package.json Scripts

Available npm scripts:

```bash
npm run build        # Build project
npm run test         # Run tests
npm run lint         # Code linting
npm run typecheck    # Type checking
npm run dev          # Development server
npm run claude:sparc # SPARC modes
npm run claude:validate # Validate ecosystem
npm run claude:update   # Update ecosystem
```

## Validation

### Automatic Validation

Run the comprehensive validation script:

```bash
.claude/validate.sh
```

Options:
- `--quiet`: Suppress non-essential output
- `--verbose`: Show detailed debug information
- `--help`: Display help information

### Manual Validation

Check individual components:

```bash
# Claude CLI
claude --version
claude auth status

# Claude Flow
npx claude-flow --version
npx claude-flow sparc modes

# MCP Servers
claude mcp list
claude mcp test claude-flow

# Project Structure
ls -la src/ tests/ docs/
```

### Validation Results

The validator checks:

- ✅ **Core System**: Node.js, npm, Git, Python
- ✅ **Claude CLI**: Installation and authentication
- ✅ **Claude Flow**: Installation and SPARC modes
- ✅ **MCP Servers**: Configuration and responsiveness
- ✅ **Project Structure**: Directories and files
- ✅ **Dependencies**: Package installations
- ✅ **Environment**: Configuration files
- ✅ **Git**: Repository and hooks
- ✅ **DevContainer**: Configuration files
- ✅ **Scripts**: Permissions and execution
- ✅ **Documentation**: Required files

## Usage Examples

### Basic SPARC Workflow

```bash
# List available SPARC modes
npx claude-flow sparc modes

# Run specification and pseudocode analysis
npx claude-flow sparc run spec-pseudocode "Create user authentication system"

# Run complete TDD workflow
npx claude-flow sparc tdd "User login feature with JWT tokens"

# Parallel execution of multiple modes
npx claude-flow sparc batch "spec,architect,refine" "API design task"
```

### Agent Orchestration

Using Claude Code's Task tool for parallel agent execution:

```javascript
// Spawn multiple agents concurrently
Task("Research agent", "Analyze authentication patterns and security best practices", "researcher")
Task("Architect agent", "Design system architecture for user management", "system-architect")
Task("Coder agent", "Implement JWT authentication with Express.js", "coder")
Task("Tester agent", "Create comprehensive test suite with security tests", "tester")
Task("Reviewer agent", "Review code quality and security vulnerabilities", "reviewer")
```

### MCP Server Integration

```bash
# Initialize swarm coordination
npx claude-flow swarm init --topology mesh --max-agents 5

# Spawn specialized agents
npx claude-flow agent spawn --type researcher --capabilities ["security", "authentication"]
npx claude-flow agent spawn --type coder --capabilities ["nodejs", "express", "jwt"]

# Orchestrate complex tasks
npx claude-flow task orchestrate "Build secure user authentication system" --strategy adaptive
```

### Memory and State Management

```bash
# Store project decisions
npx claude-flow memory store "auth-strategy" "JWT with refresh tokens" --namespace "project"

# Retrieve context
npx claude-flow memory retrieve "auth-strategy" --namespace "project"

# Search memory patterns
npx claude-flow memory search "authentication" --limit 10
```

### Performance Monitoring

```bash
# Generate performance report
npx claude-flow performance report --format detailed --timeframe 24h

# Analyze bottlenecks
npx claude-flow bottleneck analyze --component "task-orchestration"

# Track token usage
npx claude-flow token usage --operation "sparc-tdd" --timeframe 7d
```

## Troubleshooting

### Common Issues

#### 1. Claude CLI Authentication Failed

```bash
# Check current status
claude auth status

# Re-authenticate
claude auth logout
claude auth login

# Verify configuration
cat ~/.claude/auth.json
```

#### 2. MCP Server Not Responding

```bash
# Test individual server
claude mcp test claude-flow

# Restart MCP servers
claude mcp restart claude-flow

# Reconfigure server
claude mcp remove claude-flow
claude mcp add claude-flow "npx claude-flow@alpha mcp start"
```

#### 3. Claude Flow Installation Issues

```bash
# Clear npm cache
npm cache clean --force

# Reinstall with specific version
npm uninstall -g claude-flow
npm install -g claude-flow@alpha

# Check global packages
npm list -g --depth=0
```

#### 4. Permission Errors

```bash
# Fix script permissions
find .claude -name "*.sh" -exec chmod +x {} \;
find .devcontainer -name "*.sh" -exec chmod +x {} \;

# Fix npm permissions (Linux/macOS)
sudo chown -R $(whoami) ~/.npm
sudo chown -R $(whoami) /usr/local/lib/node_modules
```

#### 5. Node.js Version Issues

```bash
# Check current version
node --version

# Update Node.js using nvm
nvm install 20
nvm use 20
nvm alias default 20
```

### Debug Mode

Enable verbose logging for troubleshooting:

```bash
# Environment variables
export CLAUDE_FLOW_LOG_LEVEL=debug
export NODE_ENV=development

# Verbose validation
.claude/validate.sh --verbose

# Debug SPARC execution
npx claude-flow sparc run spec --debug "task description"
```

### Log Files

Check log files for detailed error information:

```bash
# Setup logs
cat ~/.claude/ecosystem-setup.log

# Validation logs
cat ~/.claude/last-validation.json

# Update logs
cat ~/.claude/update-*.log

# Claude Flow logs
cat ~/.claude-flow/logs/latest.log
```

## Advanced Features

### Neural Pattern Training

Train neural models for improved performance:

```bash
# Train coordination patterns
npx claude-flow neural train --pattern coordination --epochs 50

# Train optimization patterns
npx claude-flow neural train --pattern optimization --data "performance-data.json"

# Analyze cognitive patterns
npx claude-flow neural patterns --action analyze --operation "task-orchestration"
```

### GitHub Integration

Automate GitHub workflows:

```bash
# Analyze repository
npx claude-flow github repo-analyze --repo "owner/repo" --analysis-type code_quality

# Manage pull requests
npx claude-flow github pr-manage --repo "owner/repo" --action review --pr-number 123

# Create code review swarm
npx claude-flow github code-review --repo "owner/repo" --pr 123
```

### Distributed Agent Networks

Create distributed agent networks:

```bash
# Initialize distributed swarm
npx claude-flow daa agent-create --agent-type "distributed-researcher"

# Create autonomous workflows
npx claude-flow daa workflow-create --name "continuous-integration" --strategy adaptive

# Share knowledge between agents
npx claude-flow daa knowledge-share --source-agent "researcher-1" --target-agents "coder-1,tester-1"
```

### Custom Workflows

Create and manage custom workflows:

```bash
# Create workflow
npx claude-flow workflow create --name "full-stack-development" \
  --steps '[{"agent": "backend-dev", "task": "API"}, {"agent": "frontend-dev", "task": "UI"}]'

# Execute workflow
npx claude-flow workflow execute --workflow-id "workflow-123" --params '{"framework": "express"}'

# Monitor progress
npx claude-flow workflow status --workflow-id "workflow-123"
```

### Performance Optimization

Optimize ecosystem performance:

```bash
# Run benchmarks
npx claude-flow benchmark run --suite "full-system"

# Analyze trends
npx claude-flow trend analysis --metric "task-completion-time" --period "30d"

# Optimize topology
npx claude-flow topology optimize --swarm-id "swarm-123"
```

## Next Steps

After successful setup:

1. **Explore SPARC Modes**: Run `npx claude-flow sparc modes` to see available development modes
2. **Try Examples**: Start with simple tasks to understand the workflow
3. **Configure GitHub**: Set up repository integration for automated workflows
4. **Train Neural Models**: Use your project data to improve performance
5. **Join Community**: Connect with other Claude Code users for tips and best practices

## Support Resources

- **Documentation**: [Claude Flow GitHub](https://github.com/ruvnet/claude-flow)
- **Issues**: [Report Bugs](https://github.com/ruvnet/claude-flow/issues)
- **Community**: [Discussions](https://github.com/ruvnet/claude-flow/discussions)
- **Updates**: Run `.claude/update.sh` regularly for latest features

---

For additional help, run `.claude/validate.sh --help` or check the troubleshooting section above.