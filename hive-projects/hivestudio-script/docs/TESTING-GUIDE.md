# Claude Code Ecosystem Testing Guide

## Overview

This comprehensive testing guide validates the complete Claude Code ecosystem setup including swarm coordination, agent spawning, memory management, and GitHub integration. Follow this step-by-step guide to ensure everything works correctly.

## 🚨 Pre-Flight Checklist

Before starting any tests, verify these prerequisites:

### System Requirements
- [ ] **Node.js**: Version 18.0+ installed
- [ ] **npm**: Version 8.0+ installed
- [ ] **Git**: Latest version installed
- [ ] **Claude Desktop**: Latest version installed
- [ ] **Terminal**: Modern terminal with color support

### Account Setup
- [ ] **GitHub Account**: Active with repository access
- [ ] **Anthropic API Key**: Valid and properly configured
- [ ] **Claude Desktop**: Logged in and functional

### Environment Verification
```bash
# Check Node.js version (should be 18.0+)
node --version

# Check npm version (should be 8.0+)
npm --version

# Check Git configuration
git config --list

# Verify Claude Desktop connection
claude --version
```

### Expected Output Examples:
```
node --version
# Expected: v18.17.0 or higher

npm --version
# Expected: 8.19.0 or higher

git config --list
# Expected: user.name=YourName, user.email=your@email.com

claude --version
# Expected: Claude Desktop version x.x.x
```

## 🧪 Testing Procedures

### Phase 1: Core System Testing

#### 1.1 Claude Flow Installation Test

```bash
# Test Claude Flow installation
npx claude-flow@alpha --version

# Test configuration load
npx claude-flow@alpha config validate

# Test MCP server status
npx claude-flow@alpha mcp status
```

**Expected Output:**
```
npx claude-flow@alpha --version
# Expected: claude-flow version 2.x.x-alpha

npx claude-flow@alpha config validate
# Expected: ✓ Configuration valid
# Expected: ✓ MCP servers configured: 3
# Expected: ✓ Memory system initialized

npx claude-flow@alpha mcp status
# Expected: ✓ claude-flow server: running
# Expected: ✓ ruv-swarm server: running
# Expected: ✓ flow-nexus server: running
```

#### 1.2 Memory System Test

```bash
# Test memory storage
npx claude-flow@alpha memory store test-key "Hello Claude Flow"

# Test memory retrieval
npx claude-flow@alpha memory retrieve test-key

# Test memory search
npx claude-flow@alpha memory search "Claude"

# Test memory cleanup
npx claude-flow@alpha memory delete test-key
```

**Expected Output:**
```
npx claude-flow@alpha memory store test-key "Hello Claude Flow"
# Expected: ✓ Stored: test-key -> "Hello Claude Flow"

npx claude-flow@alpha memory retrieve test-key
# Expected: "Hello Claude Flow"

npx claude-flow@alpha memory search "Claude"
# Expected: Found 1 matching keys: test-key

npx claude-flow@alpha memory delete test-key
# Expected: ✓ Deleted: test-key
```

### Phase 2: Swarm Coordination Testing

#### 2.1 Basic Swarm Initialization

```bash
# Initialize mesh swarm
npx claude-flow@alpha swarm init mesh --max-agents 5

# Check swarm status
npx claude-flow@alpha swarm status

# List active swarms
npx claude-flow@alpha swarm list
```

**Expected Output:**
```
npx claude-flow@alpha swarm init mesh --max-agents 5
# Expected: ✓ Swarm initialized: mesh topology
# Expected: ✓ Max agents: 5
# Expected: ✓ Swarm ID: swarm-xxxxx

npx claude-flow@alpha swarm status
# Expected: Swarm Status: Active
# Expected: Topology: mesh
# Expected: Active Agents: 0/5
# Expected: Memory Usage: low
```

#### 2.2 Agent Spawning Test

```bash
# Spawn test agents
npx claude-flow@alpha agent spawn researcher --name "test-researcher"
npx claude-flow@alpha agent spawn coder --name "test-coder"
npx claude-flow@alpha agent spawn tester --name "test-tester"

# List agents
npx claude-flow@alpha agent list

# Check agent metrics
npx claude-flow@alpha agent metrics
```

