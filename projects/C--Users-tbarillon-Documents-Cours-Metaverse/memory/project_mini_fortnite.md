---
name: Project: Mini-Fortnite
description: 1v1 Roblox build+fight game — build system MVP in pure Lua (no framework)
type: project
originSessionId: 9507a5f6-c2e1-4815-bb83-3f5b9ca088e9
---
Full plan lives in `C:\Users\tbarillon\.claude\plans\i-want-to-build-jiggly-jellyfish.md`.
Source lives in `C:\Users\tbarillon\Documents\Cours\Metaverse\src\`.

Key decisions (build system MVP):
- **No framework** — pure Lua/Roblox API only (no Knit, no Wally)
- 1v1 format, build system only (no weapons/combat in MVP)
- Grid: 8-stud cells, flat Y=0 ground, ~500×500 stud arena
- Build types: WALL / FLOOR / RAMP (3 types; ROOF = FLOOR)
- Single material (one HP value), no build limit MVP
- B key toggles build mode; 1/2/3 keys select type; R key cycles ramp orientation
- Client prediction ghost (green=valid range, red=out of range); server validates all
- Staggered cascade destruction: 0.05s delay per BFS layer
- Progressive construction: Transparency 0.7 → 0 over 2s (HP 50→100)
- Turbo build: 0.15s normal / 0.05s hold
- Owner can self-deconstruct; match end = immediate wipe

File layout (mirrors Roblox Studio hierarchy):
- src/server/BuildServer.lua → ServerScriptService
- src/client/BuildClient.lua → StarterPlayerScripts
- src/shared/Constants.lua   → ReplicatedStorage/BuildShared
- src/shared/GridUtils.lua   → ReplicatedStorage/BuildShared
- src/gui/BuildHUD.lua       → StarterGui/BuildHUD

**Why:** Educational Roblox course project; VR is the main end-goal. Build system is phase 1.
**How to apply:** No framework — all tunable values in Constants.lua. Server is authoritative for all placement/destruction.
