---
name: canvas
description: View and update the hypothesis canvas for your project in KaizenLab
---

# kaizen-lab:canvas

View and update the hypothesis canvas for the current project in KaizenLab.

## When to use
Run `/kaizen-lab:canvas` to get a quick snapshot of your hypothesis canvas, update specific fields after new insights, or create a new canvas for a new idea.

## Steps

### With no arguments — show active canvas
1. Use `list_projects` then `list_canvases` to find the most recently updated canvas.
2. Display the canvas in a readable format:
   - **Title** and **description**
   - Key fields: `valueProposition`, `obviousProblem`, `latentProblem`, `metrics`
   - PMF score if available
3. Note which fields are empty (opportunities to strengthen the hypothesis).

### With `update` — update a field
If `$ARGUMENTS` starts with `update` (e.g. `update metrics: DAU, retention D7`):
1. Parse the field name and new value.
2. Call `update_sticky_note` or `add_sticky_note` for that field.
3. Confirm the update with ✅.

### With `new` — create a new canvas
If `$ARGUMENTS` starts with `new` followed by a title:
1. Use `list_projects` to get the project ID.
2. Call `create_canvas` with the provided title.
3. Return the canvas ID and a link to view it.

## Field reference
`purpose`, `vision`, `valueProposition`, `obviousProblem`, `latentProblem`, `means`, `advantage`, `metrics`, `revenueModel`, `marketSize`, `situation`, `trend`, `alternatives`, `channel`

These 14 values are the `field_id` enum for `add_sticky_note` / `update_sticky_note`.

To append context to an existing note without overwriting it, pass `supplementary_note` and omit `text`.

> **Not the same as the verification canvas.** The hypothesis canvas ("what we believe") uses these flat `field_id` values via sticky notes. The verification canvas ("how we will check it") uses a nested `sections` object with an entirely different schema — see `/kaizen-lab:verify` and [../overview/references/api.md](../overview/references/api.md). Mixing the two silently drops the content.

Full MCP tool reference with argument shapes: [../overview/references/api.md](../overview/references/api.md).

## Example

```
/kaizen-lab:canvas
```
→ Shows current canvas overview

```
/kaizen-lab:canvas update metrics: DAU >1000, D7 retention >40%
```
→ Updates the metrics field
