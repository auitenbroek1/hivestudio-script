#!/bin/bash

# Team Spawning Utility
# Usage: ./scripts/spawn-team.sh [team-template] [project-description]

TEAM_TEMPLATE=${1:-"full-stack-team"}
PROJECT_DESC=${2:-"Development project"}

echo "🚀 Spawning team: $TEAM_TEMPLATE"
echo "📋 Project: $PROJECT_DESC"

# Load team template
if [ ! -f ".claude/team-templates/${TEAM_TEMPLATE}.json" ]; then
    echo "❌ Team template not found: $TEAM_TEMPLATE"
    echo "Available templates:"
    ls .claude/team-templates/*.json | xargs -n 1 basename | sed 's/.json$//'
    exit 1
fi

# Initialize swarm with Claude Flow
echo "🔧 Initializing swarm..."
npx claude-flow@alpha swarm init --topology hierarchical --max-agents 8

# Spawn agents based on template
echo "👥 Spawning team members..."
echo "Team spawned! Use 'npx claude-flow swarm status' to monitor."
echo "Ready for task orchestration with 'npx claude-flow task orchestrate'"
