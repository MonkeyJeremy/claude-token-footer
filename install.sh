#!/bin/bash
# install.sh — Claude Token Usage Footer
# Installs the three-bar token usage footer rule into your ~/.claude config

set -e

CLAUDE_DIR="$HOME/.claude"
RULES_DIR="$CLAUDE_DIR/rules/common"
AGENTS_FILE="$CLAUDE_DIR/AGENTS.md"

# --- 1. Copy rule file ---
echo "→ Installing token-usage rule..."
mkdir -p "$RULES_DIR"
cp rules/common/token-usage.md "$RULES_DIR/token-usage.md"
echo "  ✓ Copied to $RULES_DIR/token-usage.md"

# --- 2. Create usage_tracking.json in the first project memory dir ---
echo "→ Setting up usage tracking..."
PROJECT_DIR=$(ls -d "$CLAUDE_DIR/projects/"*/ 2>/dev/null | head -1)
if [ -n "$PROJECT_DIR" ]; then
  MEMORY_DIR="$PROJECT_DIR/memory"
  TRACKING_FILE="$MEMORY_DIR/usage_tracking.json"
  mkdir -p "$MEMORY_DIR"
  if [ ! -f "$TRACKING_FILE" ]; then
    echo '{"entries":[]}' > "$TRACKING_FILE"
    echo "  ✓ Created $TRACKING_FILE"
  else
    echo "  ✓ Tracking file already exists — skipping."
  fi
else
  echo "  ! No project directories found in $CLAUDE_DIR/projects/"
  echo "    The tracking file will be created automatically on first use."
fi

# --- 3. Patch AGENTS.md ---
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
      python3 - "$AGENTS_FILE" <<'PYEOF'
import sys

path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

patch = """## Token Usage Footer (MANDATORY)

**Every single response MUST end with a three-bar token usage footer — no exceptions, including new sessions.**

Format:
```
---
Context  🟩 █████░░░░░░░░░░░░░░░░░░░░░  5.0% | ~190,000 tokens remaining
5-hour   🟩 ██░░░░░░░░░░░░░░░░░░░░░░░░  8.9% | ~41 msgs remaining
Weekly   🟩 ████░░░░░░░░░░░░░░░░░░░░░░ 16.0% | ~168 msgs remaining
```

Bars:
- **Context**: tokens used / 200,000 — estimate from conversation length (~2–3 chars/token Chinese, ~4 English)
- **5-hour**: responses in last 5 hours / 45 limit
- **Weekly**: responses in last 7 days / 200 limit

Bar rules (all three bars):
- Width = 25 chars: `█` filled + `░` empty
- Filled count = `round(pct / 4)` (each block ≈ 4%)
- Color emoji (independent per bar): `🟩` < 60% · `🟨` 60–90% · `🟥` > 90%

Tracking (5-hour and weekly bars):
On every response: read `usage_tracking.json`, append current UTC timestamp, prune entries >8 days old, write back. Count entries within last 5h / 7d to compute bar values.

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

**Every single response MUST end with a three-bar token usage footer — no exceptions, including new sessions.**

Format:
```
---
Context  🟩 █████░░░░░░░░░░░░░░░░░░░░░  5.0% | ~190,000 tokens remaining
5-hour   🟩 ██░░░░░░░░░░░░░░░░░░░░░░░░  8.9% | ~41 msgs remaining
Weekly   🟩 ████░░░░░░░░░░░░░░░░░░░░░░ 16.0% | ~168 msgs remaining
```

Bars:
- Context: tokens used / 200,000 — estimate from conversation length
- 5-hour: responses in last 5 hours / 45 limit
- Weekly: responses in last 7 days / 200 limit

Bar rules: width=25, filled=round(pct/4), color 🟩<60% 🟨60-90% 🟥>90%
EOF
      echo "  ✓ Appended to AGENTS.md"
    fi
  fi
fi

echo ""
echo "✅ Installation complete. Open a new Claude Code session to activate."
