---
name: roadmap
description: View, plan, and update the project roadmap in KaizenLab
---

# kaizen-lab:roadmap

View and manage the product roadmap for the current project in KaizenLab. The roadmap is a two-layer model — **phases** (milestones) contain **items** (deliverables).

## When to use
Run `/kaizen-lab:roadmap` to see what's planned, add a new phase or item after planning sessions, or update item status as work progresses. Use it aggressively — every time you discuss what to build next, capture it on the roadmap.

## Steps

### With no arguments — show roadmap
1. Use `list_projects` to find the active project.
2. Call `list_roadmap` with that `project_id`.
3. Display phases in order, with their items grouped underneath:
   - Show item **status** (`idea` / `planned` / `in_progress` / `done`) with an emoji marker
   - Show **priority** (`must` / `should` / `could` / `wont`)
   - Mark phases with no items as opportunities to break down
4. Highlight items currently `in_progress` and the next `must` priority item to start.

### With `add phase <name>` — create a phase
If `$ARGUMENTS` starts with `add phase`:
1. Parse the phase name (and optional `target: YYYY-MM-DD` suffix).
2. Call `create_roadmap_phase` with `project_id`, `name`, optional `target_date`.
3. Confirm with ✅ and the new phase ID.

### With `add item <phase>: <title>` — create an item
If `$ARGUMENTS` starts with `add item`:
1. Resolve the phase from the name (use `list_roadmap` if needed to find `phase_id`).
2. Parse the title, and optional `priority:`, `effort:`, `status:` hints.
3. Call `create_roadmap_item` with `project_id`, `phase_id`, `title`, and any provided fields.
4. Confirm with ✅ and the new item ID.

### With `update <item_id> <field>: <value>` — update an item
If `$ARGUMENTS` starts with `update`:
1. Parse `item_id` and one or more field updates.
2. Call `update_roadmap_item` with only the fields the user changed.
3. Confirm with ✅ and show the new status / priority.

## Field reference

**Phase fields:** `name`, `description`, `target_date`
**Item fields:** `title`, `description`, `status` (`idea` / `planned` / `in_progress` / `done`), `priority` (`must` / `should` / `could` / `wont`), `effort`

> Defaults when creating: `status=idea`, `priority=should`. Items auto-order to the end of the phase.

## Example

```
/kaizen-lab:roadmap
```
→ Shows phases and items grouped by milestone

```
/kaizen-lab:roadmap add phase MVP Beta target: 2026-07-31
```
→ Creates a new phase with a target date

```
/kaizen-lab:roadmap add item MVP Beta: Onboarding redesign priority: must effort: M
```
→ Adds an item under the "MVP Beta" phase

```
/kaizen-lab:roadmap update abc-123 status: in_progress
```
→ Marks item `abc-123` as in progress

## Tips
- Tie items back to verifications: when a `verify` returns validated, add the next item on the roadmap.
- Use `must` sparingly — the roadmap is most useful when priorities are honest.
- Pair with `/kaizen-lab:canvas` and `/kaizen-lab:verify` to keep strategy, validation, and delivery in sync.
