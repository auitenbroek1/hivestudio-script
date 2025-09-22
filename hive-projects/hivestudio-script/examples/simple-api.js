// Example: Simple API development with agent coordination
// Run: node examples/simple-api.js

const { exec } = require('child_process');

async function createSimpleAPI() {
    console.log('🚀 Creating Simple API with Agent Team');

    // This example shows how to use the ecosystem for API development
    console.log('Step 1: Initialize team');
    console.log('Command: ./scripts/spawn-team.sh api-team "Simple REST API"');

    console.log('\nStep 2: Use SPARC methodology');
    console.log('Command: npx claude-flow sparc tdd "User authentication API"');

    console.log('\nStep 3: Monitor progress');
    console.log('Command: npx claude-flow swarm status');

    console.log('\n✅ Example workflow defined');
    console.log('Run the commands above to see the ecosystem in action!');
}

if (require.main === module) {
    createSimpleAPI();
}

module.exports = { createSimpleAPI };
