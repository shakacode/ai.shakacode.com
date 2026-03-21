---
layout: ../layouts/Article.astro
title: "Codex Desktop App: Projects, Worktrees, Threads, and Cleanup"
description: "A practical guide to the Codex desktop app model: when to create a new project, when to reuse one, and how auto-cleanup works."
author: "ShakaCode"
date: "March 2026"
---

If Codex desktop app terminology feels fuzzy, this mental model is the one that stays consistent:

- A **project** is an entry in your sidebar tied to a local folder/workspace.
- A **thread** is a conversation inside that project.
- A **Codex-managed worktree** is an isolated checkout Codex can use for thread work.
- A **permanent worktree** is a long-lived isolated checkout that appears as its own project and is not auto-deleted.

## What "Isolated Lane" Means in the App

In Codex app terms, an isolated lane means your work is happening in a different checkout than your main Local checkout for that repo.

That separation prevents common collisions:

- New files generated in one lane do not appear in another lane by accident.
- Dependency installs and build artifacts stay scoped to the lane you are using.
- Branch and working-copy state in one lane does not disrupt your active Local lane.

This is why permanent worktrees are useful for longer efforts: they give you a stable, separate workspace without constant context switching.

## When to Create a New Project vs Reuse One

Use this rule of thumb:

- **Create a new project** when you are switching to a different folder/repository, or when you want a separate long-lived lane from the same repo.
- **Reuse an existing project** when you are still in the same folder and just starting another task; create a new thread instead.

If your work will continue over many sessions in the same repo and you want hard isolation, create a permanent worktree project.

## How to Create a Permanent Worktree Project

In the sidebar:

1. Find the project.
2. Open the three-dot (`...`) menu.
3. Choose the permanent worktree option.

Codex creates a new project backed by a permanent worktree. You can run multiple threads from that project, and Codex does not auto-delete it.

## Auto-Cleanup: When It Happens

Codex cleanup is lifecycle-based, not a fixed nightly schedule.

By default, Codex keeps your most recent **15** Codex-managed worktrees and can remove older ones to stay under that limit.

Codex-managed worktrees are eligible for automatic deletion when:

- The associated thread is archived, or
- Codex needs to evict older worktrees to respect the retention limit.

Codex tries to preserve important worktrees and avoids auto-deleting a managed worktree if:

- The conversation is pinned,
- The thread is still in progress, or
- The worktree is permanent.

Before a managed worktree is deleted, Codex stores a snapshot so restore is possible when reopening.

## How to Configure Cleanup

In Codex desktop app:

1. Open **Settings** (`Cmd+,`).
2. Find worktree cleanup/retention controls.
3. Change the managed-worktree retention limit, or disable automatic deletion if you prefer manual cleanup.

If you never want a lane auto-deleted, use a permanent worktree for that lane.

## Practical Cleanup Workflow

For old items:

1. Archive stale threads.
2. Remove no-longer-needed projects from the sidebar.
3. Keep only active long-running lanes as permanent worktrees.

This keeps the sidebar and disk usage under control without losing active context.

## Sources

- [Codex app: Worktrees](https://developers.openai.com/codex/app/worktrees)
- [Codex app: Features](https://developers.openai.com/codex/app/features)
- [Codex app: Troubleshooting](https://developers.openai.com/codex/app/troubleshooting)
- [Codex app: Settings](https://developers.openai.com/codex/app/settings)
