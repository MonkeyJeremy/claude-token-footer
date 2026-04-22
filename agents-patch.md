# AGENTS.md Patch — Token Usage Footer Section

Add the following block to your `~/.claude/AGENTS.md`, before the `## Success Metrics` section:

---

```markdown
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
- **Context**: tokens used / 200,000 — estimate from conversation length (~2–3 chars/token Chinese, ~4 English)
- **5-hour**: responses in last 5 hours / 45 limit
- **Weekly**: responses in last 7 days / 200 limit

Bar rules (all three bars):
- Width = 25 chars: `█` filled + `░` empty
- Filled count = `round(pct / 4)` (each block ≈ 4%)
- Color emoji (independent per bar): `🟩` < 60% · `🟨` 60–90% · `🟥` > 90%

Tracking (5-hour and weekly bars):
On every response: read `usage_tracking.json`, append current UTC timestamp, prune entries >8 days old, write back. Count entries within last 5h / 7d to compute bar values.
```
