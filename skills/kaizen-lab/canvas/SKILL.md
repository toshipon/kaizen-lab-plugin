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

## Example

```
/kaizen-lab:canvas
```
→ Shows current canvas overview

```
/kaizen-lab:canvas update metrics: DAU >1000, D7 retention >40%
```
→ Updates the metrics field
