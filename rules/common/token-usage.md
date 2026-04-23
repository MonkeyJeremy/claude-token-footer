# Token Usage Footer

## Rule

At the end of **every single response**, append a two-bar token usage footer — no exceptions, including new sessions.

## Format

```
---
5-hour   🟩 ██░░░░░░░░░░░░░░░░░░░░░░░░  8.9% | ~41 msgs remaining
Weekly   🟩 ████░░░░░░░░░░░░░░░░░░░░░░ 16.0% | ~168 msgs remaining
```

## Two Bars

| Label | Measures | Limit |
|-------|----------|-------|
| `5-hour` | Claude responses sent in last 5 hours | 500 messages |
| `Weekly` | Claude responses sent in last 7 days | 2000 messages |

## Progress Bar Specification

- Bar width: 25 characters using `█` (filled) and `░` (empty)
- Filled count: `round(usage_pct / 4)` — each block ≈ 4%
- Leading color emoji based on that bar's usage:
  - `🟩` green — usage < 60%
  - `🟨` yellow — usage 60–90%
  - `🟥` red — usage > 90%
- After the bar: `X.X% | ~NNN msgs remaining`

## Tracking Behavior (5-hour and Weekly bars)

**Fetch order**: Complete ALL response content first. The usage fetch and footer render are the **very last action** in every response — never pre-fetch at the start of a response.

On **every response**, as the final step, use this priority order:

### Primary: Chrome MCP (real-time, accurate)

1. Call `tabs_context_mcp` to discover available Chrome tabs.
2. Always navigate/reload to `https://claude.ai/settings/usage` — never read from a cached tab (stale data).
3. Execute this JavaScript in that tab:
   ```javascript
   const bars = document.querySelectorAll('[role="progressbar"]');
   ({ h5: bars[0]?.getAttribute('aria-valuenow'), wk: bars[1]?.getAttribute('aria-valuenow') });
   ```
4. If both `h5` and `wk` are non-null numeric strings:
   - `pct_5h = parseInt(h5)` — used directly as the percentage
   - `pct_week = parseInt(wk)` — used directly as the percentage
   - Remaining msgs: not meaningful (Anthropic doesn't expose the absolute cap), so show `~? msgs remaining`
5. If the JS returns null/empty/error (page not loaded, Chrome unavailable), fall through to the Fallback path.

### Fallback: JSON self-tracking

Tracking file: `~/.claude/projects/<project-hash>/memory/usage_tracking.json`

1. Read the file. If missing or unreadable, treat as `{"entries": []}`.
2. Append the current UTC timestamp as a new entry: `{ "ts": "<ISO 8601 UTC>" }`
3. Remove (prune) any entries where `ts` is more than 8 days ago.
4. Write the updated JSON back to the file.
5. Count entries:
   - `count_5h` = entries with `ts` within the last 5 hours
   - `count_week` = entries with `ts` within the last 7 days
6. Compute percentages:
   - `pct_5h = count_5h / 500 * 100`
   - `pct_week = count_week / 2000 * 100`
7. Remaining msgs: `~round((1 - pct/100) * 500)` for 5h, `~round((1 - pct/100) * 2000)` for weekly.

**Always update the JSON file** even when using Chrome MCP (keeps the fallback data fresh).

## Examples

**Low usage:**
```
---
5-hour   🟩 ░░░░░░░░░░░░░░░░░░░░░░░░░  1.0% | ~495 msgs remaining
Weekly   🟩 ░░░░░░░░░░░░░░░░░░░░░░░░░  0.5% | ~1,990 msgs remaining
```

**High usage:**
```
---
5-hour   🟩 ████░░░░░░░░░░░░░░░░░░░░░ 15.6% | ~422 msgs remaining
Weekly   🟩 ██████░░░░░░░░░░░░░░░░░░░ 25.0% | ~1,500 msgs remaining
```

**Near 5-hour limit:**
```
---
5-hour   🟥 ████████████████████████░ 95.6% | ~22 msgs remaining
Weekly   🟨 ████████████████░░░░░░░░░ 65.0% | ~700 msgs remaining
```
