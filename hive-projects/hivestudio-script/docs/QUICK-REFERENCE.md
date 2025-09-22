# HiveStudio Ecosystem Quick Reference

## Essential Commands

### Team Management
```bash
# Spawn a team
./scripts/spawn-team.sh [template] [description]

# Available templates:
# - full-stack-team: Complete web development
# - api-team: REST API development
# - ml-team: Machine learning projects
# - mobile-team: Mobile app development

# Check team status
npx claude-flow swarm status

# Monitor team activity
npx claude-flow swarm monitor
```

### SPARC Methodology
```bash
# Full TDD workflow
npx claude-flow sparc tdd "Feature description"

# Individual phases
npx claude-flow sparc run spec-pseudocode "Requirements"
npx claude-flow sparc run architect "System design"

# Batch processing
npx claude-flow sparc batch spec-pseudocode,architect "Complex feature"
```

### Task Orchestration
```bash
# Orchestrate tasks across team
npx claude-flow task orchestrate "Implement user authentication"

# Check task status
npx claude-flow task status

# Get task results
npx claude-flow task results [task-id]
```

### Memory & Context
```bash
# Store information
npx claude-flow memory store key "value"

# Retrieve information
npx claude-flow memory retrieve key

# Search memory
npx claude-flow memory search "pattern"
```

### GitHub Integration
```bash
# Analyze repository
npx claude-flow github repo analyze owner/repo

# Manage pull requests
npx claude-flow github pr manage owner/repo --action review

# Issue tracking
npx claude-flow github issue track owner/repo --action triage
```

## Quick Start Workflows

### 1. Web Application
```bash
./quickstart.sh web-app "My App"
```

### 2. REST API
```bash
./quickstart.sh api "User Service API"
```

### 3. ML Project
```bash
./quickstart.sh ml-project "Recommendation Engine"
```

### 4. Mobile App
```bash
./quickstart.sh mobile-app "Travel App"
```

## Configuration

### Team Templates
Location: `.claude/team-templates/`
- `full-stack-team.json` - Web development
- `api-team.json` - API development
- `ml-team.json` - Machine learning
- `mobile-team.json` - Mobile development

### Workflows
Location: `.claude/workflows/`
- `sparc-tdd.json` - SPARC with TDD

### Environment
- `.env` - Environment variables
- `package.json` - Project configuration
- `.gitignore` - Git ignore rules

## Troubleshooting

### Common Issues
1. **MCP server not found**: Run `claude mcp list` to check installations
2. **Permission denied**: Make sure scripts are executable with `chmod +x`
3. **Team not spawning**: Check network connection and MCP server status

### Getting Help
- Run `npx claude-flow --help` for command help
- Check `.claude/memory/` for session logs
- Use `npx claude-flow swarm status` for team diagnostics

## Advanced Features

### Custom Agents
Create custom agent types in team templates with specific:
- Responsibilities
- Skills
- Coordination patterns

### Neural Training
```bash
# Train patterns from successful workflows
npx claude-flow neural train coordination training-data.json

# Analyze cognitive patterns
npx claude-flow neural patterns --action analyze
```

### Performance Monitoring
```bash
# Run benchmarks
npx claude-flow benchmark run

# Analyze performance
npx claude-flow performance report

# Monitor bottlenecks
npx claude-flow bottleneck analyze
```
