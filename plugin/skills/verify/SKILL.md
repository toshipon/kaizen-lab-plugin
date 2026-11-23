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
2. Call `list_verification_canvases` for that project (`format: "json"` returns every field, including `sections`).
3. Display a summary grouped by status:
   - 🔴 `not-started` — validations not yet begun
   - 🟡 `in-progress` — currently running experiments
   - 🟢 `validated` — confirmed hypotheses
   - ❌ `invalidated` — disproven hypotheses
4. Highlight any `in-progress` items that are blocking progress.
5. Treat a `validated` canvas whose `sections` are empty as **not** validated — flag it. A status without recorded evidence is a false positive and will mislead every later decision.
6. For every `validated` / `invalidated` canvas, check `what.qualitativeResults` (`get_verification_canvas` with `format: "json"`). List every one that is empty under "⚠️ 結果未記録" and offer to backfill it (see "Backfill" below). Do not hide these — a closed canvas with no written result is the most common data-quality bug in this tool.

### With arguments — update a verification
If `$ARGUMENTS` contains a status update (e.g. `"validated: login conversion improved 20%"`):
1. Find the most relevant `in-progress` verification canvas.
2. Call `update_verification_canvas` with:
   - `status`: `validated` or `invalidated`
   - `sections_patch`: `{ what: { qualitativeResults: "...", quantitativeResults: [{ id, metricName, expected, actual }], nextAction: { type, description } } }`
     (deep-merged into the existing sections; `sections` would replace all of them and drop Why/How)
3. **Read back** with `get_verification_canvas` and confirm 定性結果 / 次のアクション no longer show 未記入. If they do, the key path was wrong — fix and resend.
4. Prompt to record a learning with `/kaizen-lab:learn`.

## 🚦 Completion gate — never close a canvas without a written result

Setting `status` to `validated` or `invalidated` — **whether via this skill or by calling `update_verification_canvas` directly** — is only allowed when the same call also carries all of the following in `sections_patch.what` (or the canvas already has them):

| Field | Must contain |
|---|---|
| `qualitativeResults` (string) | **The result in words**: (1) the one-line verdict, (2) *why* — the mechanism or structural reason the outcome came out this way, (3) caveats — power/MDE, population, anything that limits the conclusion, (4) implementation notes if a bug or dead knob was discovered along the way. This is the part a future reader needs and numbers alone cannot give; it is the field most often left empty. |
| `quantitativeResults` (array) | One `{ id, metricName, expected, actual }` per headline number. |
| `nextAction` (object) | `{ type: pivot \| persevere \| stop, description }` — what changes next. |

A `validated`/`invalidated` status with `qualitativeResults` empty is a **defect**, not a shortcut: close it later, or leave it `in-progress` until the write-up exists. Before every status-closing call, ask "would someone reading only this canvas understand what happened and why?" — if not, the write-up is not done.

Do **not** stash results in `why.purpose`, `how.mvpDefinition`, or a flat top-level key. Those either misfile the content or do not render — the canvas then shows 未記入 even though something was sent.

### Backfill — filling results on already-closed canvases
When a closed canvas has 未記入 in 定性結果:
1. `get_verification_canvas` with `format: "json"` to see what is stored.
2. Reconstruct the write-up from the best available source (project notes, measurement scripts, output JSON, git log, chat history). If the numbers cannot be recovered, say so inside `qualitativeResults` rather than inventing them.
3. Send it with `sections_patch` (status unchanged) and read back.

> `update_verification_canvas` has no `result_summary` argument. Results go in `sections_patch.what` (or `sections.what`); a summary passed under any other name is not stored.

## `sections` vs `sections_patch`

- `sections` **replaces the whole object**. Passing `sections: { what: { ... } }` erases the existing `why` and `how`.
- `sections_patch` deep-merges into the stored sections. Arrays, strings and `null` replace the stored value. Use it for every partial update.
- The two cannot be sent in the same call.
- Unknown keys are not rejected, but they do not render. Do not guess key names — use the table below.

## `sections` schema (quick reference)

The nested `{ why, how, what }` shape is required. A flat object is accepted by the API but will not render in the UI.

| UI label | Path | Type |
|---|---|---|
| 目的 (Purpose) | `why.purpose` | string |
| 検証対象の仮説 | `why.hypothesisStatement` | string (`why.targetHypothesis` / `why.stickyNoteId` are written by the server from `hypothesis_canvas_id` / `sticky_note_id`) |
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
→ Shows all verifications with status summary, and lists closed canvases with no written result

```
/kaizen-lab:verify validated — A/B test showed 15% lift in activation
```
→ Writes the finding to `what.qualitativeResults` and `what.nextAction` through `sections_patch`, marks the canvas `validated`, and reads it back

```
/kaizen-lab:verify backfill
```
→ Lists closed canvases whose 定性結果 is 未記入 and fills them one by one from available sources
