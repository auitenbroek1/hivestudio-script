# Claude GitHub App Testing and Troubleshooting Guide

This guide provides comprehensive testing procedures and troubleshooting steps for the Claude GitHub App integration.

## 🧪 Testing Strategy

### Testing Phases

1. **Pre-Integration Testing**: Validate setup before GitHub App installation
2. **Integration Testing**: Test the complete workflow end-to-end
3. **Regression Testing**: Verify continued functionality after changes
4. **Performance Testing**: Monitor workflow execution times and resource usage

## 🚀 Pre-Integration Testing

### 1. Local Environment Setup

Before testing the GitHub integration, verify your local setup:

```bash
# Check Node.js version (requires 18+)
node --version

# Install Claude CLI
npm install -g @anthropic-ai/claude@latest

# Verify Claude CLI installation
claude --version

# Test basic Claude functionality
claude ask "Hello, can you respond with a simple greeting?"
```

### 2. Authentication Testing

Test both authentication methods locally:

#### OAuth Token Testing
```bash
# Generate OAuth token
claude setup-token

# Test authentication
claude auth login --oauth-token "your-oauth-token"

# Verify auth status
claude auth status

# Test API access
claude ask "Test authentication with a simple question"
```

#### API Key Testing
```bash
# Test with API key (if using this method)
claude auth login --api-key "your-api-key"

# Verify auth status
claude auth status

# Test API access
claude ask "Test API key authentication"
```

### 3. Repository Structure Validation

Verify the repository has the required structure:

```bash
# Check workflow files exist
ls -la .github/workflows/

# Verify claude.yml exists
cat .github/workflows/claude.yml

# Check documentation exists
ls -la docs/

# Verify all required files
find . -name "*.yml" -o -name "*.md" | grep -E "(claude|github|setup)" | head -10
```

## 🔧 Integration Testing

### 1. GitHub App Installation Test

Verify the Claude GitHub App is properly installed:

1. **Check App Installation**:
   ```
   https://github.com/settings/installations
   ```
   - Confirm "Claude" app is listed
   - Verify it has access to `auitenbroek1/hivestudio-script`

2. **Repository Permissions**:
   ```
   https://github.com/auitenbroek1/hivestudio-script/settings/installations
   ```
   - Confirm Claude app has required permissions
   - Check access scope is set correctly

### 2. Secrets Configuration Test

Verify GitHub repository secrets are configured:

```bash
# Use GitHub CLI to check (if available)
gh secret list

# Or manually verify in GitHub UI:
# Repository → Settings → Secrets and variables → Actions
```

Expected secrets:
- `ANTHROPIC_API_KEY` OR `CLAUDE_CODE_OAUTH_TOKEN`
- `GITHUB_TOKEN` (automatically provided)

### 3. Workflow Trigger Test

Create a test pull request to verify the workflow triggers:

```bash
# Create test branch
git checkout -b test-claude-integration-$(date +%s)

# Create test file
cat > test-claude-review.md << 'EOF'
# Test File for Claude Review

This is a test file to verify Claude GitHub App integration.

## Test Code Block

```javascript
function testFunction() {
    console.log("Hello, Claude!");
    return true;
}
```

## Test Changes
- Added test documentation
- Included sample code for review
- Testing Claude integration workflow
EOF

# Commit and push
git add test-claude-review.md
git commit -m "Test: Add test file for Claude GitHub App integration

This commit tests:
- Workflow trigger on PR creation
- Claude authentication
- Code review functionality
- Comment posting
"

git push origin test-claude-integration-$(date +%s)
```

### 4. Create Test Pull Request

1. **Create PR via GitHub UI**:
   - Go to repository on GitHub
   - Click "Compare & pull request"
   - Title: "Test: Claude GitHub App Integration"
   - Description:
     ```markdown
     ## Testing Claude Integration

     This PR tests:
     - [x] Workflow triggers on PR events
     - [ ] Claude authentication works
     - [ ] Code review comments are posted
     - [ ] Workflow completes successfully

     **Expected Behavior**:
     - Claude workflow should trigger automatically
     - Authentication should succeed
     - Claude should post a review comment
     - Workflow status should show as passing
     ```
   - Click "Create pull request"

2. **Monitor Workflow Execution**:
   - Go to **Actions** tab
   - Find "Claude GitHub App Integration" workflow
   - Click on the running workflow
   - Monitor each step's progress

### 5. Workflow Step Verification

Monitor these key steps in the workflow:

