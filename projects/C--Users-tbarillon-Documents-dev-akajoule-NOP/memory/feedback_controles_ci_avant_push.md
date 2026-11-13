---
name: feedback_controles_ci_avant_push
description: "NOP - avant push, rejouer les memes controles que la CI (mypy back, prettier/eslint sur tout le depot front)"
metadata:
  node_type: memory
  type: feedback
  originSessionId: feaddece-58cf-489b-9342-1639e6b9dd24
  modified: 2026-11-12T15:53:49.380Z
---

Avant de pousser une PR NOP, lancer les controles exacts de la CI, pas une version reduite :
- back : `docker compose exec web mypy app` (en plus de ruff et des tests) ;
- front : `yarn prettier --check .` et `yarn eslint .` sur tout le depot (specs Markdown de `docs/` comprises), pas seulement `src/`.

**Why:** PR back #506 / front #538 (2026-11-12) : CI rouge sur un type mypy et sur le formatage d'une spec `.md`, alors que les tests locaux passaient.

**How to apply:** derniere etape avant `git push`, dans chaque worktree modifie.
