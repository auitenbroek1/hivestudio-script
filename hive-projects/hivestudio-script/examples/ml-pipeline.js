// Example: ML Pipeline development with specialized team
// Run: node examples/ml-pipeline.js

async function createMLPipeline() {
    console.log('🤖 Creating ML Pipeline with Specialized Team');

    console.log('Step 1: Initialize ML team');
    console.log('Command: ./scripts/spawn-team.sh ml-team "Recommendation system"');

    console.log('\nStep 2: Research and design');
    console.log('Command: npx claude-flow sparc run spec-pseudocode "User recommendation ML model"');

    console.log('\nStep 3: Implementation');
    console.log('Command: npx claude-flow sparc run architect "ML pipeline architecture"');

    console.log('\nStep 4: Training and evaluation');
    console.log('Command: npx claude-flow sparc tdd "Model training pipeline"');

    console.log('\n✅ ML Pipeline workflow defined');
}

if (require.main === module) {
    createMLPipeline();
}

module.exports = { createMLPipeline };
