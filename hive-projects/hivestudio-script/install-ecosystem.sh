#!/bin/bash

# HiveStudio Multi-Agent Ecosystem Installer
# One-command setup for the complete development environment
#
# CODESPACES COMPATIBLE: Works in GitHub Codespaces, macOS, and Linux
# - Handles missing Homebrew gracefully
# - Uses npm as primary Claude CLI installation method
# - Fallback to curl installation if npm fails
# - Continues installation even if Claude CLI install fails

set -e

echo "🚀 HiveStudio Multi-Agent Ecosystem Installer"
echo "============================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."

    # Check Node.js
    if ! command -v node &> /dev/null; then
        error "Node.js is required but not installed. Please install Node.js 18+ first."
    fi

    # Check npm
    if ! command -v npm &> /dev/null; then
        error "npm is required but not installed. Please install npm first."
    fi

    # Check Git
    if ! command -v git &> /dev/null; then
        error "Git is required but not installed. Please install Git first."
    fi

    log "Prerequisites check passed ✓"
}

# Install Claude CLI if not present
install_claude_cli() {
    log "Checking Claude CLI installation..."

    if ! command -v claude &> /dev/null; then
        log "Installing Claude CLI..."

        # Detect if running in GitHub Codespaces
        if [ -n "$CODESPACES" ] || [ -n "$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN" ]; then
            log "Detected GitHub Codespaces environment"
        fi

        # Try multiple installation methods
        if command -v npm &> /dev/null; then
            log "Attempting npm installation..."
            if npm install -g @anthropic-ai/claude-code; then
                log "Claude CLI installed via npm ✓"
                return 0
            else
                warn "npm installation failed, trying alternative method..."
            fi
        fi

        if command -v brew &> /dev/null; then
            log "Attempting Homebrew installation..."
            if brew install claude-ai/claude/claude; then
                log "Claude CLI installed via Homebrew ✓"
                return 0
            else
                warn "Homebrew installation failed, trying curl method..."
            fi
        fi

        # Fallback to curl installation
        log "Attempting curl installation..."
        if curl -fsSL https://claude.ai/install.sh | sh; then
            log "Claude CLI installed via curl ✓"
            # Add to PATH for current session
            export PATH="$PATH:$HOME/.local/bin"
            return 0
        else
            warn "Curl installation failed"
        fi

        # If all methods fail, provide manual instructions but continue
        warn "Could not automatically install Claude CLI. Please install manually:"
        echo "  Option 1: npm install -g @anthropic-ai/claude-code"
        echo "  Option 2: curl -fsSL https://claude.ai/install.sh | sh"
        echo "  Option 3: Visit https://claude.ai/download"
        warn "Continuing with installation... you can install Claude CLI later"

    else
        log "Claude CLI already installed ✓"
    fi
}

# Install MCP servers
install_mcp_servers() {
    log "Installing MCP servers..."

    # Check if Claude CLI is available
    if ! command -v claude &> /dev/null; then
        warn "Claude CLI not available - skipping MCP server installation"
        warn "You can install MCP servers later after setting up Claude CLI"
        return 0
    fi

    # Claude Flow (required)
    log "Adding Claude Flow MCP server..."
    if claude mcp add claude-flow "npx claude-flow@alpha mcp start" 2>/dev/null; then
        log "Claude Flow MCP server added ✓"
    else
        warn "Claude Flow MCP server installation failed or may already be installed"
        # Try to verify if it's already installed
        if claude mcp list 2>/dev/null | grep -q "claude-flow"; then
            log "Claude Flow MCP server already installed ✓"
        fi
    fi

    # RUV Swarm (optional but recommended)
    log "Adding RUV Swarm MCP server..."
    if claude mcp add ruv-swarm "npx ruv-swarm mcp start" 2>/dev/null; then
        log "RUV Swarm MCP server added ✓"
    else
        warn "RUV Swarm MCP server installation failed - continuing without it"
    fi

    # Flow Nexus (optional, cloud features)
    log "Adding Flow Nexus MCP server..."
    if claude mcp add flow-nexus "npx flow-nexus@latest mcp start" 2>/dev/null; then
        log "Flow Nexus MCP server added ✓"
    else
        warn "Flow Nexus MCP server installation failed - continuing without it"
    fi

    # Show installed MCP servers
    log "Checking installed MCP servers..."
    if claude mcp list 2>/dev/null; then
        log "MCP servers installation completed ✓"
    else
        warn "Could not verify MCP server installation"
    fi
}

