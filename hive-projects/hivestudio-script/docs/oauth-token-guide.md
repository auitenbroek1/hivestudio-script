# OAuth Token Generation Guide for Claude GitHub App

This guide provides detailed instructions for generating and configuring OAuth tokens for the Claude GitHub App integration.

## 🎯 Overview

OAuth tokens provide secure, scoped access to Claude services without exposing your API key. This is the **recommended authentication method** for GitHub Actions integration.

## 📋 Prerequisites

- Claude CLI installed (`npm install -g @anthropic-ai/claude@latest`)
- Active Anthropic account
- Repository admin access to `auitenbroek1/hivestudio-script`

## 🚀 Step-by-Step Token Generation

### Step 1: Install Claude CLI

If you haven't installed the Claude CLI yet:

```bash
# Install globally
npm install -g @anthropic-ai/claude@latest

# Verify installation
claude --version
```

### Step 2: Generate OAuth Token

Run the token setup command:

```bash
claude setup-token
```

This command will:

1. **Open your default browser** automatically
2. **Redirect to Anthropic login page**
3. **Prompt for authentication** (if not logged in)
4. **Request authorization** for the token
5. **Generate and display** the OAuth token

### Step 3: Complete Browser Authentication

When the browser opens:

1. **Log in to your Anthropic account**
   - Use your existing credentials
   - Or create an account if you don't have one

2. **Review the authorization request**
   - The app will request permissions to:
     - Access Claude API on your behalf
     - Generate responses for code analysis
     - Maintain session state

3. **Click "Authorize"** to approve the token generation

4. **Copy the token** from the terminal output
   - The token will be displayed as: `claude_oauth_xxxxxxxxxxxxxxxxx`
   - Copy the entire token including the prefix

### Step 4: Add Token to GitHub Secrets

1. **Navigate to your repository**:
   ```
   https://github.com/auitenbroek1/hivestudio-script
   ```

2. **Go to repository settings**:
   - Click **"Settings"** tab (top menu)
   - Select **"Secrets and variables"** from left sidebar
   - Click **"Actions"** sub-menu

3. **Create new secret**:
   - Click **"New repository secret"** button
   - **Name**: `CLAUDE_CODE_OAUTH_TOKEN`
   - **Value**: Paste the OAuth token you copied
   - Click **"Add secret"**

## 🔧 Advanced Configuration

### Token Scopes and Permissions

The OAuth token provides access to:

- **Claude API**: Make requests to Claude models
- **Code Analysis**: Review and analyze code changes
- **Session Management**: Maintain context across requests
- **Rate Limiting**: Higher rate limits compared to API keys

### Token Lifecycle Management

#### Token Expiration
- OAuth tokens **do not expire** unless revoked
- No need for periodic renewal
- More convenient than API keys for CI/CD

#### Token Revocation
To revoke a token:

```bash
# List active tokens
claude auth list

# Revoke specific token
claude auth revoke <token-id>
```

#### Token Rotation
For security best practices, rotate tokens periodically:

```bash
# Generate new token
claude setup-token

# Update GitHub secret with new token
# Revoke old token
claude auth revoke <old-token-id>
```

## 🛠️ Troubleshooting

### Common Issues

#### 1. "Browser doesn't open automatically"

**Problem**: The `claude setup-token` command doesn't open browser.

**Solutions**:
```bash
# Manual browser approach
claude setup-token --manual

# Copy the URL shown and open manually in browser
# Complete authentication and copy token from terminal
```

#### 2. "Authentication failed in browser"

**Problem**: Browser shows authentication error.

**Solutions**:
- Clear browser cache and cookies for `anthropic.com`
- Try incognito/private browsing mode
- Use a different browser
- Check if you have an active Anthropic account

#### 3. "Token not working in GitHub Actions"

**Problem**: Workflow fails with "Invalid token" error.

**Solutions**:
- Verify the secret name is exactly: `CLAUDE_CODE_OAUTH_TOKEN`
- Check for extra spaces when copying the token
- Regenerate the token if it was corrupted
- Ensure the token includes the `claude_oauth_` prefix

