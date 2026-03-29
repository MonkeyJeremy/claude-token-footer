# Token Usage Footer

## Rule

At the end of **every single response**, append a token usage progress bar footer — no exceptions, including new sessions.

## Format

```
---
🟩 █████░░░░░░░░░░░░░░░░░░░░░ 5.0% | ~190,000 remaining
```

## Progress Bar Specification

- Bar width: 25 characters using `█` (filled) and `░` (empty)
- Filled count: `round(usage_pct / 4)` — each block ≈ 4%
- Leading color emoji based on total usage:
  - `🟩` green — usage < 60%
  - `🟨` yellow — usage 60–90%
  - `🟥` red — usage > 90%
- After the bar: `X.X% | ~XXX,XXX remaining`

## Model Context Window

- Model: `claude-sonnet-4-6`
- Context window: **200,000 tokens**

## Token Estimation Method

Estimate tokens consumed from accumulated conversation content:
- Chinese text: ~2–3 chars per token
- English text: ~4 chars per token

## Examples

| Usage | Footer |
|-------|--------|
| 5% | `🟩 █░░░░░░░░░░░░░░░░░░░░░░░░ 5.0% \| ~190,000 remaining` |
| 15% | `🟩 ████░░░░░░░░░░░░░░░░░░░░░ 15.0% \| ~170,000 remaining` |
| 70% | `🟨 █████████████████░░░░░░░░ 70.0% \| ~60,000 remaining` |
| 95% | `🟥 ████████████████████████░ 95.0% \| ~10,000 remaining` |
