---
name: viewmodel-pipeline-retex
description: "Pitfalls when making weapon viewmodels/animations for this game (Rojo sync, Studio-only assets, FBX flip); full RETEX in docs/notes"
metadata:
  node_type: memory
  type: project
  originSessionId: 6ddb2a04-ce6c-41f9-89a4-193cbb77dd3f
  modified: 2026-10-31T16:16:04.185Z
---

Full write-up: `docs/notes/retex-viewmodel-m9.md` (2026-10-31, M9 Bayonet attempt, stopped: model judged not good).

Key traps:
- ViewModels, Tools and animations live only in the Studio place, not in `src/`: renaming a weapon key in code
  requires Studio to be Rojo-synced to the SAME checkout. Studio is usually connected to port 34872 (unknown cwd); a
  worktree needs its own `rojo serve --port 34873` and the user must reconnect the plugin IN EDIT MODE (in Play:
  "Http requests can only be executed by game server").
- Blender FBX export with axis_forward=-Z, axis_up=Y, bake_space_transform → geometry flipped 180° around Y in
  Studio; sizes exact with FBX_SCALE_ALL (1 Blender unit = 1 stud).
- An AWP Blender animation pipeline exists uncommitted in worktree `CSGO_surf_combat-awp-anims` (assets/awp_viewmodel):
  check/reuse it before building another one.
- Pure-bmesh procedural modeling gave a mediocre result; prefer references or a CC0/generated base (Blender MCP libraries
  and generators are disabled by default).

**Why:** that session lost most of its time on sync/manual steps, not on the actual modeling.
**How to apply:** before any viewmodel/animation task, settle Rojo sync + publishing path first; see [[roblox-asset-publishing]].
