---
name: t3-preview-couts
description: Mesure du 2026-10-14 du cout en tokens des outils preview_* de T3 Code (alternative a Claude in Chrome pour verifier le front)
metadata:
  node_type: memory
  type: reference
  originSessionId: 26648df0-37ea-48f2-8867-ad727b6088f8
  modified: 2026-10-14T19:44:10.396Z
---

Mesure faite le 2026-10-14 sur la landing du front (stack worktree, port 3100), estimee a partir de la taille des reponses :
- `preview_open` (open=false, en arriere-plan) : ~0,2k tokens.
- `preview_snapshot` avec includeImage=false : ~11 Ko de JSON, soit ~3,5k tokens sur une page longue (texte visible + elements interactifs + console + reseau). Les erreurs console et les appels reseau en echec y figurent (utile pour les 401/500).
- Image de capture 1280x800 : ~1,4k tokens en plus si includeImage=true.
- `preview_evaluate` cible (assertion JS qui renvoie quelques champs) : ~0,1k tokens.

Usage econome : verifier par `preview_evaluate` (assertions), un snapshot texte seulement pour s'orienter, l'image seulement pour un rendu visuel. Le jugement UX reste a l'utilisateur.
Statut : verifications ciblees (evaluate) autorisees le 2026-10-14, voir [[feedback-pas-claude-in-chrome]].
