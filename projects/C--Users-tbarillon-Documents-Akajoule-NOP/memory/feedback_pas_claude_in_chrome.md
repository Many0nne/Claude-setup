---
name: feedback-pas-claude-in-chrome
description: "Ne pas tester via Claude in Chrome ; demander a l'utilisateur de faire le test dans son navigateur"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 3e219bb6-7fce-4688-9687-d1be9d9bf371
  modified: 2026-10-12T14:10:12.904Z
---

Quand un test manuel dans le navigateur est necessaire (verifier un rendu, reproduire un bug front), ne pas utiliser les outils Claude in Chrome : demander a l'utilisateur de faire le test, avec des etapes precises (URL de la stack, actions, snippet console a coller, ce qu'il faut observer).

**Why:** l'utilisateur prefere garder la main sur son navigateur, et surtout il est sur le forfait Pro : Claude in Chrome (et le parallelisme associe) consomme trop de quota. Il a desactive l'extension (2026-10-12), valable de maniere generale sur tous les projets.

**How to apply:** des qu'une verification visuelle ou un test de bout en bout navigateur est utile, rediger un mini protocole de test et attendre son retour. Les tests automatises (Vitest, tests Django via Docker) restent a lancer soi-meme.
