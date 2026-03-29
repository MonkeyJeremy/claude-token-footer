# AGENTS.md Patch — Token Usage Footer Section

Add the following block to your `~/.claude/AGENTS.md`, before the `## Success Metrics` section:

---

```markdown
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
```