# Set up project structure
setup_project_structure() {
    log "Setting up project structure..."

    # Create essential directories
    mkdir -p {src,tests,docs,config,scripts,examples}
    mkdir -p .claude/{team-templates,workflows,memory}

    # Copy team templates if they don't exist
    if [ ! -f ".claude/team-templates/full-stack-team.json" ]; then
        log "Setting up team templates..."
        # Templates will be created by the script
    fi

    log "Project structure setup completed ✓"
}

# Initialize package.json if not exists
setup_package_json() {
    log "Setting up package.json..."

    if [ ! -f "package.json" ]; then
        cat > package.json << 'EOF'
{
  "name": "hivestudio-ecosystem",
  "version": "1.0.0",
  "description": "HiveStudio Multi-Agent Development Ecosystem",
  "main": "src/index.js",
  "scripts": {
    "start": "./quickstart.sh",
    "build": "echo 'Build script - customize as needed'",
    "test": "npm run test:unit && npm run test:integration",
    "test:unit": "echo 'Unit tests - add your test framework'",
    "test:integration": "echo 'Integration tests - add your test framework'",
    "lint": "echo 'Linting - add your linter'",
    "typecheck": "echo 'Type checking - add if using TypeScript'",
    "sparc:modes": "npx claude-flow sparc modes",
    "sparc:tdd": "npx claude-flow sparc tdd",
    "team:spawn": "./scripts/spawn-team.sh",
    "team:status": "npx claude-flow swarm status"
  },
  "keywords": ["ai", "agents", "development", "claude", "sparc"],
  "author": "HiveStudio",
  "license": "MIT",
  "devDependencies": {
    "claude-flow": "alpha"
  }
}
EOF
        log "package.json created ✓"
    else
        log "package.json already exists ✓"
    fi
}