**Expected Output:**
```
npx claude-flow@alpha agent spawn researcher --name "test-researcher"
# Expected: ✓ Agent spawned: test-researcher (researcher)
# Expected: ✓ Capabilities: [research, analysis, documentation]

npx claude-flow@alpha agent list
# Expected: 3 active agents:
# Expected: - test-researcher (researcher): active
# Expected: - test-coder (coder): active
# Expected: - test-tester (tester): active
```

### Phase 3: Task Orchestration Testing

#### 3.1 Simple Task Test

```bash
# Orchestrate simple task
npx claude-flow@alpha task orchestrate "Create a hello world function" --strategy parallel --max-agents 2

# Check task status
npx claude-flow@alpha task status

# Get task results
npx claude-flow@alpha task results <task-id>
```

**Expected Output:**
```
npx claude-flow@alpha task orchestrate "Create a hello world function"
# Expected: ✓ Task created: task-xxxxx
# Expected: ✓ Strategy: parallel
# Expected: ✓ Assigned agents: 2
# Expected: ✓ Status: running

npx claude-flow@alpha task status
# Expected: Active tasks: 1
# Expected: - task-xxxxx: running (2 agents)
```

#### 3.2 Complex Workflow Test

```bash
# Test multi-step workflow
npx claude-flow@alpha workflow create "test-workflow" \
  --steps "research,design,implement,test" \
  --agents "researcher,architect,coder,tester"

# Execute workflow
npx claude-flow@alpha workflow execute test-workflow

# Monitor workflow progress
npx claude-flow@alpha workflow status test-workflow
```

### Phase 4: GitHub Integration Testing

#### 4.1 Repository Analysis Test

```bash
# Test GitHub repository analysis
npx claude-flow@alpha github repo-analyze <your-repo> --analysis-type code_quality

# Test PR management
npx claude-flow@alpha github pr-manage <your-repo> --action review --pr-number <pr-id>
```

**Expected Output:**
```
npx claude-flow@alpha github repo-analyze owner/repo --analysis-type code_quality
# Expected: ✓ Repository analyzed: owner/repo
# Expected: ✓ Code quality score: 85/100
# Expected: ✓ Issues found: 3
# Expected: ✓ Recommendations: 5
```

### Phase 5: Neural Pattern Testing

#### 5.1 Neural Training Test

```bash
# Test neural pattern training
npx claude-flow@alpha neural train coordination --epochs 10 --training-data "sample coordination patterns"

# Check neural status
npx claude-flow@alpha neural status

# Test pattern recognition
npx claude-flow@alpha neural patterns --pattern coordination
```

**Expected Output:**
```
npx claude-flow@alpha neural train coordination --epochs 10
# Expected: ✓ Training started: coordination pattern
# Expected: ✓ Epochs: 10
# Expected: ✓ Training complete
# Expected: ✓ Accuracy: 92.5%
```

### Phase 6: Performance Testing

#### 6.1 Benchmark Test

```bash
# Run performance benchmarks
npx claude-flow@alpha benchmark run --type all

# Analyze bottlenecks
npx claude-flow@alpha bottleneck analyze

# Check resource usage
npx claude-flow@alpha performance report --format detailed
```

**Expected Output:**
```
npx claude-flow@alpha benchmark run --type all
# Expected: ✓ WASM benchmark: 145ms
# Expected: ✓ Swarm coordination: 23ms
# Expected: ✓ Memory operations: 8ms
# Expected: ✓ Agent spawning: 156ms
# Expected: ✓ Overall score: 9.2/10
```

## 🔍 Platform-Specific Testing

### GitHub Codespaces Testing

#### Setup in Codespaces:
1. **Open Codespace**: Navigate to your repository and click "Code" > "Codespaces" > "Create codespace"
2. **Wait for Environment**: Allow 2-3 minutes for full initialization
3. **Verify Dependencies**: Run the pre-flight checklist commands

