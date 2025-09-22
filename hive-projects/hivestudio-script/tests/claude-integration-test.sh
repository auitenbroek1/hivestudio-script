#!/bin/bash

# Claude GitHub App Integration Test Suite
# Tests for validating the Claude GitHub App setup and configuration

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((TESTS_PASSED++))
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    ((TESTS_FAILED++))
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

run_test() {
    ((TESTS_RUN++))
    local test_name="$1"
    local test_command="$2"

    log_info "Running test: $test_name"

    if eval "$test_command"; then
        log_success "$test_name"
        return 0
    else
        log_error "$test_name"
        return 1
    fi
}

# Test functions
test_workflow_file_exists() {
    [ -f ".github/workflows/claude.yml" ]
}

test_workflow_syntax() {
    # Basic YAML syntax check
    if command -v yamllint >/dev/null 2>&1; then
        yamllint .github/workflows/claude.yml >/dev/null 2>&1
    else
        # Fallback: check for basic YAML structure
        grep -q "name:" .github/workflows/claude.yml && \
        grep -q "on:" .github/workflows/claude.yml && \
        grep -q "jobs:" .github/workflows/claude.yml
    fi
}

test_workflow_has_required_permissions() {
    grep -q "permissions:" .github/workflows/claude.yml && \
    grep -q "pull-requests: write" .github/workflows/claude.yml && \
    grep -q "contents: read" .github/workflows/claude.yml
}

test_workflow_has_authentication() {
    grep -q "ANTHROPIC_API_KEY\|CLAUDE_CODE_OAUTH_TOKEN" .github/workflows/claude.yml
}

test_documentation_exists() {
    [ -f "docs/github-app-setup.md" ] && \
    [ -f "docs/oauth-token-guide.md" ] && \
    [ -f "docs/testing-guide.md" ]
}

test_documentation_completeness() {
    grep -q "ANTHROPIC_API_KEY\|CLAUDE_CODE_OAUTH_TOKEN" docs/github-app-setup.md && \
    grep -q "claude setup-token" docs/oauth-token-guide.md && \
    grep -q "troubleshooting" docs/testing-guide.md
}

test_config_template_exists() {
    [ -f "config/claude-app-config.template.json" ]
}

test_config_template_valid_json() {
    if command -v node >/dev/null 2>&1; then
        node -e "JSON.parse(require('fs').readFileSync('config/claude-app-config.template.json', 'utf8'))" >/dev/null 2>&1
    elif command -v python3 >/dev/null 2>&1; then
        python3 -c "import json; json.load(open('config/claude-app-config.template.json'))" >/dev/null 2>&1
    else
        # Fallback: basic JSON structure check
        grep -q "{" config/claude-app-config.template.json && \
        grep -q "}" config/claude-app-config.template.json
    fi
}

test_repository_structure() {
    [ -d ".github/workflows" ] && \
    [ -d "docs" ] && \
    [ -d "config" ] && \
    [ -d "tests" ]
}

test_git_repository() {
    [ -d ".git" ] && git status >/dev/null 2>&1
}

test_workflow_triggers() {
    grep -q "pull_request:" .github/workflows/claude.yml && \
    grep -q "workflow_dispatch:" .github/workflows/claude.yml
}

test_claude_cli_commands() {
    grep -q "claude auth login" .github/workflows/claude.yml && \
    grep -q "claude ask" .github/workflows/claude.yml
}

# GitHub-specific tests (require network access)
test_github_app_url() {
    if command -v curl >/dev/null 2>&1; then
        curl -s -o /dev/null -w "%{http_code}" "https://github.com/apps/claude" | grep -q "200\|302"
    else
        log_warning "curl not available, skipping GitHub App URL test"
        return 0
    fi
}

test_anthropic_console_url() {
    if command -v curl >/dev/null 2>&1; then
        curl -s -o /dev/null -w "%{http_code}" "https://console.anthropic.com/" | grep -q "200\|302"
    else
        log_warning "curl not available, skipping Anthropic console URL test"
        return 0
    fi
}

# Main test execution
main() {
    echo "🧪 Claude GitHub App Integration Test Suite"
    echo "==========================================="
    echo ""

    log_info "Repository: auitenbroek1/hivestudio-script"
    log_info "Test environment: $(uname -s) $(uname -m)"
    echo ""

    # Core file tests
    echo "📁 File Structure Tests"
    echo "----------------------"
    run_test "Workflow file exists" "test_workflow_file_exists"
    run_test "Repository structure valid" "test_repository_structure"
    run_test "Git repository valid" "test_git_repository"
    run_test "Configuration template exists" "test_config_template_exists"
    echo ""

    # Workflow validation tests
    echo "⚙️  Workflow Validation Tests"
    echo "----------------------------"
    run_test "Workflow YAML syntax valid" "test_workflow_syntax"
    run_test "Workflow has required permissions" "test_workflow_has_required_permissions"
    run_test "Workflow has authentication setup" "test_workflow_has_authentication"
    run_test "Workflow has correct triggers" "test_workflow_triggers"
    run_test "Workflow uses Claude CLI commands" "test_claude_cli_commands"
    echo ""

    # Documentation tests
    echo "📚 Documentation Tests"
    echo "---------------------"
    run_test "Documentation files exist" "test_documentation_exists"
    run_test "Documentation is complete" "test_documentation_completeness"
    echo ""

    # Configuration tests
    echo "🔧 Configuration Tests"
    echo "---------------------"
    run_test "Config template is valid JSON" "test_config_template_valid_json"
    echo ""

    # Network tests (optional)
    echo "🌐 Network Connectivity Tests"
    echo "-----------------------------"
    run_test "GitHub Apps page accessible" "test_github_app_url"
    run_test "Anthropic console accessible" "test_anthropic_console_url"
    echo ""

    # Test summary
    echo "📊 Test Summary"
    echo "==============="
    echo "Tests run: $TESTS_RUN"
    echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        log_success "All tests passed! Claude GitHub App setup is ready."
        echo ""
        echo "🎉 Next Steps:"
        echo "1. Install Claude GitHub App: https://github.com/apps/claude"
        echo "2. Generate OAuth token: claude setup-token"
        echo "3. Add secrets to repository"
        echo "4. Create a test pull request"
        echo ""
        exit 0
    else
        log_error "Some tests failed. Please fix the issues and run tests again."
        echo ""
        echo "🔧 Troubleshooting:"
        echo "1. Check the failed tests above"
        echo "2. Review docs/github-app-setup.md for setup instructions"
        echo "3. Verify all required files are in place"
        echo ""
        exit 1
    fi
}

# Command line options
case "${1:-}" in
    --help|-h)
        echo "Claude GitHub App Integration Test Suite"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --verbose, -v  Show verbose output"
        echo "  --quick, -q    Run only essential tests"
        echo ""
        echo "Examples:"
        echo "  $0              # Run all tests"
        echo "  $0 --verbose    # Run with detailed output"
        echo "  $0 --quick      # Run quick validation only"
        exit 0
        ;;
    --verbose|-v)
        set -x
        main
        ;;
    --quick|-q)
        echo "🚀 Quick Validation Tests"
        echo "========================"
        run_test "Workflow file exists" "test_workflow_file_exists"
        run_test "Documentation exists" "test_documentation_exists"
        run_test "Config template exists" "test_config_template_exists"
        echo ""
        if [ $TESTS_FAILED -eq 0 ]; then
            log_success "Quick validation passed!"
        else
            log_error "Quick validation failed!"
            exit 1
        fi
        ;;
    *)
        main
        ;;
esac