# GitHub App Integration - Quick Reference

## 🚀 5-Minute Setup Commands

```bash
# 1. Install Claude CLI (use npm, not Homebrew!)
npm install -g @anthropic-ai/claude@latest

# 2. Generate OAuth Token
claude setup-token
# Copy token (starts with 'claude_oauth_')

# 3. Run automated setup script
chmod +x scripts/setup-github-app.sh
./scripts/setup-github-app.sh

# 4. Run validation tests
./tests/claude-integration-test.sh --quick
```

## 🔑 Key Success Commands

### Authentication Setup
```bash
# OAuth Token (Recommended)
claude setup-token
# Add as: CLAUDE_CODE_OAUTH_TOKEN

# API Key (Alternative)
# Get from: https://console.anthropic.com/
# Add as: ANTHROPIC_API_KEY
```

### Testing the Integration
```bash
# Quick test
./tests/claude-integration-test.sh --quick

# Full test
./tests/claude-integration-test.sh

# Create test PR
git checkout -b test-claude
echo "Test" > test.md
git add test.md
git commit -m "Test: Claude integration"
git push origin test-claude
```

## ✅ Success Checklist

- [ ] Node.js 18+ installed
- [ ] Claude CLI installed via npm
- [ ] `.github/workflows/claude.yml` exists
- [ ] OAuth token or API key generated
- [ ] Secret added to GitHub repository
- [ ] Claude GitHub App installed
- [ ] Test PR triggers workflow
- [ ] Claude posts review comment

## 📁 Essential Files

| File | Purpose | Status |
|------|---------|--------|
| `.github/workflows/claude.yml` | Main workflow | ✅ Required |
| `docs/GITHUB-APP-SUCCESS-PATH.md` | Full documentation | ✅ Created |
| `tests/claude-integration-test.sh` | Validation tests | ✅ Created |
| `scripts/setup-github-app.sh` | Automated setup | ✅ Created |
| `config/claude-app-config.template.json` | Configuration | ✅ Created |

## 🚨 Critical Success Factors

### DO ✅
- Use npm for Claude CLI installation
- Support both OAuth and API key
- Include error handling in workflows
- Test with integration script

### DON'T ❌
- Use Homebrew as primary installer
- Skip authentication setup
- Forget GitHub App permissions
- Miss workflow file in main branch

## 🔗 Quick Links

- **Install Claude App**: https://github.com/apps/claude
- **Repository Secrets**: `Settings → Secrets and variables → Actions`
- **Anthropic Console**: https://console.anthropic.com/
- **Full Documentation**: `docs/GITHUB-APP-SUCCESS-PATH.md`

## 💡 One-Liner Verification

```bash
# Quick health check
[ -f .github/workflows/claude.yml ] && \
[ -f tests/claude-integration-test.sh ] && \
echo "✅ Setup looks good!" || echo "❌ Missing files"
```

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| Workflow not triggering | Ensure `.github/workflows/claude.yml` in main branch |
| Authentication failed | Check secret names match exactly |
| No review comment | Verify pull-requests: write permission |
| Claude CLI install fails | Use npm, not Homebrew |

---

**Success Method**: npm-first installation with dual authentication
**Repository**: `auitenbroek1/hivestudio-script`
**Status**: ✅ Working