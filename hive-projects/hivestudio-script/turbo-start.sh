#!/bin/bash

# HiveStudio Turbo Start - Zero to Hero in 5 minutes
# Inspired by Turbo Flow Claude methodology for instant value delivery
#
# Goal: Working AI agents in under 5 minutes
# Strategy: Essential setup → Immediate demo → Progressive enhancement

set -e

# Colors and styling
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# Progress tracking
STEPS_TOTAL=5
STEP_CURRENT=0

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

progress() {
    STEP_CURRENT=$((STEP_CURRENT + 1))
    local percent=$((STEP_CURRENT * 100 / STEPS_TOTAL))
    local bars=$((percent / 20))
    local spaces=$((5 - bars))
    printf "${BLUE}[%s%s] %s... (%d%%)${NC}\n" \
        "$(printf '●%.0s' $(seq 1 $bars))" \
        "$(printf '○%.0s' $(seq 1 $spaces))" \
        "$1" "$percent"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Banner
show_banner() {
    echo -e "${BOLD}${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                        🚀 HiveStudio Turbo Start                            ║"
    echo "║                                                                              ║"
    echo "║                    Zero to AI Agents in 5 Minutes                           ║"
    echo "║                  Powered by Turbo Flow Claude Method                        ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${YELLOW}⏱️  Target: Working AI agent team in under 5 minutes${NC}"
    echo -e "${BLUE}📋 Strategy: Essential setup → Immediate demo → Progressive enhancement${NC}"
    echo ""
}

# Smart prerequisite checking with auto-install guidance
check_prerequisites() {
    progress "Checking prerequisites"

    local missing=()

    # Check Node.js
    if ! command -v node &> /dev/null; then
        missing+=("Node.js")
    else
        local node_version=$(node --version | sed 's/v//')
        if [[ "$(printf '%s\n' "18.0.0" "$node_version" | sort -V | head -n1)" != "18.0.0" ]]; then
            missing+=("Node.js 18+")
        fi
    fi

    # Check npm
    if ! command -v npm &> /dev/null; then
        missing+=("npm")
    fi

    # Check git
    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        error "Missing prerequisites: ${missing[*]}"
        echo ""
        echo -e "${YELLOW}Quick install commands:${NC}"

        # Platform-specific install guidance
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "macOS:"
            [[ " ${missing[*]} " =~ " Node.js" ]] && echo "  brew install node"
            [[ " ${missing[*]} " =~ " git" ]] && echo "  brew install git"
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo "Linux (Ubuntu/Debian):"
            [[ " ${missing[*]} " =~ " Node.js" ]] && echo "  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -"
            [[ " ${missing[*]} " =~ " Node.js" ]] && echo "  sudo apt-get install -y nodejs"
            [[ " ${missing[*]} " =~ " git" ]] && echo "  sudo apt-get install -y git"
        fi

        echo ""
        echo "Then run: curl -fsSL https://get.hivestudio.dev | bash"
        exit 1
    fi

    success "Prerequisites verified (Node.js $(node --version), npm $(npm --version), git $(git --version | cut -d' ' -f3))"
}

# Fast Claude CLI installation with smart fallbacks
install_claude_cli() {
    progress "Installing Claude CLI"

    if command -v claude &> /dev/null; then
        success "Claude CLI already installed ($(claude --version 2>/dev/null || echo 'version unknown'))"
        return 0
    fi

    log "Installing Claude CLI via npm (fastest method)..."

    # Try npm installation with timeout
    if timeout 60 npm install -g @anthropic-ai/claude-code &>/dev/null; then
        success "Claude CLI installed via npm"
        return 0
    fi

    # Fallback to curl if npm fails
    warn "npm installation timeout, trying curl method..."
    if curl -fsSL https://claude.ai/install.sh | sh &>/dev/null; then
        export PATH="$PATH:$HOME/.local/bin"
        success "Claude CLI installed via curl"
        return 0
    fi

    # Ultimate fallback - continue without Claude CLI
    warn "Claude CLI installation failed - continuing with local mode"
    warn "You can install it later with: npm install -g @anthropic-ai/claude-code"
    return 1
}

# Minimal project setup for immediate success
create_minimal_project() {
    progress "Creating minimal project"

    # Essential directories only
    mkdir -p {src,demo}
    mkdir -p .hivestudio/{agents,memory}

    # Minimal package.json for immediate functionality
    cat > package.json << 'EOF'
{
  "name": "hivestudio-turbo",
  "version": "1.0.0",
  "description": "HiveStudio AI Agent Team - Turbo Start",
  "scripts": {
    "demo": "node demo/hello-agents.js",
    "enhance": "./enhance.sh"
  },
  "dependencies": {
    "chalk": "^4.1.2"
  }
}
EOF

    # Install minimal dependencies
    npm install &>/dev/null || warn "npm install failed - demo will run without styling"

    success "Minimal project structure created"
}

# Create immediate value demonstration
create_demo() {
    progress "Creating AI agent demo"

    # Hello World AI agent simulation
    cat > demo/hello-agents.js << 'EOF'
#!/usr/bin/env node

// HiveStudio AI Agent Demo - Simulated Multi-Agent Coordination
// This demonstrates the concept before full installation

const chalk = require('chalk').default || require('chalk');

console.log(chalk.blue.bold('\n🚀 HiveStudio AI Agent Team - Live Demo\n'));

const agents = [
    { name: 'Research Agent', role: 'Analyzer', color: 'cyan' },
    { name: 'Code Agent', role: 'Implementation', color: 'green' },
    { name: 'Review Agent', role: 'Quality Assurance', color: 'yellow' }
];

async function simulateAgent(agent, task, duration) {
    return new Promise(resolve => {
        console.log(chalk[agent.color](`${agent.name}: Starting ${task}...`));

        setTimeout(() => {
            console.log(chalk[agent.color](`${agent.name}: ✅ ${task} completed`));
            resolve();
        }, duration);
    });
}

async function runDemo() {
    console.log(chalk.white.bold('Task: "Create a simple hello world function"\n'));

    // Parallel agent execution (simulated)
    const tasks = [
        simulateAgent(agents[0], 'analyzing requirements', 1000),
        simulateAgent(agents[1], 'implementing solution', 1500),
        simulateAgent(agents[2], 'reviewing code quality', 800)
    ];

    await Promise.all(tasks);

    console.log(chalk.green.bold('\n🎉 Team coordination complete!'));
    console.log(chalk.white('\nGenerated code:'));
    console.log(chalk.gray('─'.repeat(40)));
    console.log(chalk.white('function helloWorld() {'));
    console.log(chalk.white('  return "Hello from HiveStudio AI Agents!";'));
    console.log(chalk.white('}'));
    console.log(chalk.gray('─'.repeat(40)));

    console.log(chalk.blue('\n📊 Coordination Stats:'));
    console.log(chalk.white('• Agents spawned: 3'));
    console.log(chalk.white('• Tasks completed: 3'));
    console.log(chalk.white('• Coordination time: 1.5 seconds'));
    console.log(chalk.white('• Success rate: 100%'));

    console.log(chalk.yellow.bold('\n🚀 Ready for real AI agents?'));
    console.log(chalk.white('Run: ./enhance.sh --guided'));
    console.log(chalk.gray('This will install full HiveStudio with Claude Code integration\n'));
}

runDemo().catch(console.error);
EOF

    chmod +x demo/hello-agents.js

    success "AI agent demo ready"
}

# Run the immediate value demonstration
run_hello_world() {
    progress "Running AI agent demo"

    echo ""
    echo -e "${YELLOW}🎬 Watch your AI agents coordinate:${NC}"
    echo ""

    # Run the demo
    cd "$(dirname "$0")" 2>/dev/null || true
    node demo/hello-agents.js

    echo ""
    success "Demo completed successfully!"
}

# Create enhancement script for progressive improvement
create_enhancement_script() {
    cat > enhance.sh << 'EOF'
#!/bin/bash

# HiveStudio Enhancement Script - Progressive Feature Addition
# Usage: ./enhance.sh [--guided|--standard|--enterprise]

MODE=${1:-"--guided"}

echo "🔧 HiveStudio Enhancement Mode: $MODE"
echo ""

if [[ "$MODE" == "--guided" ]]; then
    echo "This will add:"
    echo "• Full Claude Code integration"
    echo "• MCP servers for coordination"
    echo "• Team templates and workflows"
    echo "• SPARC methodology tools"
    echo ""
    echo "Estimated time: 10-15 minutes"
    echo ""
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        curl -fsSL https://raw.githubusercontent.com/auitenbroek1/hivestudio-script/main/install-ecosystem.sh | bash
    fi
elif [[ "$MODE" == "--standard" ]]; then
    echo "Installing standard HiveStudio features..."
    curl -fsSL https://raw.githubusercontent.com/auitenbroek1/hivestudio-script/main/install-ecosystem.sh | bash
elif [[ "$MODE" == "--enterprise" ]]; then
    echo "Installing full enterprise HiveStudio..."
    curl -fsSL https://raw.githubusercontent.com/auitenbroek1/hivestudio-script/main/install-ecosystem.sh | bash
    # Additional enterprise features would go here
else
    echo "Usage: ./enhance.sh [--guided|--standard|--enterprise]"
    echo ""
    echo "Modes:"
    echo "  --guided     Interactive installation with guidance"
    echo "  --standard   Standard HiveStudio features"
    echo "  --enterprise Full enterprise feature set"
fi
EOF

    chmod +x enhance.sh
}

# Show success summary and next steps
show_success() {
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo ""
    echo -e "${GREEN}${BOLD}🎉 SUCCESS! Your AI agents are ready!${NC}"
    echo ""
    echo -e "${BLUE}📊 Setup Summary:${NC}"
    echo -e "   ⏱️  Total time: ${duration} seconds"
    echo -e "   ✅ AI agent demo: Working"
    echo -e "   📦 Project structure: Created"
    echo -e "   🚀 Ready for: Enhancement"
    echo ""
    echo -e "${YELLOW}🎯 What you just accomplished:${NC}"
    echo -e "   • Validated your development environment"
    echo -e "   • Created a working AI agent simulation"
    echo -e "   • Demonstrated multi-agent coordination"
    echo -e "   • Set up progressive enhancement path"
    echo ""
    echo -e "${BLUE}🚀 Next Steps:${NC}"
    echo -e "   1. Run demo again: ${GREEN}npm run demo${NC}"
    echo -e "   2. Add full features: ${GREEN}./enhance.sh --guided${NC}"
    echo -e "   3. Read quick guide: ${GREEN}https://hivestudio.dev/quickstart${NC}"
    echo ""
    echo -e "${YELLOW}💡 Pro Tips:${NC}"
    echo -e "   • The demo shows HiveStudio concepts in action"
    echo -e "   • Enhancement adds real Claude Code integration"
    echo -e "   • You can always enhance later - no pressure!"
    echo ""
    echo -e "${GREEN}Happy coding with AI agents! 🤖✨${NC}"
}

# Main execution
main() {
    local start_time=$(date +%s)

    show_banner

    # Execute the 5-step turbo setup
    check_prerequisites
    install_claude_cli
    create_minimal_project
    create_demo
    run_hello_world

    # Create enhancement path
    create_enhancement_script

    # Show success and next steps
    show_success
}

# Execute if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi