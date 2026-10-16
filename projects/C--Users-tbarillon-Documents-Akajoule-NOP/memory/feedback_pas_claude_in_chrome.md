---
name: feedback-pas-claude-in-chrome
description: "Pas de Claude in Chrome ; verifications front ciblees autorisees via preview_* de T3 (evaluate), le reste en protocole a l'utilisateur"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 3e219bb6-7fce-4688-9687-d1be9d9bf371
  modified: 2026-10-14T19:44:05.802Z
---

Ne jamais utiliser Claude in Chrome. Depuis le 2026-10-14, les **verifications ciblees** avec les outils `preview_*` de T3 Code sont autorisees : `preview_open` (open=false), `preview_navigate`, puis assertions `preview_evaluate` (texte d'un element, presence d'un composant, valeur calculee affichee, erreurs console). Un `preview_snapshot` texte (includeImage=false) seulement pour se reperer sur une page. Pas de capture d'ecran, pas de navigation exploratoire. Le jugement visuel et UX (rendu, ergonomie) reste a l'utilisateur, via un mini protocole : URL de la stack, etapes, ce qu'il faut observer.

**Why:** forfait Pro, l'utilisateur surveille le quota. Mesure : evaluate ~0,1k tokens, snapshot texte ~3,5k, image ~1,4k (voir [[t3-preview-couts]]). Il reverra la regle s'il constate qu'en fin de semaine la limite de tokens reste loin.

**How to apply:** avant de rendre la main sur un changement front, se verifier soi-meme par evaluate ciblee sur la stack du worktree, puis ne demander a l'utilisateur que le jugement visuel. Les tests automatises (Vitest, tests Django via Docker) restent a lancer soi-meme.
