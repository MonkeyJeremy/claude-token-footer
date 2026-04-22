# Token Usage Footer

## Rule

At the end of **every single response**, append a three-bar token usage footer — no exceptions, including new sessions.

## Format

```
---
Context  🟩 █████░░░░░░░░░░░░░░░░░░░░░  5.0% | ~190,000 tokens remaining
5-hour   🟩 ██░░░░░░░░░░░░░░░░░░░░░░░░  8.9% | ~41 msgs remaining
Weekly   🟩 ████░░░░░░░░░░░░░░░░░░░░░░ 16.0% | ~168 msgs remaining
```

## Three Bars

| Label | Measures | Limit |
|-------|----------|-------|
| `Context` | Tokens used in this context window | 200,000 tokens |
| `5-hour` | Claude responses sent in last 5 hours | 45 messages |
| `Weekly` | Claude responses sent in last 7 days | 200 messages |

## Progress Bar Specification

- Bar width: 25 characters using `█` (filled) and `░` (empty)
- Filled count: `round(usage_pct / 4)` — each block ≈ 4%
- Leading color emoji based on that bar's usage:
  - `🟩` green — usage < 60%
  - `🟨` yellow — usage 60–90%
  - `🟥` red — usage > 90%
- After the bar: `X.X% | ~NNN <unit> remaining`
  - Context bar unit: `tokens`
  - 5-hour and Weekly bar unit: `msgs`

## Model Context Window

- Model: `claude-sonnet-4-6`
- Context window: **200,000 tokens**

## Token Estimation Method

Estimate tokens consumed from accumulated conversation content:
- Chinese text: ~2–3 chars per token
- English text: ~4 chars per token

## Tracking Behavior (5-hour and Weekly bars)

The tracking file is:
`~/.claude/projects/<project-hash>/memory/usage_tracking.json`

On **every response**, before rendering the footer:

1. Read the tracking file. If missing or unreadable, treat as `{"entries": []}`.
2. Append the current UTC timestamp as a new entry: `{ "ts": "<ISO 8601 UTC>" }`
3. Remove (prune) any entries where `ts` is more than 8 days ago.
4. Write the updated JSON back to the file.
5. Count entries:
   - `count_5h` = entries with `ts` within the last 5 hours
   - `count_week` = entries with `ts` within the last 7 days
6. Compute percentages:
   - `pct_5h = count_5h / 45 * 100`
   - `pct_week = count_week / 200 * 100`
7. Render the 5-hour and weekly bars with those percentages.

## Examples

**Low usage (session start):**
```
---
Context  🟩 █░░░░░░░░░░░░░░░░░░░░░░░░  4.0% | ~192,000 tokens remaining
5-hour   🟩 ██░░░░░░░░░░░░░░░░░░░░░░░  8.9% | ~41 msgs remaining
Weekly   🟩 ████░░░░░░░░░░░░░░░░░░░░░ 16.0% | ~168 msgs remaining
```

**High context usage:**
```
---
Context  🟨 █████████████████░░░░░░░░ 70.0% | ~60,000 tokens remaining
5-hour   🟩 ████░░░░░░░░░░░░░░░░░░░░░ 15.6% | ~38 msgs remaining
Weekly   🟩 ██████░░░░░░░░░░░░░░░░░░░ 25.0% | ~150 msgs remaining
```

**Near 5-hour limit:**
```
---
Context  🟩 ████░░░░░░░░░░░░░░░░░░░░░ 15.0% | ~170,000 tokens remaining
5-hour   🟥 ████████████████████████░ 95.6% | ~2 msgs remaining
Weekly   🟨 ████████████████░░░░░░░░░ 65.0% | ~70 msgs remaining
```