#### Codespace-Specific Tests:
```bash
# Test Codespace environment
echo $CODESPACE_NAME
printenv | grep GITHUB_

# Test port forwarding (if applicable)
npx claude-flow@alpha server start --port 3000

# Test file permissions
touch test-file.txt && rm test-file.txt
```

#### Expected Codespace Output:
```
echo $CODESPACE_NAME
# Expected: some-repo-name-xxxxx

printenv | grep GITHUB_
# Expected: Multiple GITHUB_ environment variables
```

### Local Testing (macOS)

#### macOS-Specific Setup:
```bash
# Check macOS version
sw_vers

# Test Homebrew (if using)
brew --version

# Test terminal capabilities
echo $TERM
```

#### macOS-Specific Tests:
```bash
# Test file system permissions
ls -la ~/.claude*

# Test process management
ps aux | grep claude

# Test network connectivity
curl -I https://api.anthropic.com
```

### Local Testing (Windows)

#### Windows-Specific Setup:
```powershell
# Check Windows version
winver

# Test PowerShell execution policy
Get-ExecutionPolicy

# Test Node.js in PowerShell
node --version
npm --version
```

#### Windows-Specific Tests:
```powershell
# Test file permissions
Get-Acl $env:USERPROFILE\.claude*

# Test process management
Get-Process | Where-Object {$_.Name -like "*claude*"}

# Test network connectivity
Test-NetConnection -ComputerName api.anthropic.com -Port 443
```

## ✅ Validation Checkpoints

### Checkpoint 1: Installation Validation
- [ ] Claude Flow installed and accessible
- [ ] All MCP servers running
- [ ] Configuration files valid
- [ ] Memory system operational

### Checkpoint 2: Basic Functionality
- [ ] Swarm initialization working
- [ ] Agent spawning successful
- [ ] Memory operations functional
- [ ] Basic task orchestration working

### Checkpoint 3: Advanced Features
- [ ] Complex workflows executing
- [ ] GitHub integration operational
- [ ] Neural patterns training
- [ ] Performance benchmarks passing

### Checkpoint 4: Integration Testing
- [ ] Multi-agent coordination working
- [ ] Cross-session memory persistence
- [ ] Real-time monitoring active
- [ ] Error handling functional

## 🚨 Common Issues and Solutions

### Issue 1: MCP Server Connection Failed
**Symptoms:**
```
Error: Failed to connect to MCP server 'claude-flow'
```

**Solutions:**
1. **Restart MCP servers:**
   ```bash
   npx claude-flow@alpha mcp restart
   ```

2. **Check port conflicts:**
   ```bash
   lsof -i :8000-8010
   ```

3. **Verify configuration:**
   ```bash
   npx claude-flow@alpha config validate --verbose
   ```

### Issue 2: Agent Spawning Timeout
**Symptoms:**
```
Timeout: Agent 'researcher' failed to initialize within 30s
```

**Solutions:**
1. **Increase timeout:**
   ```bash
   npx claude-flow@alpha config set agent.timeout 60
   ```

2. **Check system resources:**
   ```bash
   npx claude-flow@alpha system status
   ```

3. **Clear agent cache:**
   ```bash
   npx claude-flow@alpha agent cache clear
   ```

### Issue 3: Memory System Corruption
**Symptoms:**
```
Error: Memory store corrupted or inaccessible
```

**Solutions:**
1. **Backup and reset memory:**
   ```bash
   npx claude-flow@alpha memory backup
   npx claude-flow@alpha memory reset
   ```

2. **Verify file permissions:**
   ```bash
   ls -la ~/.claude-flow/memory/
   ```

3. **Restore from backup:**
   ```bash
   npx claude-flow@alpha memory restore <backup-file>
   ```

### Issue 4: GitHub Integration Failures
**Symptoms:**
```
Error: GitHub API rate limit exceeded
Error: Repository access denied
```

**Solutions:**
1. **Check GitHub token:**
   ```bash
   npx claude-flow@alpha github auth status
   ```

2. **Wait for rate limit reset:**
   ```bash
   npx claude-flow@alpha github rate-limit
   ```

