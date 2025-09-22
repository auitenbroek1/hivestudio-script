# Claude GitHub App Setup Guide

This guide will walk you through setting up the Claude GitHub App integration for the hivestudio-script repository.

## 🚀 Quick Start

The Claude GitHub App integration provides automated code reviews and analysis for your pull requests. Follow these steps to complete the setup:

### Prerequisites

- Repository: `auitenbroek1/hivestudio-script`
- GitHub repository admin access
- Anthropic API key or Claude OAuth token

## 📋 Step-by-Step Setup

### Step 1: Install the Claude GitHub App

1. **Visit the Claude GitHub App page:**
   ```
   https://github.com/apps/claude
   ```

2. **Click "Install" or "Configure"**

3. **Select your account/organization:**
   - Choose `auitenbroek1` (your GitHub username)

4. **Configure repository access:**
   - Select "Only select repositories"
   - Choose `hivestudio-script` from the dropdown
   - Click "Install"

5. **Grant permissions:**
   The app will request permissions to:
   - Read repository contents
   - Write pull request comments
   - Read pull request metadata
   - Read repository issues

### Step 2: Configure Authentication

You have two authentication options. Choose **Option A** (recommended) or **Option B**:

#### Option A: Using OAuth Token (Recommended)

1. **Generate OAuth token using Claude CLI:**
   ```bash
   # Install Claude CLI if not already installed
   npm install -g @anthropic-ai/claude@latest

   # Generate OAuth token
   claude setup-token
   ```

2. **Follow the prompts:**
   - This will open your browser
   - Log in to your Anthropic account
   - Authorize the token
   - Copy the generated token

3. **Add token to GitHub repository secrets:**
   - Go to your repository: `https://github.com/auitenbroek1/hivestudio-script`
   - Navigate to: **Settings** → **Secrets and variables** → **Actions**
   - Click **"New repository secret"**
   - Name: `CLAUDE_CODE_OAUTH_TOKEN`
   - Value: Paste the OAuth token you generated
   - Click **"Add secret"**

#### Option B: Using API Key

1. **Get your Anthropic API key:**
   - Visit: https://console.anthropic.com/
   - Log in to your account
   - Navigate to: **Settings** → **API Keys**
   - Generate a new API key
   - Copy the key (starts with `sk-ant-`)

2. **Add API key to GitHub repository secrets:**
   - Go to your repository: `https://github.com/auitenbroek1/hivestudio-script`
   - Navigate to: **Settings** → **Secrets and variables** → **Actions**
   - Click **"New repository secret"**
   - Name: `ANTHROPIC_API_KEY`
   - Value: Paste your API key
   - Click **"Add secret"**

### Step 3: Verify Workflow Files

The repository should now have the following workflow files:

1. **`.github/workflows/claude.yml`** ✅ (Created)
2. **`.github/workflows/validate.yml`** ✅ (Existing)

### Step 4: Test the Integration

1. **Create a test branch:**
   ```bash
   git checkout -b test-claude-integration
   ```

2. **Make a small change:**
   ```bash
   echo "# Test Claude Integration" >> test-file.md
   git add test-file.md
   git commit -m "Test: Add test file for Claude integration"
   git push origin test-claude-integration
   ```

3. **Create a pull request:**
   - Go to your repository on GitHub
   - Click "Compare & pull request"
   - Add title: "Test Claude GitHub App Integration"
   - Add description: "Testing the Claude GitHub App setup"
   - Click "Create pull request"

4. **Check the results:**
   - The `claude.yml` workflow should trigger automatically
   - Look for the "Claude GitHub App Integration" workflow in the "Checks" tab
   - Claude should post a review comment on your PR

## 🔧 Configuration Options

### Environment Variables

The workflow supports these environment variables:

- `ANTHROPIC_API_KEY`: Your Anthropic API key
- `CLAUDE_CODE_OAUTH_TOKEN`: OAuth token from `claude setup-token`
- `GITHUB_TOKEN`: Automatically provided by GitHub Actions

### Workflow Triggers

The Claude integration runs on:

- **Pull Request Events:**
  - `opened`: When a new PR is created
  - `synchronize`: When commits are added to an existing PR
  - `reopened`: When a closed PR is reopened

- **Manual Trigger:**
  - `workflow_dispatch`: Can be manually triggered from GitHub Actions tab

### Customizing the Review

You can customize what Claude reviews by modifying the `review_prompt.txt` section in `.github/workflows/claude.yml`:

