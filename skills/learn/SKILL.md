---
name: learn
description: Record a learning from the current session into KaizenLab
---

# kaizen-lab:learn

Record a learning from the current session into KaizenLab via MCP.

## When to use
Run `/kaizen-lab:learn` at the end of a coding session, experiment, or after discovering something important. This captures institutional knowledge and feeds the hypothesis validation loop.

## Steps

1. **Understand context**: Ask the user what they learned, or infer it from recent conversation if obvious.
   - If `$ARGUMENTS` is provided, use it as the learning content directly.
   - Otherwise, summarize the key insight from the current session in 1–2 sentences.

2. **Identify project**: Use `list_projects` to find the relevant project. If only one exists, use it. If multiple, ask the user which one.

3. **Categorize the learning**:
   - `validated` — a hypothesis turned out to be correct
   - `invalidated` — a hypothesis was disproven
   - `insight` — a new observation or discovery
   - `pattern` — a recurring behavior or trend
   - `risk` — something that could go wrong

4. **Record via MCP**: Call `add_learning` with:
   - `project_id`: from step 2
   - `title`: short title (≤ 30 chars)
   - `content`: the learning detail
   - `tags`: relevant tags (e.g. `["ux", "api", "performance"]`)

5. **Confirm**: Show the user what was recorded with a ✅ and the learning ID.

## Example

```
/kaizen-lab:learn Users drop off when the onboarding has more than 3 steps
```

→ Records as insight in the active project, tags: ["ux", "onboarding"]
