---
name: feedback-captures-survol
description: "Captures de preuve d'une PR front : inclure l'état au survol (infobulle, menu) des éléments ajoutés, pas seulement la page au repos"
metadata:
  node_type: memory
  type: feedback
  originSessionId: c72d71c3-476d-453c-b7b7-2bc0ca04e06d
  modified: 2026-11-10T11:34:47.406Z
---

Quand une PR ajoute un élément dont l'information n'apparaît qu'au survol (infobulle, tooltip, menu), les captures
avant/après doivent montrer cet état survolé, en plus de la page entière au repos.

**Why:** l'utilisateur juge la lisibilité et le rendu de l'infobulle sur les captures (PR front #525, alerte des
scénarios incomplets : seules les pages au repos avaient été capturées, l'infobulle n'était pas visible).

**How to apply:** avec `scripts/nop-pr-captures.ps1`, ajouter une `-Spec` (fichier Python, mêmes outils que
`captures.py`) qui survole l'élément et capture la zone avec l'infobulle ouverte, en plus des `-Pages`. Lié à
[[feedback-tester-moi-meme]].
