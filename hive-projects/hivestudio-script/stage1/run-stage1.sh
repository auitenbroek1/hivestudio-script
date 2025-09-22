#!/bin/bash
# HiveStudio Stage 1 Runner - Simple entry point
# This script runs the complete Stage 1 installation process

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Banner
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "           🚀 HiveStudio Stage 1 Installation                 "
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "This will install:"
echo "  ✓ System prerequisites"
echo "  ✓ Claude Code application"
echo "  ✓ Required dependencies"
echo ""
echo "After Stage 1 completes:"
echo "  1. Launch Claude Code"
echo "  2. Sign in with your Anthropic account"
echo "  3. Select Pro or Max plan"
echo "  4. Run Stage 2 from within Claude Code"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check if install-stage1.sh exists
if [ ! -f "$SCRIPT_DIR/install-stage1.sh" ]; then
    echo -e "${RED}❌ Error: install-stage1.sh not found${NC}"
    echo "Expected location: $SCRIPT_DIR/install-stage1.sh"
    exit 1
fi

# Make sure the script is executable
chmod +x "$SCRIPT_DIR/install-stage1.sh"

# Run Stage 1
echo -e "${BLUE}▶ Starting Stage 1 installation...${NC}"
echo ""

"$SCRIPT_DIR/install-stage1.sh"

# Check exit code
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}    ✅ Stage 1 completed successfully!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Launch Claude Code application"
    echo "  2. Sign in and authenticate"
    echo "  3. From within Claude Code, run:"
    echo ""
    echo -e "${YELLOW}    cd $(dirname "$SCRIPT_DIR")${NC}"
    echo -e "${YELLOW}    ./stage2/run-stage2.sh${NC}"
    echo ""
else
    echo ""
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}    ❌ Stage 1 encountered an error${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Please check the log file:"
    echo "  $SCRIPT_DIR/../logs/stage1-install.log"
    echo ""
    echo "For help, see:"
    echo "  $SCRIPT_DIR/README.md"
    exit 1
fi