```yaml
# Current review criteria:
1. Code quality and best practices
2. Security vulnerabilities
3. Performance considerations
4. Maintainability and readability
5. Adherence to SPARC methodology
6. Compatibility with HiveStudio ecosystem
```

## 🛠️ Troubleshooting

### Common Issues

#### 1. "Authentication failed" error

**Problem:** Workflow fails with authentication error.

**Solution:**
- Verify you've added either `ANTHROPIC_API_KEY` or `CLAUDE_CODE_OAUTH_TOKEN` to repository secrets
- Check that the secret name matches exactly (case-sensitive)
- Regenerate the token/key if it's expired

#### 2. "Claude GitHub App not installed" error

**Problem:** Repository access error.

**Solution:**
- Reinstall the Claude GitHub App
- Ensure you selected the correct repository during installation
- Check that the app has the required permissions

#### 3. Workflow doesn't trigger on PR

**Problem:** No workflow runs appear for pull requests.

**Solution:**
- Check that `.github/workflows/claude.yml` exists in the main branch
- Verify the workflow syntax using GitHub's workflow validator
- Ensure you have Actions enabled in repository settings

#### 4. Claude CLI installation fails

**Problem:** `npm install -g @anthropic-ai/claude@latest` fails.

**Solution:**
- This is handled automatically in the workflow
- For local testing, ensure you have Node.js 18+ installed
- Use `npx @anthropic-ai/claude@latest` instead of global install

### Manual Testing

To test Claude integration locally:

```bash
# Install Claude CLI
npm install -g @anthropic-ai/claude@latest

# Authenticate (choose one)
claude auth login --api-key "your-api-key"
# OR
claude auth login --oauth-token "your-oauth-token"

# Test Claude analysis
claude ask "Review this code for quality and security" --context ./src/
```

### Workflow Logs

To debug issues:

1. Go to your repository on GitHub
2. Click **"Actions"** tab
3. Click on the failed workflow run
4. Expand the failed step to see detailed logs
5. Look for error messages starting with `❌`

## 📊 Monitoring and Metrics

### Workflow Status

Monitor your Claude integration through:

- **GitHub Actions tab**: See all workflow runs and their status
- **Pull Request checks**: View Claude review status directly on PRs
- **Workflow artifacts**: Download detailed analysis reports

### Usage Analytics

The workflow provides analytics on:

- Files analyzed per PR
- Review completion time
- Authentication method used
- Error rates and types

## 🔐 Security Considerations

### Secret Management

- **Never commit API keys** to your repository
- **Use repository secrets** for all sensitive data
- **Regenerate tokens** if compromised
- **Limit token scope** to necessary permissions only

### Access Control

- The Claude GitHub App only has access to:
  - Repository contents (read-only)
  - Pull request comments (write)
  - Pull request metadata (read)
- No access to sensitive repository settings or admin functions

## 🚀 Advanced Configuration

### Custom Review Templates

Create custom review templates in `.github/claude-templates/`:

```bash
mkdir -p .github/claude-templates
```

Example security review template:
```markdown
# Security Review Template
Review for:
- SQL injection vulnerabilities
- Cross-site scripting (XSS)
- Authentication bypasses
- Data exposure risks
- Input validation issues
```

### Integration with Other Tools

The Claude workflow can be extended to work with:

- **SonarQube**: Combine static analysis
- **CodeQL**: Security scanning
- **ESLint/Prettier**: Code formatting
- **Jest/Mocha**: Test validation

## 📞 Support

### Getting Help

1. **Check this guide first** for common issues
2. **Review workflow logs** for specific error messages
3. **Claude Documentation**: https://docs.anthropic.com/
4. **GitHub Actions Documentation**: https://docs.github.com/en/actions

### Reporting Issues

If you encounter issues:

1. **Check existing GitHub Issues** in the repository
2. **Create a new issue** with:
   - Workflow run URL
   - Error messages (remove sensitive data)
   - Steps to reproduce
   - Expected vs actual behavior

## 🎉 Success Indicators

You'll know the setup is working when:

- ✅ Pull requests trigger the Claude workflow automatically
- ✅ Claude posts review comments with code analysis
- ✅ Workflow status shows as "passing" in PR checks
- ✅ No authentication errors in workflow logs
- ✅ Analysis reports are generated and accessible

---

**Next Steps:**
- Create a test pull request to verify the integration
- Customize review prompts for your project needs
- Set up additional workflows for different review types
- Monitor usage and optimize based on your team's needs

**Repository**: `auitenbroek1/hivestudio-script`
**Setup Status**: Ready for testing ✅