# Claude GitHub App Quick Start Guide

Get your Claude GitHub App integration up and running in 5 minutes!

## 🚀 Quick Setup (5 Minutes)

### Step 1: Install Claude GitHub App (2 minutes)

1. **Visit**: https://github.com/apps/claude
2. **Click**: "Install" or "Configure"
3. **Select**: `auitenbroek1` account
4. **Choose**: "Only select repositories"
5. **Select**: `hivestudio-script`
6. **Click**: "Install"

### Step 2: Generate OAuth Token (1 minute)

```bash
# Install Claude CLI (if not already installed)
npm install -g @anthropic-ai/claude@latest

# Generate OAuth token
claude setup-token
```

**Copy the token** (starts with `claude_oauth_`)

### Step 3: Add Repository Secret (1 minute)

1. **Go to**: https://github.com/auitenbroek1/hivestudio-script/settings/secrets/actions
2. **Click**: "New repository secret"
3. **Name**: `CLAUDE_CODE_OAUTH_TOKEN`
4. **Value**: Paste your OAuth token
5. **Click**: "Add secret"

### Step 4: Test Integration (1 minute)

```bash
# Create test branch
git checkout -b test-claude-$(date +%s)

# Add test file
echo "# Testing Claude Integration" > test-claude.md
git add test-claude.md
git commit -m "Test: Claude GitHub App integration"
git push origin test-claude-$(date +%s)

# Create PR on GitHub and watch Claude review it!
```

## ✅ Verification Checklist

After setup, verify these are working:

- [ ] GitHub App installed and has repository access
- [ ] Repository secret `CLAUDE_CODE_OAUTH_TOKEN` is set
- [ ] Workflow file `.github/workflows/claude.yml` exists
- [ ] Test pull request triggers Claude workflow
- [ ] Claude posts review comment on PR

## 🔧 Alternative: API Key Setup

If OAuth token doesn't work, use API key instead:

1. **Get API key**: https://console.anthropic.com/
2. **Add secret**: `ANTHROPIC_API_KEY` (instead of OAuth token)
3. **Use same value**: Your API key (starts with `sk-ant-`)

## 🐛 Quick Troubleshooting

### "Workflow not triggering"
- Ensure `.github/workflows/claude.yml` is in main branch
- Check repository has Actions enabled

### "Authentication failed"
- Verify secret name is exactly `CLAUDE_CODE_OAUTH_TOKEN`
- Make sure token was copied completely

### "No review comment"
- Check workflow logs in Actions tab
- Verify GitHub App permissions include pull requests

## 🧪 Test Your Setup

Run the integration test:

```bash
./tests/claude-integration-test.sh --quick
```

## 📚 Need More Help?

- **Full Setup Guide**: [docs/github-app-setup.md](github-app-setup.md)
- **OAuth Token Details**: [docs/oauth-token-guide.md](oauth-token-guide.md)
- **Troubleshooting**: [docs/testing-guide.md](testing-guide.md)

---

**Repository**: `auitenbroek1/hivestudio-script`
**Status**: Ready for testing ✅

**Quick Links**:
- [Claude GitHub App](https://github.com/apps/claude)
- [Repository Secrets](https://github.com/auitenbroek1/hivestudio-script/settings/secrets/actions)
- [Anthropic Console](https://console.anthropic.com/)