#!/bin/bash

# HiveStudio Installation System v2.0
# Modern, progressive, and resilient installation wrapper

set -euo pipefail

# Script metadata
declare -r INSTALLER_VERSION="2.0.0"
declare -r SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check for installation directory
if [ ! -d "$SCRIPT_DIR/install" ]; then
    echo "❌ Error: Installation system not found"
    echo "Expected directory: $SCRIPT_DIR/install"
    echo "Please ensure you have the complete HiveStudio installation package"
    exit 1
fi

# Banner
cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                    HiveStudio Installation v2.0              ║
║          AI-Powered Development Ecosystem Setup              ║
║                                                              ║
║  Features:                                                   ║
║  • Progressive installation with graceful fallbacks         ║
║  • Environment-aware configuration                          ║
║  • Automatic retry mechanisms                               ║
║  • Comprehensive validation and health checks               ║
║  • Codespaces and Docker optimized                          ║
╚══════════════════════════════════════════════════════════════╝

EOF

echo "🚀 Starting HiveStudio Installation System v$INSTALLER_VERSION"
echo "📁 Installation directory: $SCRIPT_DIR"
echo ""

# Quick environment check
if [ -n "${CODESPACES:-}" ]; then
    echo "🔧 Detected: GitHub Codespaces environment"
elif [ -f /.dockerenv ]; then
    echo "🐳 Detected: Docker container environment"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Detected: macOS environment"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Detected: Linux environment"
fi

echo ""

# Execute main installer
exec "$SCRIPT_DIR/install/main-installer.sh" "$@"