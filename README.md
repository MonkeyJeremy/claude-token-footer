# Claude Token Usage Footer

Adds a persistent token usage progress bar to every Claude Code response.

```
---
🟩 █████░░░░░░░░░░░░░░░░░░░░░ 8.0% | ~184,000 remaining
```

Color coding:
- 🟩 Green — < 60% used
- 🟨 Yellow — 60–90% used
- 🟥 Red — > 90% used

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/claude-token-footer.git
cd claude-token-footer
chmod +x install.sh
./install.sh
```

Then open a new Claude Code session — the footer will appear automatically.

## What it does

1. Copies `rules/common/token-usage.md` → `~/.claude/rules/common/`
2. Patches `~/.claude/AGENTS.md` with the mandatory footer rule

## Manual installation

If the script doesn't work, manually:

1. Copy `rules/common/token-usage.md` to `~/.claude/rules/common/`
2. Add the contents of `agents-patch.md` to your `~/.claude/AGENTS.md`

## Uninstall

```bash
rm ~/.claude/rules/common/token-usage.md
# Then remove the "Token Usage Footer" section from ~/.claude/AGENTS.md
```
