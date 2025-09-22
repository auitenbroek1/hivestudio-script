#!/bin/bash

# HiveStudio 30-Minute Setup Validation Test
# Tests the complete flow from zero to full HiveStudio in under 30 minutes
# Measures time, validates functionality, reports bottlenecks

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# Test configuration
TEST_DIR="/tmp/hivestudio-30min-test-$(date +%s)"
START_TIME=$(date +%s)
TARGET_TIME=1800  # 30 minutes in seconds
PHASE_TIMES=()

log() {
    local current_time=$(date +%s)
    local elapsed=$((current_time - START_TIME))
    echo -e "${GREEN}[$(printf '%02d:%02d' $((elapsed/60)) $((elapsed%60)))] $1${NC}"
}

phase() {
    local current_time=$(date +%s)
    local elapsed=$((current_time - START_TIME))
    PHASE_TIMES+=("$1:$elapsed")
    echo -e "${BLUE}${BOLD}🔄 Phase: $1 (at ${elapsed}s)${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Test banner
show_banner() {
    echo -e "${BOLD}${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                      🧪 HiveStudio 30-Minute Test                           ║"
    echo "║                                                                              ║"
    echo "║                  Target: Complete setup in under 30 minutes                 ║"
    echo "║                  Tests: Turbo start → Standard → Enterprise                 ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${YELLOW}🎯 Testing complete HiveStudio setup flow...${NC}"
    echo -e "${BLUE}📍 Test directory: $TEST_DIR${NC}"
    echo ""
}

# Clean test environment setup
setup_test_environment() {
    phase "Test Environment Setup"

    log "Creating clean test directory..."
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"

    log "Clearing any existing Claude configuration..."
    export CLAUDE_CONFIG_DIR="$TEST_DIR/.claude-test"

    success "Test environment ready"
}

# Test Phase 1: Turbo Start (Target: 5 minutes)
test_turbo_start() {
    phase "Turbo Start (Target: 5 minutes)"

    local phase_start=$(date +%s)

    log "Downloading turbo-start.sh..."
    curl -fsSL https://raw.githubusercontent.com/auitenbroek1/hivestudio-script/main/turbo-start.sh > turbo-start.sh
    chmod +x turbo-start.sh

    log "Running turbo start..."
    if ./turbo-start.sh; then
        success "Turbo start completed"
    else
        error "Turbo start failed"
    fi

    log "Validating turbo start results..."
    validate_turbo_results

    local phase_end=$(date +%s)
    local phase_duration=$((phase_end - phase_start))

    if [ $phase_duration -le 300 ]; then  # 5 minutes
        success "Turbo start completed in ${phase_duration}s (target: 300s)"
    else
        warn "Turbo start took ${phase_duration}s (exceeded 300s target)"
    fi
}

# Validate turbo start results
validate_turbo_results() {
    log "Checking turbo start outputs..."

    # Check essential files
    [ -f "package.json" ] && success "package.json created" || error "package.json missing"
    [ -f "demo/hello-agents.js" ] && success "Demo script created" || error "Demo script missing"
    [ -f "enhance.sh" ] && success "Enhancement script created" || error "Enhancement script missing"
    [ -x "enhance.sh" ] && success "Enhancement script executable" || error "Enhancement script not executable"

    # Check directories
    [ -d "src" ] && success "src/ directory created" || error "src/ directory missing"
    [ -d "demo" ] && success "demo/ directory created" || error "demo/ directory missing"
    [ -d ".hivestudio" ] && success ".hivestudio/ directory created" || error ".hivestudio/ directory missing"

    # Test demo functionality
    log "Testing demo functionality..."
    if timeout 30 npm run demo > demo-output.log 2>&1; then
        success "Demo runs successfully"
        if grep -q "Team coordination complete" demo-output.log; then
            success "Demo shows expected output"
        else
            warn "Demo output unexpected - check demo-output.log"
        fi
    else
        warn "Demo failed or timed out"
    fi
}

# Test Phase 2: Standard Enhancement (Target: 15 minutes total)
test_standard_enhancement() {
    phase "Standard Enhancement (Target: 15 minutes total)"

    local phase_start=$(date +%s)

    log "Running standard enhancement..."
    if timeout 600 ./enhance.sh --standard; then  # 10 minute timeout
        success "Standard enhancement completed"
    else
        error "Standard enhancement failed or timed out"
    fi

    log "Validating standard enhancement..."
    validate_standard_results

    local phase_end=$(date +%s)
    local phase_duration=$((phase_end - phase_start))
    local total_duration=$((phase_end - START_TIME))

    if [ $total_duration -le 900 ]; then  # 15 minutes total
        success "Standard setup completed in ${total_duration}s total (target: 900s)"
    else
        warn "Standard setup took ${total_duration}s total (exceeded 900s target)"
    fi
}

# Validate standard enhancement results
validate_standard_results() {
    log "Checking standard enhancement outputs..."

    # Check for Claude CLI
    if command -v claude &> /dev/null; then
        success "Claude CLI installed"
        log "Claude version: $(claude --version 2>/dev/null || echo 'unknown')"
    else
        warn "Claude CLI not found in PATH"
    fi

    # Check for MCP servers
    if claude mcp list &> /dev/null; then
        success "MCP servers configured"
        local mcp_count=$(claude mcp list 2>/dev/null | wc -l)
        log "MCP servers found: $mcp_count"
    else
        warn "MCP servers not configured"
    fi

    # Check enhanced project structure
    [ -d ".claude/team-templates" ] && success "Team templates directory exists" || warn "Team templates missing"
    [ -d ".claude/workflows" ] && success "Workflows directory exists" || warn "Workflows missing"
    [ -d "scripts" ] && success "Scripts directory exists" || warn "Scripts missing"
    [ -d "tests" ] && success "Tests directory exists" || warn "Tests missing"

    # Check for key scripts
    [ -f "scripts/spawn-team.sh" ] && [ -x "scripts/spawn-team.sh" ] && success "Team spawning script ready" || warn "Team spawning script missing"

    # Check team templates
    local template_count=$(find .claude/team-templates -name "*.json" 2>/dev/null | wc -l)
    if [ "$template_count" -gt 0 ]; then
        success "Team templates available: $template_count"
    else
        warn "No team templates found"
    fi
}

# Test Phase 3: Enterprise Features (Target: 30 minutes total)
test_enterprise_features() {
    phase "Enterprise Features (Target: 30 minutes total)"

    local phase_start=$(date +%s)

    log "Running enterprise enhancement..."
    if timeout 900 ./enhance.sh --enterprise; then  # 15 minute timeout
        success "Enterprise enhancement completed"
    else
        warn "Enterprise enhancement failed or timed out (continuing)"
    fi

    log "Validating enterprise features..."
    validate_enterprise_results

    local phase_end=$(date +%s)
    local total_duration=$((phase_end - START_TIME))

    if [ $total_duration -le $TARGET_TIME ]; then
        success "Enterprise setup completed in ${total_duration}s (target: ${TARGET_TIME}s)"
    else
        warn "Enterprise setup took ${total_duration}s (exceeded ${TARGET_TIME}s target)"
    fi
}

# Validate enterprise features
validate_enterprise_results() {
    log "Checking enterprise features..."

    # Check for advanced configurations
    [ -f "docs/QUICK-REFERENCE.md" ] && success "Quick reference documentation" || warn "Quick reference missing"

    # Check examples
    local example_count=$(find examples -name "*.js" 2>/dev/null | wc -l)
    if [ "$example_count" -gt 0 ]; then
        success "Example files available: $example_count"
    else
        warn "No example files found"
    fi

    # Test basic functionality
    log "Testing basic HiveStudio functionality..."
    if npx claude-flow@alpha --version &> /dev/null; then
        success "Claude Flow accessible"
    else
        warn "Claude Flow not accessible"
    fi
}

# Performance analysis and recommendations
analyze_performance() {
    phase "Performance Analysis"

    local total_time=$(date +%s)
    local duration=$((total_time - START_TIME))

    echo ""
    echo -e "${BOLD}📊 Performance Report${NC}"
    echo "══════════════════════════════════════"

    # Time breakdown
    echo -e "${BLUE}⏱️  Time Breakdown:${NC}"
    for phase_time in "${PHASE_TIMES[@]}"; do
        echo "   ${phase_time//:/ - }s"
    done
    echo "   Total: ${duration}s"
    echo ""

    # Success metrics
    echo -e "${BLUE}🎯 Success Metrics:${NC}"
    if [ $duration -le $TARGET_TIME ]; then
        echo -e "   ✅ 30-minute target: ${GREEN}ACHIEVED${NC} (${duration}s / ${TARGET_TIME}s)"
    else
        echo -e "   ❌ 30-minute target: ${RED}MISSED${NC} (${duration}s / ${TARGET_TIME}s)"
    fi

    # Generate recommendations
    echo ""
    echo -e "${BLUE}💡 Optimization Recommendations:${NC}"

    if [ $duration -gt $TARGET_TIME ]; then
        local overage=$((duration - TARGET_TIME))
        echo "   • Reduce setup time by ${overage}s to meet target"

        # Specific recommendations based on common bottlenecks
        echo "   • Consider parallel downloads for faster installs"
        echo "   • Pre-compile or cache frequently used components"
        echo "   • Optimize network-dependent operations"
        echo "   • Add more intelligent fallbacks"
    else
        echo "   • Current setup meets 30-minute target"
        echo "   • Consider documenting this success path"
        echo "   • Monitor for performance regressions"
    fi

    # Bottleneck analysis
    echo ""
    echo -e "${BLUE}🔍 Bottleneck Analysis:${NC}"

    # Analyze phase times to identify slowest components
    local max_time=0
    local slowest_phase=""

    for phase_time in "${PHASE_TIMES[@]}"; do
        local phase=$(echo "$phase_time" | cut -d: -f1)
        local time=$(echo "$phase_time" | cut -d: -f2)
        if [ "$time" -gt "$max_time" ]; then
            max_time=$time
            slowest_phase=$phase
        fi
    done

    if [ -n "$slowest_phase" ]; then
        echo "   • Slowest phase: $slowest_phase (${max_time}s)"
    fi

    # Resource usage analysis
    echo ""
    echo -e "${BLUE}💾 Resource Usage:${NC}"
    local disk_usage=$(du -sh "$TEST_DIR" 2>/dev/null | cut -f1)
    echo "   • Disk space used: $disk_usage"
    echo "   • Test directory: $TEST_DIR"
}

# Generate detailed report
generate_report() {
    local report_file="$TEST_DIR/hivestudio-30min-test-report.md"

    cat > "$report_file" << EOF
# HiveStudio 30-Minute Setup Test Report

**Test Date**: $(date)
**Target Time**: 30 minutes (1800 seconds)
**Actual Time**: $(($(date +%s) - START_TIME)) seconds
**Status**: $([ $(($(date +%s) - START_TIME)) -le $TARGET_TIME ] && echo "✅ PASSED" || echo "❌ FAILED")

## Phase Breakdown

$(for phase_time in "${PHASE_TIMES[@]}"; do
    echo "- ${phase_time//:/ - }s"
done)

## Validation Results

### Turbo Start Validation
- package.json: $([ -f "$TEST_DIR/package.json" ] && echo "✅" || echo "❌")
- Demo script: $([ -f "$TEST_DIR/demo/hello-agents.js" ] && echo "✅" || echo "❌")
- Enhancement script: $([ -f "$TEST_DIR/enhance.sh" ] && echo "✅" || echo "❌")

### Standard Enhancement Validation
- Claude CLI: $(command -v claude &> /dev/null && echo "✅" || echo "❌")
- MCP servers: $(claude mcp list &> /dev/null && echo "✅" || echo "❌")
- Team templates: $([ -d "$TEST_DIR/.claude/team-templates" ] && echo "✅" || echo "❌")

### Enterprise Features Validation
- Documentation: $([ -f "$TEST_DIR/docs/QUICK-REFERENCE.md" ] && echo "✅" || echo "❌")
- Examples: $([ -d "$TEST_DIR/examples" ] && echo "✅" || echo "❌")
- Claude Flow: $(npx claude-flow@alpha --version &> /dev/null && echo "✅" || echo "❌")

## Recommendations

$([ $(($(date +%s) - START_TIME)) -le $TARGET_TIME ] && echo "✅ Current setup meets 30-minute target" || echo "❌ Optimization needed to meet 30-minute target")

## Test Environment

- Test Directory: $TEST_DIR
- Node.js: $(node --version)
- npm: $(npm --version)
- OS: $(uname -s)

EOF

    echo -e "${GREEN}📄 Detailed report saved to: $report_file${NC}"
}

# Cleanup
cleanup() {
    phase "Cleanup"

    log "Cleaning up test environment..."
    cd /tmp
    rm -rf "$TEST_DIR"

    success "Test environment cleaned up"
}

# Main test execution
main() {
    show_banner

    setup_test_environment
    test_turbo_start
    test_standard_enhancement
    test_enterprise_features
    analyze_performance
    generate_report

    local final_time=$(date +%s)
    local total_duration=$((final_time - START_TIME))

    echo ""
    if [ $total_duration -le $TARGET_TIME ]; then
        echo -e "${GREEN}${BOLD}🎉 SUCCESS: 30-minute setup target achieved!${NC}"
        echo -e "${GREEN}Total time: ${total_duration}s (target: ${TARGET_TIME}s)${NC}"
    else
        echo -e "${RED}${BOLD}❌ FAILED: 30-minute setup target missed${NC}"
        echo -e "${RED}Total time: ${total_duration}s (target: ${TARGET_TIME}s)${NC}"
        echo -e "${YELLOW}Overage: $((total_duration - TARGET_TIME))s${NC}"
    fi

    echo ""
    echo -e "${BLUE}📊 View detailed report: $TEST_DIR/hivestudio-30min-test-report.md${NC}"

    # Ask about cleanup
    echo ""
    read -p "Clean up test environment? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        cleanup
    else
        echo -e "${YELLOW}Test environment preserved at: $TEST_DIR${NC}"
    fi
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi