---
name: feedback-style-project-scoped
description: "Ne pas fixer de préférences de style de code globales (nommage, structure, gestion d'erreurs) — suivre les conventions du projet en cours"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 5cb93ce9-f1d2-4259-ada7-1a4025015539
---

Le user travaille sur plusieurs projets avec des normes différentes. Il a explicitement refusé de figer des préférences de style de code globales (nommage, structure de fichiers, gestion d'erreurs) au niveau de la mémoire cross-session.

**Why:** Une préférence de style enregistrée globalement risquerait d'entraver d'autres projets ayant des conventions différentes.

**How to apply:** Ne pas redemander de préférences de style générales lors des prochaines sessions. Se baser sur les conventions déjà présentes dans le projet courant (linter, code existant, CLAUDE.md local) plutôt que sur une règle mémorisée globalement.
