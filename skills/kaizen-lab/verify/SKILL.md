---
name: verify
description: Check and update hypothesis verification status in KaizenLab
---

# kaizen-lab:verify

Check verification status and update hypothesis verifications in KaizenLab.

## When to use
Run `/kaizen-lab:verify` to see which hypotheses need validation, update verification results after an experiment, or when deciding what to work on next.

## Steps

### With no arguments — show verification status
1. Use `list_projects` to find the active project.
2. Call `list_verification_canvases` for that project.
3. Display a summary grouped by status:
   - 🔴 `not-started` — validations not yet begun
   - 🟡 `in-progress` — currently running experiments
   - 🟢 `validated` — confirmed hypotheses
   - ❌ `invalidated` — disproven hypotheses
4. Highlight any `in-progress` items that are blocking progress.
5. Treat a `validated` canvas whose `sections` are empty as **not** validated — flag it. A status without recorded evidence is a false positive and will mislead every later decision.
6. For every `validated` / `invalidated` canvas, call `get_verification_canvas` and check `what.qualitativeResults`. List every one that shows **未記入** under "⚠️ 結果未記録" and offer to backfill it (see "Backfill" below). Do not hide these — a closed canvas with no written result is the most common data-quality bug in this tool.

### With arguments — update a verification
If `$ARGUMENTS` contains a status update (e.g. `"validated: login conversion improved 20%"`):
1. Find the most relevant `in-progress` verification canvas.
2. Call `get_verification_canvas` first and keep its existing `sections`. See the warning below — `sections` is replaced wholesale, not merged.
3. Call `update_verification_canvas` with:
   - `status`: `validated` or `invalidated`
   - `sections`: the **merged** object, with findings in `what.qualitativeResults` and the decision in `what.nextAction`
4. **Read back** with `get_verification_canvas` and confirm 定性結果 / 次のアクション no longer show 未記入. If they do, the key path was wrong — fix and resend.
5. Prompt to record a learning with `/kaizen-lab:learn`.

## 🚦 Completion gate — never close a canvas without a written result

Setting `status` to `validated` or `invalidated` — **whether via this skill or by calling `update_verification_canvas` directly** — is only allowed when the same call also carries all of the following in `sections.what`:

| Field | Must contain |
|---|---|
| `qualitativeResults` (string) | **The result in words**: (1) the one-line verdict, (2) *why* — the mechanism or structural reason the outcome came out this way, (3) caveats — power/MDE, population, anything that limits the conclusion, (4) implementation notes if a bug or dead knob was discovered along the way. This is the part a future reader needs and numbers alone cannot give; it is the field most often left empty. |
| `quantitativeResults` (array) | One `{ id, metricName, expected, actual }` per headline number (e.g. Δ期待値 with CI, trade count, sizedDD). |
| `nextAction` (object) | `{ type: pivot \| persevere \| stop, description }` — what changes in production / what gets tried next. |

A `validated`/`invalidated` status with `qualitativeResults` empty is a **defect**, not a shortcut: close it later, or leave it `in-progress` until the write-up exists. Before every status-closing call, ask "would someone reading only this canvas understand what happened and why?" — if not, the write-up is not done.

Do **not** stash results in `why.purpose`, `how.mvpDefinition`, or a flat top-level key. Those either misfile the content or (for flat keys) silently discard it — the canvas then renders 未記入 even though something was sent.

### Backfill — filling results on already-closed canvases
When a closed canvas has 未記入 in 定性結果:
1. `get_verification_canvas` and keep the existing `why` / `how`.
2. Reconstruct the write-up from the best available source (project CLAUDE.md notes, measurement scripts, `out/` JSON, git log, chat history). If the numbers cannot be recovered, say so inside `qualitativeResults` rather than inventing them.
3. Send the merged `sections` (status unchanged) and read back.

> There is **no `result_summary` parameter**. `update_verification_canvas` accepts only `canvas_id`, `name`, `sections`, and `status`. Writing a summary anywhere else silently discards it.

## ⚠️ `sections` is replaced wholesale, not merged

Passing `sections: { what: { ... } }` **silently erases the existing `why` and `how`**.

Always `get_verification_canvas` first, merge your changes into the full object, then send all three top-level keys back.

Unknown keys are also accepted without error and silently dropped, so a single typo loses that content with no warning. Do not guess key names — use the table below.

## `sections` schema (quick reference)

The nested `{ why, how, what }` shape is required. A flat object is accepted by the API but will not render in the UI.

| UI label | Path | Type |
|---|---|---|
| 目的 (Purpose) | `why.purpose` | string |
| 検証対象の仮説 | `why.targetHypothesis` | string |
| 成功基準 | `why.successMetrics` | array of `{ id, type, description, target }` — `type` is `quantitative` or `qualitative` |
| 期待 (Expectations) | `why.expectations` | string |
| 手法 (Method) | `how.method` | enum only: `interview`, `survey`, `prototype`, `ab-test`, `analytics`, `other` |
| MVP定義 | `how.mvpDefinition` | string (multi-line OK) |
| 実施環境 | `how.environment` | object `{ tools, targetUsers, location }` |
| スケジュール | `how.schedule` | array of `{ id, label, startDate, endDate }` |
| 定量結果 | `what.quantitativeResults` | array of `{ id, metricName, expected, actual }` |
| 定性結果 | `what.qualitativeResults` | **string** |
| 学び | `what.learnings` | array of `{ id, content, tags }` |
| 次のアクション | `what.nextAction` | **object** `{ type, description }` — `type` is `pivot`, `persevere`, or `stop` |

Types are deliberately mixed and easy to get wrong:

- `qualitativeResults` is a **string**, but `quantitativeResults` is an **array**
- `nextAction` is an **object**, not a string
- `how.method` accepts the six enum values only — free text will not render

Fill `what` only after the experiment has run; it may be empty at creation time.

Full spec with JSON examples: [../overview/references/api.md](../overview/references/api.md) (section "検証キャンバスの `sections` フォーマット").

## Example

```
/kaizen-lab:verify
```
→ Shows all verifications with status summary

```
/kaizen-lab:verify validated — A/B test showed 15% lift in activation
```
→ Merges into the existing `sections`, writes the finding to `what.qualitativeResults`, sets `what.nextAction` to `{ type: "persevere", description: "..." }`, and marks the canvas `validated`

```
/kaizen-lab:verify backfill
```
→ Lists closed canvases whose 定性結果 is 未記入 and fills them one by one from available sources
