---
name: plan-file-workflow
description: >
  Use when work should be governed by a persisted markdown plan file with explicit lifecycle
  states. Enforces draft -> in progress -> done transitions, yaml front matter validation,
  and strict separation between planning edits and implementation work.
---

Use this skill when a task should be managed through a plan file stored in the workspace.

## Purpose

This workflow separates planning from execution.

- A plan file is a markdown document written by an `architect` or planner-style agent.
- The plan file is the source of truth for execution scope.
- Plan content is mutable only while plan status is `draft`.
- Execution is allowed only while plan status is `in progress`.
- Completion is recorded by a `reviewer` agent setting status to `done`.

## Plan File Format

The plan file must be markdown with YAML front matter at the top.

Required front matter fields:

```yaml
---
status: draft
created_at: 2026-06-15T12:00:00Z
updated_at: 2026-06-15T12:00:00Z
readonly: false
---
```

Field rules:

- `status`: one of `draft`, `in progress`, `done`
- `created_at`: timestamp string
- `updated_at`: timestamp string
- `readonly`: boolean

`readonly: true` means the file must not be edited, regardless of status.

## Core Rules

1. Never create, edit, or execute against a plan file without reading its current contents first.
2. Never change plan body content unless `status` is exactly `draft`.
3. Never change plan body content when `status` is `in progress` or `done`.
4. Never execute a plan unless `status` is exactly `in progress`.
5. Never mark a plan `done` yourself during implementation. A `reviewer` agent must set that state after changes are complete.
6. Always update `updated_at` whenever the plan file itself is legitimately modified.
7. Treat `readonly: true` as a hard stop for plan edits.

## Workflow

### 1. Gather

Collect enough context to understand the task boundaries, constraints, and affected files.

- Read relevant code, docs, and configuration.
- Ask clarifying questions only when necessary.
- Do not write a plan prematurely.

### 2. Draft Plan

When enough information has been gathered to formulate a concrete plan:

- Use an `architect` agent, or equivalent planner role, to write the plan file.
- If the plan file already exists, read it first and verify:
  - `status` is `draft`
  - `readonly` is `false`
- Only then create or edit the plan content.
- Keep the plan specific, actionable, and scoped to the requested work.

Recommended plan structure:

```md
---
status: draft
created_at: 2026-06-15T12:00:00Z
updated_at: 2026-06-15T12:00:00Z
readonly: false
---

# Goal

Short statement of desired outcome.

# Context

Relevant findings, assumptions, and constraints.

# Steps

1. Concrete implementation step.
2. Concrete verification step.
3. Concrete review or follow-up step.

# Risks

Known risks, edge cases, or open questions.
```

After the draft plan is complete:

- Do not start implementation.
- Request that the user change `status` to `in progress`.
- Make it explicit that execution cannot begin until that status change happens.

### 3. Execute Plan

Before making code changes:

- Read the plan file again.
- Verify all of the following:
  - `status` is `in progress`
  - `readonly` is `false`
  - the plan content matches the work to be executed

Execution rules:

- Follow the plan as written.
- Do not edit plan body content during execution.
- If the plan is wrong, stale, or incomplete, stop execution.
- Request that the user move the plan back to `draft` before any plan changes are made.

If `status` is `draft`:

- You may refine the plan content, but you may not execute it.

If `status` is `done`:

- Do not execute the plan.
- Create a new draft plan or ask the user how they want to proceed.

### 4. Review And Close

After implementation and verification are complete:

- Hand off to a `reviewer` agent.
- The reviewer validates that planned work is complete.
- The reviewer sets `status` to `done` and updates `updated_at`.

Implementation agents must not set `status: done` themselves.

## Required Behaviors

When writing a new plan file:

- Ensure initial status is `draft`.
- Set `created_at` and `updated_at`.
- Set `readonly` explicitly.

When modifying an existing draft plan:

- Re-read the file immediately before editing.
- Confirm status is still `draft`.
- Update `updated_at`.

When asked to execute work from a plan:

- Refuse execution unless status is `in progress`.
- State the exact blocker plainly if the status is wrong.

When a plan is in `in progress` or `done`:

- Refuse any request to modify plan content.
- Instruct the user to move the plan back to `draft` if content must change.

## Decision Rules

- If there is no plan file yet and enough context exists: create a draft plan.
- If there is no plan file yet and context is insufficient: gather more information first.
- If a draft plan exists: editing is allowed, execution is not.
- If an in-progress plan exists: execution is allowed, editing is not.
- If a done plan exists: neither editing nor execution is allowed.

## Example User-Facing Messages

Draft finished:

> The plan file is complete and remains in `draft`. Please change its status to `in progress` when you want execution to begin.

Execution blocked:

> I cannot execute this plan because its status is `draft`. Execution is only allowed when the plan status is `in progress`.

Edit blocked:

> I cannot change this plan because its status is `in progress`. Plan content can only be changed in `draft`.

Review handoff:

> Implementation is complete. A reviewer must validate the work and then set the plan status to `done`.
