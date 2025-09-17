#!/bin/bash

# HiveStudio Ecosystem Quick Start
# Usage: ./quickstart.sh [workflow-type] [project-description]

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

WORKFLOW_TYPE=${1:-"demo"}
PROJECT_DESC=${2:-"Quick Start Demo"}

echo -e "${GREEN}🚀 HiveStudio Ecosystem Quick Start${NC}"
echo -e "${BLUE}Workflow: $WORKFLOW_TYPE${NC}"
echo -e "${BLUE}Project: $PROJECT_DESC${NC}"
echo "================================="

# Demo workflow - shows basic capabilities
demo_workflow() {
    echo -e "${YELLOW}📋 Running Demo Workflow...${NC}"

    echo "1. Checking MCP servers..."
    claude mcp list || echo "MCP servers need setup - run ./install-ecosystem.sh first"

    echo "2. Testing Claude Flow..."
    npx claude-flow@alpha --version || echo "Claude Flow not available"

    echo "3. Showing available SPARC modes..."
    npx claude-flow@alpha sparc modes || echo "SPARC modes not available"

    echo "4. Demonstrating team templates..."
    echo "Available team templates:"
    ls .claude/team-templates/*.json 2>/dev/null | xargs -n 1 basename | sed 's/.json$//' || echo "No team templates found"

    echo -e "${GREEN}✅ Demo completed!${NC}"
    echo "Run specific workflows with: ./quickstart.sh [web-app|api|ml-project|mobile-app] 'Project Name'"
}

# Web application workflow
web_app_workflow() {
    echo -e "${YELLOW}🌐 Starting Web Application Development Workflow...${NC}"

    echo "1. Spawning full-stack development team..."
    ./scripts/spawn-team.sh full-stack-team "$PROJECT_DESC" || echo "Team spawning failed - check installation"

    echo "2. Running SPARC specification phase..."
    echo "Command: npx claude-flow@alpha sparc run spec-pseudocode 'Modern web application with authentication'"

    echo "3. Next steps:"
    echo "   - npx claude-flow@alpha sparc run architect 'Web app architecture'"
    echo "   - npx claude-flow@alpha sparc tdd 'User authentication system'"
    echo "   - npx claude-flow@alpha swarm status"

    echo -e "${GREEN}✅ Web app workflow initialized!${NC}"
}

# API development workflow
api_workflow() {
    echo -e "${YELLOW}🔌 Starting API Development Workflow...${NC}"

    echo "1. Spawning API development team..."
    ./scripts/spawn-team.sh api-team "$PROJECT_DESC" || echo "Team spawning failed - check installation"

    echo "2. Running API design phase..."
    echo "Command: npx claude-flow@alpha sparc run spec-pseudocode 'RESTful API with authentication and CRUD operations'"

    echo "3. Next steps:"
    echo "   - npx claude-flow@alpha sparc run architect 'Microservices API architecture'"
    echo "   - npx claude-flow@alpha sparc tdd 'API endpoints with OpenAPI spec'"
    echo "   - npx claude-flow@alpha task orchestrate 'Implement user management API'"

    echo -e "${GREEN}✅ API workflow initialized!${NC}"
}

# ML project workflow
ml_workflow() {
    echo -e "${YELLOW}🤖 Starting ML Project Workflow...${NC}"

    echo "1. Spawning ML development team..."
    ./scripts/spawn-team.sh ml-team "$PROJECT_DESC" || echo "Team spawning failed - check installation"

    echo "2. Running ML research phase..."
    echo "Command: npx claude-flow@alpha sparc run spec-pseudocode 'Machine learning model for data analysis'"

    echo "3. Next steps:"
    echo "   - npx claude-flow@alpha sparc run architect 'ML pipeline architecture'"
    echo "   - npx claude-flow@alpha neural train coordination ml-training-data.json"
    echo "   - npx claude-flow@alpha task orchestrate 'Implement and train ML model'"

    echo -e "${GREEN}✅ ML workflow initialized!${NC}"
}

# Mobile app workflow
mobile_workflow() {
    echo -e "${YELLOW}📱 Starting Mobile App Development Workflow...${NC}"

    echo "1. Spawning mobile development team..."
    ./scripts/spawn-team.sh mobile-team "$PROJECT_DESC" || echo "Team spawning failed - check installation"

    echo "2. Running mobile app specification..."
    echo "Command: npx claude-flow@alpha sparc run spec-pseudocode 'Cross-platform mobile application'"

    echo "3. Next steps:"
    echo "   - npx claude-flow@alpha sparc run architect 'Mobile app architecture'"
    echo "   - npx claude-flow@alpha sparc tdd 'Mobile app features with testing'"
    echo "   - npx claude-flow@alpha task orchestrate 'Implement mobile app MVP'"

    echo -e "${GREEN}✅ Mobile workflow initialized!${NC}"
}

# Test ecosystem health
test_ecosystem() {
    echo -e "${YELLOW}🔧 Testing Ecosystem Health...${NC}"

    echo "Checking Node.js..."
    node --version || echo "❌ Node.js not found"

    echo "Checking npm..."
    npm --version || echo "❌ npm not found"

    echo "Checking Claude CLI..."
    claude --version || echo "❌ Claude CLI not found"

    echo "Checking MCP servers..."
    claude mcp list || echo "❌ MCP servers not configured"

    echo "Checking project structure..."
    [ -d "src" ] && echo "✅ src/ directory exists" || echo "❌ src/ directory missing"
    [ -d "tests" ] && echo "✅ tests/ directory exists" || echo "❌ tests/ directory missing"
    [ -d ".claude/team-templates" ] && echo "✅ team templates exist" || echo "❌ team templates missing"

    echo "Checking scripts..."
    [ -x "scripts/spawn-team.sh" ] && echo "✅ spawn-team.sh executable" || echo "❌ spawn-team.sh not executable"

    echo -e "${GREEN}✅ Health check completed!${NC}"
}

# Show usage
show_usage() {
    echo "Usage: ./quickstart.sh [workflow-type] [project-description]"
    echo ""
    echo "Workflow types:"
    echo "  demo        - Basic demonstration (default)"
    echo "  web-app     - Full-stack web application"
    echo "  api         - REST API development"
    echo "  ml-project  - Machine learning project"
    echo "  mobile-app  - Mobile application"
    echo "  test        - Test ecosystem health"
    echo "  help        - Show this help"
    echo ""
    echo "Examples:"
    echo "  ./quickstart.sh web-app 'E-commerce Platform'"
    echo "  ./quickstart.sh api 'User Management API'"
    echo "  ./quickstart.sh ml-project 'Recommendation Engine'"
    echo "  ./quickstart.sh mobile-app 'Travel Booking App'"
}

# Main execution
case $WORKFLOW_TYPE in
    "demo")
        demo_workflow
        ;;
    "web-app")
        web_app_workflow
        ;;
    "api")
        api_workflow
        ;;
    "ml-project")
        ml_workflow
        ;;
    "mobile-app")
        mobile_workflow
        ;;
    "test")
        test_ecosystem
        ;;
    "help"|"-h"|"--help")
        show_usage
        ;;
    *)
        echo -e "${RED}❌ Unknown workflow type: $WORKFLOW_TYPE${NC}"
        show_usage
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}💡 Tips:${NC}"
echo "• Check team status: npx claude-flow swarm status"
echo "• Monitor activity: npx claude-flow swarm monitor"
echo "• View quick reference: cat docs/QUICK-REFERENCE.md"
echo "• Get help: npx claude-flow --help"
echo ""
echo -e "${GREEN}Happy coding with your AI agent team! 🎉${NC}"