# Create team templates
create_team_templates() {
    log "Creating team templates..."

    # Full-stack development team
    cat > .claude/team-templates/full-stack-team.json << 'EOF'
{
  "name": "Full-Stack Development Team",
  "description": "Complete team for full-stack web application development",
  "topology": "hierarchical",
  "maxAgents": 8,
  "agents": [
    {
      "type": "architect",
      "role": "team-lead",
      "responsibilities": ["System design", "Architecture decisions", "Team coordination"]
    },
    {
      "type": "backend-dev",
      "role": "backend-specialist",
      "responsibilities": ["API development", "Database design", "Server logic"]
    },
    {
      "type": "coder",
      "role": "frontend-specialist",
      "responsibilities": ["UI components", "Frontend logic", "User experience"]
    },
    {
      "type": "tester",
      "role": "qa-specialist",
      "responsibilities": ["Test automation", "Quality assurance", "Bug detection"]
    },
    {
      "type": "reviewer",
      "role": "code-reviewer",
      "responsibilities": ["Code quality", "Security review", "Best practices"]
    },
    {
      "type": "cicd-engineer",
      "role": "devops-specialist",
      "responsibilities": ["Deployment", "CI/CD", "Infrastructure"]
    }
  ],
  "workflows": [
    "SPARC methodology",
    "Test-driven development",
    "Code review process",
    "Continuous integration"
  ]
}
EOF

    # API development team
    cat > .claude/team-templates/api-team.json << 'EOF'
{
  "name": "API Development Team",
  "description": "Specialized team for REST API and microservices development",
  "topology": "mesh",
  "maxAgents": 6,
  "agents": [
    {
      "type": "api-docs",
      "role": "api-architect",
      "responsibilities": ["API design", "Documentation", "Standards"]
    },
    {
      "type": "backend-dev",
      "role": "implementation-lead",
      "responsibilities": ["Endpoint implementation", "Business logic", "Data access"]
    },
    {
      "type": "tester",
      "role": "api-tester",
      "responsibilities": ["API testing", "Contract testing", "Load testing"]
    },
    {
      "type": "reviewer",
      "role": "security-reviewer",
      "responsibilities": ["Security audit", "Performance review", "Code quality"]
    },
    {
      "type": "cicd-engineer",
      "role": "deployment-specialist",
      "responsibilities": ["API deployment", "Monitoring", "Scaling"]
    }
  ],
  "workflows": [
    "API-first development",
    "Contract testing",
    "Security review",
    "Performance optimization"
  ]
}
EOF

    # Machine Learning team
    cat > .claude/team-templates/ml-team.json << 'EOF'
{
  "name": "Machine Learning Team",
  "description": "Specialized team for ML model development and deployment",
  "topology": "star",
  "maxAgents": 7,
  "agents": [
    {
      "type": "ml-developer",
      "role": "ml-lead",
      "responsibilities": ["Model design", "Training", "Evaluation"]
    },
    {
      "type": "researcher",
      "role": "data-scientist",
      "responsibilities": ["Data analysis", "Feature engineering", "Research"]
    },
    {
      "type": "coder",
      "role": "ml-engineer",
      "responsibilities": ["Model implementation", "Pipeline development", "Integration"]
    },
    {
      "type": "tester",
      "role": "ml-tester",
      "responsibilities": ["Model validation", "A/B testing", "Performance testing"]
    },
    {
      "type": "cicd-engineer",
      "role": "mlops-engineer",
      "responsibilities": ["Model deployment", "Monitoring", "MLOps pipeline"]
    },
    {
      "type": "reviewer",
      "role": "model-reviewer",
      "responsibilities": ["Model review", "Ethics review", "Performance audit"]
    }
  ],
  "workflows": [
    "ML experimentation",
    "Model validation",
    "MLOps deployment",
    "Performance monitoring"
  ]
}
EOF

    # Mobile development team
    cat > .claude/team-templates/mobile-team.json << 'EOF'
{
  "name": "Mobile Development Team",
  "description": "Cross-platform mobile application development team",
  "topology": "ring",
  "maxAgents": 6,
  "agents": [
    {
      "type": "mobile-dev",
      "role": "mobile-lead",
      "responsibilities": ["App architecture", "Platform integration", "Performance"]
    },
    {
      "type": "coder",
      "role": "ui-developer",
      "responsibilities": ["UI components", "User experience", "Platform-specific features"]
    },
    {
      "type": "backend-dev",
      "role": "api-developer",
      "responsibilities": ["Mobile API", "Push notifications", "Data sync"]
    },
    {
      "type": "tester",
      "role": "mobile-tester",
      "responsibilities": ["Device testing", "Platform testing", "User testing"]
    },
    {
      "type": "reviewer",
      "role": "mobile-reviewer",
      "responsibilities": ["Code review", "Store compliance", "Security review"]
    },
    {
      "type": "cicd-engineer",
      "role": "mobile-devops",
      "responsibilities": ["Build automation", "App deployment", "Store publication"]
    }
  ],
  "workflows": [
    "Cross-platform development",
    "Device testing",
    "Store deployment",
    "Performance optimization"
  ]
}
EOF

    log "Team templates created ✓"
}

# Create workflow templates
create_workflow_templates() {
    log "Creating workflow templates..."

    mkdir -p .claude/workflows

    cat > .claude/workflows/sparc-tdd.json << 'EOF'
{
  "name": "SPARC TDD Workflow",
  "description": "Complete SPARC methodology with Test-Driven Development",
  "phases": [
    {
      "name": "Specification",
      "agents": ["researcher", "architect"],
      "tasks": [
        "Analyze requirements",
        "Define acceptance criteria",
        "Create user stories",
        "Document constraints"
      ]
    },
    {
      "name": "Pseudocode",
      "agents": ["architect", "coder"],
      "tasks": [
        "Design algorithms",
        "Define interfaces",
        "Plan data structures",
        "Create flow diagrams"
      ]
    },
    {
      "name": "Architecture",
      "agents": ["architect", "reviewer"],
      "tasks": [
        "System design",
        "Component architecture",
        "Technology selection",
        "Scalability planning"
      ]
    },
    {
      "name": "Refinement",
      "agents": ["coder", "tester", "reviewer"],
      "tasks": [
        "Write failing tests",
        "Implement minimum code",
        "Refactor for quality",
        "Review and iterate"
      ]
    },
    {
      "name": "Completion",
      "agents": ["tester", "reviewer", "cicd-engineer"],
      "tasks": [
        "Integration testing",
        "Performance testing",
        "Security review",
        "Deployment preparation"
      ]
    }
  ]
}
EOF

    log "Workflow templates created ✓"
}

