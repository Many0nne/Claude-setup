---
name: delete-merged-branches
description: "Après merge d'une PR T-Games, supprimer worktree + branche locale + branche distante sans redemander"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 0eb3fc84-bcbc-431e-9cb6-f4dfd4af9cff
  modified: 2026-10-17T20:01:23.540Z
---

Une fois une PR mergée, supprimer la branche (locale et distante) et son worktree sans attendre une nouvelle demande.

**Why:** demandé explicitement par l'utilisateur le 2026-10-17 après le merge de la PR #1 (hub Ludothèque).

**How to apply:** depuis la racine, `.\scripts\tgames-worktree.ps1 <branche> -Remove` (sortir d'abord le cwd du shell Bash du worktree, sinon « Permission denied »), puis `git branch -d <branche>` et `git push origin --delete <branche>`.