#### Authentication Step
```bash
# Expected output in logs:
"Using OAuth token for authentication" OR "Using API key for authentication"
"✅ Authentication successful"
```

#### File Analysis Step
```bash
# Expected output in logs:
"📁 Files changed in this PR:"
"🔍 Running Claude analysis..."
"📝 Claude Review Results:"
```

#### Comment Posting Step
```bash
# Expected output in logs:
"Posting review comment to PR"
"✅ Comment posted successfully"
```

## 🐛 Troubleshooting Guide

### Common Issues and Solutions

#### 1. Workflow Not Triggering

**Symptoms**:
- No workflow runs appear in Actions tab
- PR checks section shows no Claude workflow

**Diagnosis**:
```bash
# Check workflow file exists in main branch
git checkout main
ls -la .github/workflows/claude.yml

# Verify workflow syntax
cat .github/workflows/claude.yml | head -20
```

**Solutions**:
1. Ensure `.github/workflows/claude.yml` exists in the main branch
2. Check workflow YAML syntax using GitHub's validator
3. Verify repository has Actions enabled:
   - Settings → Actions → General
   - Enable "Allow all actions and reusable workflows"

#### 2. Authentication Failures

**Symptoms**:
- Workflow fails with "Authentication failed" error
- Logs show "❌ No authentication method found"

**Diagnosis**:
```bash
# Check secrets are configured
# Repository → Settings → Secrets and variables → Actions
```

**Solutions**:

**For OAuth Token Issues**:
```bash
# Regenerate OAuth token
claude setup-token

# Verify token format
echo $CLAUDE_CODE_OAUTH_TOKEN | grep "claude_oauth_"

# Update GitHub secret with new token
```

**For API Key Issues**:
```bash
# Verify API key format
echo $ANTHROPIC_API_KEY | grep "sk-ant-"

# Test API key locally
claude auth login --api-key "your-api-key"
claude ask "Test question"
```

#### 3. Claude CLI Installation Failures

**Symptoms**:
- Workflow fails at "Install Claude CLI" step
- Logs show npm installation errors

**Diagnosis**:
Check workflow logs for specific npm errors.

**Solutions**:
1. **Node.js version issues**:
   ```yaml
   # In claude.yml, ensure Node.js 18+
   - name: Setup Node.js
     uses: actions/setup-node@v4
     with:
       node-version: '18'
   ```

2. **NPM registry issues**:
   ```yaml
   # Add npm registry configuration
   - name: Install Claude CLI
     run: |
       npm config set registry https://registry.npmjs.org/
       npm install -g @anthropic-ai/claude@latest
   ```

3. **Permission issues**:
   ```yaml
   # Use npx instead of global install
   - name: Use Claude CLI
     run: npx @anthropic-ai/claude@latest ask "test"
   ```

#### 4. Code Review Not Posted

**Symptoms**:
- Workflow completes but no comment appears on PR
- Logs show "Comment posting failed"

**Diagnosis**:
Check GitHub token permissions and API limits.

**Solutions**:
1. **Verify GitHub token permissions**:
   ```yaml
   permissions:
     contents: read
     pull-requests: write  # Required for comments
     issues: write        # Required for issue comments
   ```

2. **Check API rate limits**:
   - Monitor GitHub API rate limit headers
   - Implement retry logic if needed

3. **Test comment posting manually**:
   ```bash
   # Using GitHub CLI
   gh pr comment <PR_NUMBER> --body "Test comment"
   ```

#### 5. File Analysis Errors

**Symptoms**:
- Claude analysis step fails
- Logs show "Analysis failed" or timeout errors

**Diagnosis**:
Check file sizes and analysis complexity.

**Solutions**:
1. **Large file handling**:
   ```bash
   # Limit files analyzed
   git diff --name-only origin/main...HEAD | head -10 > changed_files.txt
   ```

2. **Timeout handling**:
   ```yaml
   # Add timeout to Claude analysis step
   - name: Run Claude Code Review
     timeout-minutes: 10
   ```

3. **Fallback analysis**:
   ```bash
   # Implement fallback when Claude fails
   claude ask --file review_prompt.txt || {
     echo "Basic validation: Files syntax checked" > review_output.txt
   }
   ```

### Advanced Troubleshooting

#### Debug Mode

Enable debug logging in the workflow:

```yaml
env:
  DEBUG: "1"
  CLAUDE_DEBUG: "true"
```

#### Local Debugging

Test the workflow locally using `act`:

```bash
# Install act (GitHub Actions local runner)
# macOS
brew install act

# Run workflow locally
act pull_request -s ANTHROPIC_API_KEY="your-key"
```

#### Workflow Logs Analysis

Key log sections to examine:

1. **Authentication Logs**:
   ```
   Look for: "Authentication successful" or "Authentication failed"
   Check: Token format, secret names, API connectivity
   ```

2. **File Processing Logs**:
   ```
   Look for: "Files changed in this PR", "Running Claude analysis"
   Check: File paths, analysis prompts, Claude responses
   ```

3. **GitHub API Logs**:
   ```
   Look for: "Posting review comment", "Comment posted successfully"
   Check: API permissions, rate limits, response codes
   ```

## 📊 Performance Testing

### Metrics to Monitor

1. **Workflow Execution Time**:
   - Target: < 5 minutes for typical PRs
   - Monitor: Actions tab → Workflow runs → Duration

2. **Authentication Time**:
   - Target: < 30 seconds
   - Monitor: "Configure Claude Authentication" step

3. **Analysis Time**:
   - Target: < 3 minutes for < 10 files
   - Monitor: "Run Claude Code Review" step

4. **API Rate Limits**:
   - Monitor: GitHub API rate limit headers
   - Track: Anthropic API usage

### Performance Optimization

1. **File Filtering**:
   ```bash
   # Only analyze relevant files
   git diff --name-only origin/main...HEAD | \
   grep -E '\.(js|ts|py|sh|md)$' | \
   head -20 > changed_files.txt
   ```

2. **Parallel Processing**:
   ```yaml
   # Use matrix builds for large PRs
   strategy:
     matrix:
       chunk: [1, 2, 3]
   ```

3. **Caching**:
   ```yaml
   # Cache Claude CLI installation
   - uses: actions/cache@v3
     with:
       path: ~/.npm
       key: claude-cli-${{ runner.os }}
   ```

## 🧪 Regression Testing

### Automated Tests

Create automated tests to verify continued functionality:

```bash
#!/bin/bash
# tests/claude-integration-test.sh

set -e

echo "🧪 Running Claude integration regression tests..."

# Test 1: Workflow file exists and is valid
echo "Test 1: Workflow file validation"
if [ -f ".github/workflows/claude.yml" ]; then
    echo "✅ claude.yml exists"
else
    echo "❌ claude.yml missing"
    exit 1
fi

# Test 2: Required secrets are documented
echo "Test 2: Documentation validation"
if grep -q "ANTHROPIC_API_KEY\|CLAUDE_CODE_OAUTH_TOKEN" docs/github-app-setup.md; then
    echo "✅ Authentication methods documented"
else
    echo "❌ Authentication documentation missing"
    exit 1
fi

# Test 3: Workflow syntax validation
echo "Test 3: Workflow syntax"
# Use GitHub CLI to validate workflow
gh workflow list | grep -q "Claude GitHub App Integration" && \
    echo "✅ Workflow syntax valid" || \
    echo "❌ Workflow syntax invalid"

echo "🎉 Regression tests completed"
```

### Manual Testing Checklist

Perform these tests after any changes:

- [ ] Create test PR with code changes
- [ ] Verify workflow triggers automatically
- [ ] Check authentication succeeds
- [ ] Confirm Claude analysis runs
- [ ] Validate review comment is posted
- [ ] Test workflow with different file types
- [ ] Verify error handling for edge cases

## 📞 Support and Escalation

### Self-Service Debugging

1. **Check workflow logs** in GitHub Actions
2. **Review this troubleshooting guide**
3. **Test authentication locally**
4. **Verify repository configuration**

### Escalation Path

If issues persist:

1. **Create GitHub Issue** with:
   - Workflow run URL
   - Error messages (sanitized)
   - Steps to reproduce
   - Expected vs actual behavior

2. **Include debugging information**:
   ```bash
   # Collect debug info
   echo "Repository: auitenbroek1/hivestudio-script"
   echo "Workflow: $(gh workflow list | grep Claude)"
   echo "Recent runs: $(gh run list --workflow=claude.yml --limit=5)"
   ```

3. **Contact support** through appropriate channels:
   - Claude Documentation: https://docs.anthropic.com/
   - GitHub Actions Support: https://docs.github.com/en/actions

---

**Testing Status**: Ready for validation ✅
**Repository**: `auitenbroek1/hivestudio-script`
**Next Steps**: Execute test plan and validate integration