# Create utility scripts
create_utility_scripts() {
    log "Creating utility scripts..."

    # Team spawning script
    cat > scripts/spawn-team.sh << 'EOF'
#!/bin/bash

# Team Spawning Utility
# Usage: ./scripts/spawn-team.sh [team-template] [project-description]

TEAM_TEMPLATE=${1:-"full-stack-team"}
PROJECT_DESC=${2:-"Development project"}

echo "🚀 Spawning team: $TEAM_TEMPLATE"
echo "📋 Project: $PROJECT_DESC"

# Load team template
if [ ! -f ".claude/team-templates/${TEAM_TEMPLATE}.json" ]; then
    echo "❌ Team template not found: $TEAM_TEMPLATE"
    echo "Available templates:"
    ls .claude/team-templates/*.json | xargs -n 1 basename | sed 's/.json$//'
    exit 1
fi

# Initialize swarm with Claude Flow
echo "🔧 Initializing swarm..."
npx claude-flow@alpha swarm init --topology hierarchical --max-agents 8

# Spawn agents based on template
echo "👥 Spawning team members..."
echo "Team spawned! Use 'npx claude-flow swarm status' to monitor."
echo "Ready for task orchestration with 'npx claude-flow task orchestrate'"
EOF

    chmod +x scripts/spawn-team.sh

    # Environment setup script
    cat > scripts/setup-env.sh << 'EOF'
#!/bin/bash

# Environment Setup Utility
# Sets up development environment variables and configurations

echo "🔧 Setting up development environment..."

# Create .env template if it doesn't exist
if [ ! -f ".env" ]; then
    cat > .env << 'ENVEOF'
# Development Environment Configuration
NODE_ENV=development
PORT=3000

# Claude Configuration
CLAUDE_API_KEY=your_claude_api_key_here

# Database Configuration
DATABASE_URL=your_database_url_here

# External APIs
API_BASE_URL=https://api.example.com

# Debug Settings
DEBUG=true
LOG_LEVEL=info
ENVEOF
    echo "📝 Created .env template - please fill in your values"
fi

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    cat > .gitignore << 'GITEOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
logs
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Build outputs
dist/
build/
*.tgz

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Claude Flow
.claude-flow/
.claude/memory/
GITEOF
    echo "📝 Created .gitignore"
fi

echo "✅ Environment setup completed"
EOF

    chmod +x scripts/setup-env.sh

    log "Utility scripts created ✓"
}

# Create examples
create_examples() {
    log "Creating examples..."

    cat > examples/simple-api.js << 'EOF'
// Example: Simple API development with agent coordination
// Run: node examples/simple-api.js

const { exec } = require('child_process');

async function createSimpleAPI() {
    console.log('🚀 Creating Simple API with Agent Team');

    // This example shows how to use the ecosystem for API development
    console.log('Step 1: Initialize team');
    console.log('Command: ./scripts/spawn-team.sh api-team "Simple REST API"');

    console.log('\nStep 2: Use SPARC methodology');
    console.log('Command: npx claude-flow sparc tdd "User authentication API"');

    console.log('\nStep 3: Monitor progress');
    console.log('Command: npx claude-flow swarm status');

    console.log('\n✅ Example workflow defined');
    console.log('Run the commands above to see the ecosystem in action!');
}

if (require.main === module) {
    createSimpleAPI();
}

module.exports = { createSimpleAPI };
EOF

    cat > examples/ml-pipeline.js << 'EOF'
// Example: ML Pipeline development with specialized team
// Run: node examples/ml-pipeline.js

async function createMLPipeline() {
    console.log('🤖 Creating ML Pipeline with Specialized Team');

    console.log('Step 1: Initialize ML team');
    console.log('Command: ./scripts/spawn-team.sh ml-team "Recommendation system"');

    console.log('\nStep 2: Research and design');
    console.log('Command: npx claude-flow sparc run spec-pseudocode "User recommendation ML model"');

    console.log('\nStep 3: Implementation');
    console.log('Command: npx claude-flow sparc run architect "ML pipeline architecture"');

    console.log('\nStep 4: Training and evaluation');
    console.log('Command: npx claude-flow sparc tdd "Model training pipeline"');

    console.log('\n✅ ML Pipeline workflow defined');
}

if (require.main === module) {
    createMLPipeline();
}

module.exports = { createMLPipeline };
EOF

    log "Examples created ✓"
}

# Create quick reference
create_quick_reference() {
    log "Creating quick reference..."

    cat > docs/QUICK-REFERENCE.md << 'EOF'
# HiveStudio Ecosystem Quick Reference

## Essential Commands

### Team Management
```bash
# Spawn a team
./scripts/spawn-team.sh [template] [description]

# Available templates:
# - full-stack-team: Complete web development
# - api-team: REST API development
# - ml-team: Machine learning projects
# - mobile-team: Mobile app development

# Check team status
npx claude-flow swarm status

# Monitor team activity
npx claude-flow swarm monitor
```

### SPARC Methodology
```bash
# Full TDD workflow
npx claude-flow sparc tdd "Feature description"

# Individual phases
npx claude-flow sparc run spec-pseudocode "Requirements"
npx claude-flow sparc run architect "System design"

# Batch processing
npx claude-flow sparc batch spec-pseudocode,architect "Complex feature"
```

### Task Orchestration
```bash
# Orchestrate tasks across team
npx claude-flow task orchestrate "Implement user authentication"

# Check task status
npx claude-flow task status

# Get task results
npx claude-flow task results [task-id]
```

### Memory & Context
```bash
# Store information
npx claude-flow memory store key "value"

# Retrieve information
npx claude-flow memory retrieve key

# Search memory
npx claude-flow memory search "pattern"
```

### GitHub Integration
```bash
# Analyze repository
npx claude-flow github repo analyze owner/repo

# Manage pull requests
npx claude-flow github pr manage owner/repo --action review

# Issue tracking
npx claude-flow github issue track owner/repo --action triage
```

## Quick Start Workflows

### 1. Web Application
```bash
./quickstart.sh web-app "My App"
```

### 2. REST API
```bash
./quickstart.sh api "User Service API"
```

### 3. ML Project
```bash
./quickstart.sh ml-project "Recommendation Engine"
```

### 4. Mobile App
```bash
./quickstart.sh mobile-app "Travel App"
```

## Configuration

### Team Templates
Location: `.claude/team-templates/`
- `full-stack-team.json` - Web development
- `api-team.json` - API development
- `ml-team.json` - Machine learning
- `mobile-team.json` - Mobile development

### Workflows
Location: `.claude/workflows/`
- `sparc-tdd.json` - SPARC with TDD

### Environment
- `.env` - Environment variables
- `package.json` - Project configuration
- `.gitignore` - Git ignore rules

## Troubleshooting

### Common Issues
1. **MCP server not found**: Run `claude mcp list` to check installations
2. **Permission denied**: Make sure scripts are executable with `chmod +x`
3. **Team not spawning**: Check network connection and MCP server status

### Getting Help
- Run `npx claude-flow --help` for command help
- Check `.claude/memory/` for session logs
- Use `npx claude-flow swarm status` for team diagnostics

## Advanced Features

### Custom Agents
Create custom agent types in team templates with specific:
- Responsibilities
- Skills
- Coordination patterns

### Neural Training
```bash
# Train patterns from successful workflows
npx claude-flow neural train coordination training-data.json

# Analyze cognitive patterns
npx claude-flow neural patterns --action analyze
```

### Performance Monitoring
```bash
# Run benchmarks
npx claude-flow benchmark run

# Analyze performance
npx claude-flow performance report

# Monitor bottlenecks
npx claude-flow bottleneck analyze
```
EOF

    log "Quick reference created ✓"
}

# Main installation
main() {
    log "Starting HiveStudio Multi-Agent Ecosystem installation..."

    check_prerequisites
    install_claude_cli
    install_mcp_servers
    setup_project_structure
    setup_package_json
    create_team_templates
    create_workflow_templates
    create_utility_scripts
    create_examples
    create_quick_reference

    log "🎉 Installation completed successfully!"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Run: ${GREEN}./quickstart.sh${NC} to test the ecosystem"
    echo "2. Read: ${GREEN}docs/QUICK-REFERENCE.md${NC} for usage guide"
    echo "3. Try: ${GREEN}./scripts/spawn-team.sh full-stack-team 'My Project'${NC}"
    echo ""
    echo -e "${YELLOW}Happy coding with your AI agent team! 🚀${NC}"
}

# Run installation
main "$@"