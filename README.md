# Claude Token Usage Footer

Adds a persistent two-bar token usage footer to every Claude Code response — tracks 5-hour and weekly message rate limits using real-time data from `claude.ai/settings/usage` via Chrome MCP.

```
---
5-hour   🟨 ████████████████░░░░░░░░░ 62.0% | ~? msgs remaining
Weekly   🟩 ██░░░░░░░░░░░░░░░░░░░░░░░  7.0% | ~? msgs remaining
```

Color coding (independent per bar):
- 🟩 Green — < 60% used
- 🟨 Yellow — 60–90% used
- 🟥 Red — > 90% used

## What each bar tracks

| Bar | Measures | Data Source |
|-----|----------|-------------|
| 5-hour | Current session usage % | `claude.ai/settings/usage` (Chrome MCP) |
| Weekly | Weekly all-models usage % | `claude.ai/settings/usage` (Chrome MCP) |

Values are read directly from Anthropic's settings page via Chrome MCP JavaScript —
no estimation, no guessing. Falls back to JSON self-tracking when Chrome is unavailable.

## Installation

```bash
git clone https://github.com/MonkeyJeremy/claude-token-footer.git
cd claude-token-footer
chmod +x install.sh
./install.sh
```

Then open a new Claude Code session — the footer will appear automatically on every reply.

## What the installer does

1. Copies `rules/common/token-usage.md` → `~/.claude/rules/common/`
2. Patches `~/.claude/AGENTS.md` with the mandatory two-bar footer rule
3. Creates `~/.claude/projects/.../memory/usage_tracking.json` for fallback tracking

## Manual installation

If the script doesn't work, manually:

1. Copy `rules/common/token-usage.md` to `~/.claude/rules/common/`
2. Add the contents of `agents-patch.md` to your `~/.claude/AGENTS.md`
3. Create an empty tracking file:
   ```bash
   mkdir -p ~/.claude/projects/$(ls ~/.claude/projects/ | head -1)/memory
   echo '{"entries":[]}' > ~/.claude/projects/$(ls ~/.claude/projects/ | head -1)/memory/usage_tracking.json
   ```

## Requirements

- **Chrome MCP** (Claude in Chrome extension) — for real-time usage data
- Without Chrome MCP, falls back to JSON self-tracking automatically

## Uninstall

```bash
rm ~/.claude/rules/common/token-usage.md
# Then remove the "Token Usage Footer" section from ~/.claude/AGENTS.md
```
