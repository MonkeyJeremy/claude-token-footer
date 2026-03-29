#!/bin/bash
# install.sh — Claude Token Usage Footer
# Installs the token usage progress bar rule into your ~/.claude config

set -e

CLAUDE_DIR="$HOME/.claude"
RULES_DIR="$CLAUDE_DIR/rules/common"
AGENTS_FILE="$CLAUDE_DIR/AGENTS.md"

# --- 1. Copy rule file ---
echo "→ Installing token-usage rule..."
mkdir -p "$RULES_DIR"
cp rules/common/token-usage.md "$RULES_DIR/token-usage.md"
echo "  ✓ Copied to $RULES_DIR/token-usage.md"

# --- 2. Patch AGENTS.md ---
PATCH_MARKER="## Token Usage Footer (MANDATORY)"

if [ ! -f "$AGENTS_FILE" ]; then
  echo "  ! $AGENTS_FILE not found — skipping AGENTS.md patch."
  echo "    Manually add the contents of agents-patch.md to your AGENTS.md."
else
  if grep -qF "$PATCH_MARKER" "$AGENTS_FILE"; then
    echo "  ✓ AGENTS.md already patched — skipping."
  else
    # Insert before "## Success Metrics" if it exists, otherwise append
    if grep -qF "## Success Metrics" "$AGENTS_FILE"; then
      # Use Python for reliable cross-platform in-place edit
      python3 - "$AGENTS_FILE" <<'PYEOF'
import sys

path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

patch = """## Token Usage Footer (MANDATORY)

**Every single response MUST end with a token usage progress bar — no exceptions, including new sessions.**

Format:
```
---
🟩 █████░░░░░░░░░░░░░░░░░░░░░ 5.0% | ~190,000 remaining
```

Rules:
- Bar = 25 chars: `█` filled + `░` empty
- Filled count = `round(usage_pct / 4)` (each block ≈ 4%)
- Color emoji based on usage: `🟩` < 60% · `🟨` 60–90% · `🟥` > 90%
- Model: `claude-sonnet-4-6`, context window: **200,000 tokens**
- Estimate tokens from conversation length (~2–3 chars/token Chinese, ~4 chars/token English)

"""

content = content.replace("## Success Metrics", patch + "## Success Metrics")

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("  ✓ Patched AGENTS.md")
PYEOF
    else
      echo "" >> "$AGENTS_FILE"
      cat >> "$AGENTS_FILE" << 'EOF'
## Token Usage Footer (MANDATORY)

**Every single response MUST end with a token usage progress bar — no exceptions, including new sessions.**

Format:
```
---
🟩 █████░░░░░░░░░░░░░░░░░░░░░ 5.0% | ~190,000 remaining
```

Rules:
- Bar = 25 chars: `█` filled + `░` empty
- Filled count = `round(usage_pct / 4)` (each block ≈ 4%)
- Color emoji based on usage: `🟩` < 60% · `🟨` 60–90% · `🟥` > 90%
- Model: `claude-sonnet-4-6`, context window: **200,000 tokens**
- Estimate tokens from conversation length (~2–3 chars/token Chinese, ~4 chars/token English)
EOF
      echo "  ✓ Appended to AGENTS.md"
    fi
  fi
fi

echo ""
echo "✅ Installation complete. Open a new Claude Code session to activate."