#### 4. "Command not found: claude"

**Problem**: Terminal doesn't recognize `claude` command.

**Solutions**:
```bash
# Check if CLI is installed
npm list -g @anthropic-ai/claude

# Reinstall if necessary
npm uninstall -g @anthropic-ai/claude
npm install -g @anthropic-ai/claude@latest

# Use npx if global install fails
npx @anthropic-ai/claude@latest setup-token
```

### Manual Token Generation

If the automatic process fails, you can generate tokens manually:

1. **Visit the Anthropic Console**:
   ```
   https://console.anthropic.com/
   ```

2. **Navigate to API section**:
   - Log in to your account
   - Go to **Settings** → **API Keys**
   - Click **"Create Key"**

3. **Generate OAuth token**:
   - Select **"OAuth Token"** type
   - Set scope to **"Code Analysis"**
   - Add description: **"GitHub Actions - hivestudio-script"**
   - Click **"Generate"**

4. **Copy and use the token** in GitHub secrets

## 🔐 Security Best Practices

### Token Storage
- **Never commit tokens** to your repository
- **Use GitHub secrets** exclusively for token storage
- **Avoid environment variables** on local development machines
- **Don't share tokens** via email, chat, or other channels

### Access Control
- **Limit repository access** to necessary team members
- **Use organization secrets** for multi-repository access
- **Regular security audits** of token usage
- **Monitor token usage** through GitHub Actions logs

### Monitoring
```bash
# Check token usage and permissions
claude auth status

# View recent activity
claude auth activity

# List all active sessions
claude auth sessions
```

## 📊 Validation and Testing

### Verify Token Configuration

1. **Check GitHub secret exists**:
   - Go to repository **Settings** → **Secrets and variables** → **Actions**
   - Confirm `CLAUDE_CODE_OAUTH_TOKEN` is listed

2. **Test the workflow**:
   ```bash
   # Create test branch
   git checkout -b test-oauth-token

   # Make a change
   echo "Testing OAuth token" > test-oauth.md
   git add test-oauth.md
   git commit -m "Test: Verify OAuth token integration"
   git push origin test-oauth-token

   # Create PR and check if Claude workflow runs successfully
   ```

3. **Monitor workflow execution**:
   - Check **Actions** tab for workflow status
   - Review logs for authentication success
   - Verify Claude posts review comments

### Test Token Locally

```bash
# Authenticate with the token
claude auth login --oauth-token "your-oauth-token"

# Test API access
claude ask "Hello, can you analyze this simple function?" --context ./

# Check authentication status
claude auth status
```

## 🚀 Integration with Development Workflow

### Pre-commit Hooks

Set up pre-commit hooks to validate token configuration:

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check if OAuth token is configured for CI
if ! grep -q "CLAUDE_CODE_OAUTH_TOKEN" .github/workflows/claude.yml; then
    echo "Warning: Claude OAuth token not configured in workflow"
    exit 1
fi
```

### Team Onboarding

For new team members:

1. **Share this guide** for OAuth token setup
2. **Provide repository access** with appropriate permissions
3. **Test token generation** in a safe environment
4. **Verify workflow access** through a test PR

## 📞 Support and Resources

### Documentation Links
- **Claude CLI Documentation**: https://docs.anthropic.com/claude/cli
- **OAuth Token Management**: https://console.anthropic.com/docs/oauth
- **GitHub Actions Secrets**: https://docs.github.com/en/actions/security-guides/encrypted-secrets

### Getting Help

1. **Check workflow logs** for specific error messages
2. **Review this guide** for troubleshooting steps
3. **Test token locally** to isolate issues
4. **Contact support** through Anthropic Console if needed

---

**Quick Reference Commands**:
```bash
# Generate OAuth token
claude setup-token

# Check token status
claude auth status

# Test token authentication
claude auth login --oauth-token "your-token"

# List active tokens
claude auth list

# Revoke a token
claude auth revoke <token-id>
```

**Repository**: `auitenbroek1/hivestudio-script`
**Next Step**: Add token to GitHub repository secrets ✅