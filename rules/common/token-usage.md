# Token Usage Footer

## Rule

At the end of **every single response**, append a two-bar token usage footer — no exceptions, including new sessions.

## Format

```
---
Session  🟩 ██░░░░░░░░░░░░░░░░░░░░░░░░  8.9% | resets in Xh Ym
Weekly   🟩 ████░░░░░░░░░░░░░░░░░░░░░░ 16.0% | resets Sat 2:00 AM
```

## Two Bars

| Label | Measures | Source |
|-------|----------|--------|
| `Session` | Current session token usage | claude.ai/settings/usage "Current session" |
| `Weekly` | Weekly all-models token usage | claude.ai/settings/usage "Weekly limits / All models" |

## Progress Bar Specification

- Bar width: 25 characters using `█` (filled) and `░` (empty)
- Filled count: `round(usage_pct / 4)` — each block ≈ 4%
- Leading color emoji based on that bar's usage:
  - `🟩` green — usage < 60%
  - `🟨` yellow — usage 60–90%
  - `🟥` red — usage > 90%
- After the bar: `X.X% | <reset info from page>`
- If Chrome MCP unavailable: show `X.X% | (estimated)` using fallback

## Tracking Behavior

**Fetch order**: Complete ALL response content first. The usage fetch and footer render are the **very last action** in every response — never pre-fetch at the start of a response.

On **every response**, as the final step, use this priority order:

### Primary: Chrome MCP (real-time, accurate)

1. Call `tabs_context_mcp` to get available tabs (use `createIfEmpty: true`).
2. Navigate an existing MCP tab to `https://claude.ai/settings/usage`.
3. Execute this JavaScript to **wait for React to render** (up to 8 seconds), then extract data:
   ```javascript
   (async () => {
     return await new Promise((resolve, reject) => {
       const start = Date.now();
       const poll = () => {
         const bars = document.querySelectorAll('[role="progressbar"]');
         if (bars.length >= 2) {
           const resets = Array.from(document.querySelectorAll('p,span,div'))
             .filter(el => el.children.length === 0)
             .map(el => el.textContent.trim())
             .filter(t => /resets/i.test(t));
           resolve({
             cur: bars[0]?.getAttribute('aria-valuenow'),
             wk: bars[1]?.getAttribute('aria-valuenow'),
             curReset: resets[0] ?? null,
             wkReset: resets[1] ?? null
           });
         } else if (Date.now() - start > 8000) {
           reject('timeout: progressbars not found after 8s');
         } else {
           setTimeout(poll, 300);
         }
       };
       poll();
     });
   })()
   ```
4. If both `cur` and `wk` are non-null numeric strings:
   - `raw_session = parseInt(cur)`
   - `pct_weekly = parseInt(wk)`
   - Use `curReset` / `wkReset` text from page for the reset info field

5. **Apply compensation** for tokens consumed by the current response (since data was read before response completed):
   - Estimate `response_chars`: character count of the current response text (approximate)
   - Count `tool_calls`: number of tool calls made in this response turn
   - `estimated_tokens = (response_chars / 4) + (tool_calls * 500)`
   - `SESSION_CAPACITY = 80000`  ← calibrated from observed data; adjust if footers consistently over/under-shoot
   - `compensation_pct = round(estimated_tokens / SESSION_CAPACITY * 100, 1)`
   - `pct_session = min(raw_session + compensation_pct, 100)`
   - Note: compensation applies to **Session only** (weekly scale makes 1–5% lag negligible)

6. **Persist the real values** to the tracking file so other sessions can use them:
   - Write to `C:\Users\Jeremy Zhang\.claude\projects\E------Claude-Code\memory\usage_tracking.json`:
     ```json
     {
       "last_real": {
         "ts": "<ISO 8601 UTC now>",
         "pct_session": <raw_session>,
         "pct_weekly": <pct_weekly>,
         "curReset": "<curReset text>",
         "wkReset": "<wkReset text>"
       }
     }
     ```
7. Render footer with compensated `pct_session` and raw `pct_weekly`.
8. If JS throws / returns null after timeout → fall through to Fallback.

### Fallback: last known real values (when Chrome MCP unavailable)

Tracking file: `C:\Users\Jeremy Zhang\.claude\projects\E------Claude-Code\memory\usage_tracking.json`

> Do NOT use message-count estimation — it is completely inaccurate.
> Always use the last real values written by a successful Chrome MCP read.

1. Read the file. If missing or `last_real` absent → show `N/A | Chrome MCP unavailable`.
2. Read `last_real.ts` and compute `age_minutes = (now - ts) / 60`.
3. Use `last_real.pct_session` and `last_real.pct_weekly` as the percentages.
4. Apply time-decay to session % (session resets on a ~5h window, so estimate drift):
   - `decayed_session = min(last_real.pct_session + age_minutes * 0.15, 100)`
   - (0.15%/min ≈ 9%/hr is a rough drift rate; acceptable approximation)
   - If `age_minutes > 60`, note the staleness explicitly
5. Reset info: show `(last read Xm ago)` so the user knows data is stale.

## Examples

**Live data from Chrome MCP:**
```
---
Session  🟩 ░░░░░░░░░░░░░░░░░░░░░░░░░  8.9% | resets in 4h 12m
Weekly   🟩 ████░░░░░░░░░░░░░░░░░░░░░ 16.0% | resets Sat 2:00 AM
```

**High usage (live):**
```
---
Session  🟨 ████████████████░░░░░░░░░ 65.0% | resets in 1h 48m
Weekly   🟩 ███████████░░░░░░░░░░░░░░ 45.0% | resets Sat 2:00 AM
```

**Fallback (estimated, Chrome MCP unavailable):**
```
---
Session  🟩 ██░░░░░░░░░░░░░░░░░░░░░░░ 10.0% | (estimated)
Weekly   🟩 ███░░░░░░░░░░░░░░░░░░░░░░ 12.0% | (estimated)
```

**Near session limit (live):**
```
---
Session  🟥 ████████████████████████░ 95.0% | resets in 0h 8m
Weekly   🟨 ████████████████░░░░░░░░░ 65.0% | resets Sat 2:00 AM
```
