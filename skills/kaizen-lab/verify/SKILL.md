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

### With arguments — update a verification
If `$ARGUMENTS` contains a status update (e.g. `"validated: login conversion improved 20%"`):
1. Find the most relevant `in-progress` verification canvas.
2. Call `update_verification_canvas` with:
   - `status`: `validated` or `invalidated`
   - `result_summary`: brief summary of findings
3. Prompt to record a learning with `/kaizen-lab:learn`.

## Example

```
/kaizen-lab:verify
```
→ Shows all verifications with status summary

```
/kaizen-lab:verify validated — A/B test showed 15% lift in activation
```
→ Marks the active in-progress verification as validated
