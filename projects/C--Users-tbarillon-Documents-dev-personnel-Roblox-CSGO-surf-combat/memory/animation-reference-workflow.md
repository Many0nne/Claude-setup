---
name: animation-reference-workflow
description: "Pour une animation Roblox, valider sur une vidéo de référence : poses puis mouvement côte à côte, avant toute publication."
metadata:
  node_type: memory
  type: feedback
  originSessionId: f488cf2a-e9e7-4751-8d63-666bcd413540
  modified: 2026-11-01T22:58:03.067Z
---

Avant de publier une animation, faire valider par l'utilisateur les poses, puis une vidéo côte à côte référence / rendu. La méthode et les outils sont décrits dans `docs/animations.md` du dépôt CSGO_surf_combat (`tools/anim/`).

**Why:** il n'arrive pas à décrire un mouvement avec des mots, et 10 allers-retours étaient lents et coûteux. Sur la M9 (2026-11), des poses validées ont quand même donné une rotation cassée en jeu, parce que j'avais sauté la validation du mouvement quand il a dit « tu peux finir ».

**How to apply:** « tu peux finir » n'autorise pas à sauter une validation annoncée : montrer le mouvement avant de publier. Quand il demande une reproduction fidèle, mesurer la trajectoire complète sur la référence plutôt que quelques poses.
