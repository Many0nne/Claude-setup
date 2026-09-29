---
name: Win95 Portfolio skill taxonomy
description: Skill taxonomy and domain decisions made for the Win95 portfolio SPA project
type: project
---

Skills created for `C:\Users\tbarillon\Documents\Cours\portfolio`:

- `window-system` — windowStore.ts, WindowInstance, state machine, openWindow/openFile API
- `virtual-fs` — fsStore.ts, FsNode, seed constants, associations, Recycle Bin logic
- `app-registry` — types.ts + registry.ts, AppDefinition, lazy import pattern, 4-step add-app checklist
- `desktop` — Desktop.tsx, icon grid, drag-snap, localStorage keys, themes, context menu
- `ui-conventions` — 98.css rules, CSS Modules, shared primitives (ContextMenu, MenuBar, DialogBox), sound hook
- `data-layer` — projects.ts, mails.ts, playlist.ts, icons.ts shapes and conventions

**Why:** Most tasks hit exactly one of these domains. The original CLAUDE.md inlined all of it unconditionally. Splitting reduced session-start context from ~80 lines of dense content to ~35 lines (CLAUDE.md), with skills loaded only when relevant.

**How to apply:** When working in this repo, identify which skill covers the task and load it before reading source files.
