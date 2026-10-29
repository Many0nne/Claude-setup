---
name: claude-setup-push-ok
description: Commit et push directs sur main autorisés en permanence pour le dépôt de config ~/.claude (Many0nne/Claude-setup)
metadata:
  node_type: memory
  type: feedback
  originSessionId: aafdc9b6-4e26-4ca8-938e-65da1dfd6eec
  modified: 2026-10-29T11:49:32.104Z
---

Le dépôt de config `~/.claude` (remote `Many0nne/Claude-setup`, public) : commit et push directs sur `main` toujours autorisés, sans redemander. Préfixe des messages `feat:` / `fix:`.

**Why:** l'utilisateur l'a dit explicitement le 2026-10-29 (« tu peux toujours push pour le repo de setup »), même après avertissement que le dépôt est public et contenait une mémoire client.
**How to apply:** après une modif de skill/config dans `~/.claude`, commiter et pousser directement ; toujours vérifier le diff avant (le `.gitignore` est une whitelist).
