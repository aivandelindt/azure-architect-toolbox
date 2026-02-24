#!/bin/bash
set -e

echo "🔄 Updating development tools..."
echo ""

# Track failures
FAILURES=()

# Update pip first
echo "📦 Updating pip..."
python3 -m pip install --upgrade pip --quiet

# Update Azure CLI
echo "📦 Checking Azure CLI..."
CURRENT_AZ=$(az version --query '"azure-cli"' -o tsv 2>/dev/null || echo "unknown")
echo "  ℹ️  Current version: $CURRENT_AZ (managed by devcontainer feature, auto-upgrade disabled)"

# Update Bicep
echo "📦 Updating Bicep..."
if az bicep upgrade --only-show-errors 2>/dev/null; then
    echo "   ✅ Bicep updated"
else
    echo "  ⚠️  Bicep update skipped or failed"
    FAILURES+=("Bicep")
fi

# Update Python packages
echo "📦 Updating Python packages..."
if pip3 install --upgrade --quiet --break-system-packages checkov diagrams 2>/dev/null; then
    echo "   ✅ Python packages updated (checkov, diagrams)"
else
    echo "   ⚠️  Python package updates had issues"
    FAILURES+=("Python packages")
fi

# Update markdownlint-cli2
echo "📦 Updating markdownlint-cli2..."
if sudo npm update -g markdownlint-cli2 --silent 2>/dev/null; then
    echo "   ✅ markdownlint-cli2 updated"
else
    echo "   ⚠️  markdownlint-cli2 update had issues"
    FAILURES+=("markdownlint-cli2")
fi

# Update tflint
echo "📦 Updating tflint..."
if curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | sudo bash >/dev/null 2>&1; then
    echo "   ✅ tflint updated"
else
    echo "   ⚠️  tflint update had issues"
    FAILURES+=("tflint")
fi

# Update tfsec
echo "📦 Updating tfsec..."
if curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | sudo bash >/dev/null 2>&1; then
    echo "   ✅ tfsec updated"
else
    echo "   ⚠️  tfsec update had issues"
    FAILURES+=("tfsec")
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ ${#FAILURES[@]} -eq 0 ]; then
    echo "✅ All tool updates completed successfully!"
else
    echo "⚠️  Updates completed with some issues:"
    for fail in "${FAILURES[@]}"; do
        echo "   - $fail"
    done
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Show current versions
echo "📊 Current tool versions:"
printf "   %-15s %s\n" "Azure CLI:" "$(az version --query '\"azure-cli\"' -o tsv 2>/dev/null || echo 'unknown')"
printf "   %-15s %s\n" "Bicep:" "$(az bicep version 2>/dev/null || echo 'unknown')"
printf "   %-15s %s\n" "Checkov:" "$(checkov --version 2>/dev/null || echo 'unknown')"
printf "   %-15s %s\n" "tflint:" "$(tflint --version 2>/dev/null | head -n1 || echo 'unknown')"
printf "   %-15s %s\n" "tfsec:" "$(tfsec --version 2>/dev/null | head -n1 || echo 'unknown')"
printf "   %-15s %s\n" "Python:" "$(python3 --version 2>/dev/null || echo 'unknown')"
echo ""