3. **Re-authenticate:**
   ```bash
   npx claude-flow@alpha github auth login
   ```

### Issue 5: Performance Degradation
**Symptoms:**
- Slow agent response times
- High memory usage
- Task timeouts

**Solutions:**
1. **Clear caches:**
   ```bash
   npx claude-flow@alpha cache clear --all
   ```

2. **Optimize swarm topology:**
   ```bash
   npx claude-flow@alpha swarm optimize
   ```

3. **Monitor resource usage:**
   ```bash
   npx claude-flow@alpha monitor --real-time
   ```

## 🎯 Success Criteria

### Complete Success Indicators:
1. **All Pre-flight Checks Pass** ✅
2. **Basic Functionality Working** ✅
3. **Advanced Features Operational** ✅
4. **Integration Tests Successful** ✅
5. **Performance Benchmarks Met** ✅

### Performance Targets:
- **Agent Spawn Time**: < 2 seconds
- **Task Orchestration**: < 5 seconds
- **Memory Operations**: < 100ms
- **GitHub Integration**: < 3 seconds
- **Overall Benchmark Score**: > 8.0/10

### Quality Indicators:
- **Zero Critical Errors** in logs
- **Memory Usage** < 500MB baseline
- **Network Latency** < 200ms average
- **Error Rate** < 1% across all operations

## 📋 Testing Checklist Summary

### Quick Validation (5 minutes):
- [ ] Run: `npx claude-flow@alpha --version`
- [ ] Run: `npx claude-flow@alpha config validate`
- [ ] Run: `npx claude-flow@alpha swarm init mesh`
- [ ] Run: `npx claude-flow@alpha agent spawn researcher`
- [ ] Run: `npx claude-flow@alpha task orchestrate "test task"`

### Full Validation (30 minutes):
- [ ] Complete all Phase 1-6 tests
- [ ] Verify all checkpoints
- [ ] Run performance benchmarks
- [ ] Test error recovery
- [ ] Validate cross-session persistence

### Continuous Monitoring:
- [ ] Set up health checks
- [ ] Configure alerting
- [ ] Monitor performance metrics
- [ ] Track error rates
- [ ] Review logs regularly

## 📞 Support and Troubleshooting

### Documentation Resources:
- **Main Documentation**: `CLAUDE.md` in project root
- **Configuration Guide**: `claude-flow.config.json`
- **Advanced Features**: `.claude-flow/` directory
- **Memory System**: `memory/` directory

### Support Channels:
- **GitHub Issues**: [claude-flow repository](https://github.com/ruvnet/claude-flow/issues)
- **Documentation**: [Official docs](https://github.com/ruvnet/claude-flow)
- **Community**: Claude Flow Discord/Slack

### Debug Information to Collect:
```bash
# Generate debug report
npx claude-flow@alpha debug report --output debug-report.json

# System information
npx claude-flow@alpha system info

# Recent logs
npx claude-flow@alpha logs --tail 100

# Configuration dump
npx claude-flow@alpha config dump --redact-secrets
```

## 🔄 Regular Maintenance

### Daily Checks:
- [ ] Verify swarm status
- [ ] Check memory usage
- [ ] Review error logs
- [ ] Monitor performance metrics

### Weekly Maintenance:
- [ ] Clear old cache files
- [ ] Update dependencies
- [ ] Backup memory store
- [ ] Run full test suite

### Monthly Maintenance:
- [ ] Update Claude Flow version
- [ ] Review and optimize configuration
- [ ] Analyze performance trends
- [ ] Update documentation

---

## 🎉 Completion Verification

If you've successfully completed all tests and checkpoints, your Claude Code ecosystem is fully operational and ready for production use!

**Final Validation Command:**
```bash
npx claude-flow@alpha health check --comprehensive
```

**Expected Success Output:**
```
✅ Claude Flow Ecosystem Health Check: PASSED
✅ All systems operational
✅ Performance within targets
✅ Ready for production use

🚀 Your Claude Code ecosystem is fully validated and operational!
```

Remember to bookmark this guide for future reference and run periodic health checks to ensure continued optimal performance.