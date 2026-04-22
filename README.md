# Claude Token Usage Footer

Adds a persistent three-bar token usage footer to every Claude Code response — tracks context window consumption, 5-hour message rate, and weekly message rate.

```
---
Context  🟩 █████░░░░░░░░░░░░░░░░░░░░░  5.0% | ~190,000 tokens remaining
5-hour   🟩 ██░░░░░░░░░░░░░░░░░░░░░░░░  8.9% | ~41 msgs remaining
Weekly   🟩 ████░░░░░░░░░░░░░░░░░░░░░░ 16.0% | ~168 msgs remaining
```

Color coding (independent per bar):
- 🟩 Green — < 60% used
- 🟨 Yellow — 60–90% used
- 🟥 Red — > 90% used

## What each bar tracks

| Bar | Measures | Limit |
|-----|----------|-------|
| Context | Tokens used in the current context window | 200,000 tokens |
| 5-hour | Claude responses sent in the last 5 hours | 45 messages |
| Weekly | Claude responses sent in the last 7 days | 200 messages |

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
2. Patches `~/.claude/AGENTS.md` with the mandatory three-bar footer rule
3. Creates `~/.claude/projects/.../memory/usage_tracking.json` for 5-hour/weekly tracking

## Manual installation

If the script doesn't work, manually:

1. Copy `rules/common/token-usage.md` to `~/.claude/rules/common/`
2. Add the contents of `agents-patch.md` to your `~/.claude/AGENTS.md`
3. Create an empty tracking file:
   ```bash
   mkdir -p ~/.claude/projects/$(ls ~/.claude/projects/ | head -1)/memory
   echo '{"entries":[]}' > ~/.claude/projects/$(ls ~/.claude/projects/ | head -1)/memory/usage_tracking.json
   ```

## Uninstall

```bash
rm ~/.claude/rules/common/token-usage.md
# Then remove the "Token Usage Footer" section from ~/.claude/AGENTS.md
```
