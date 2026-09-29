---
name: feedback-ask-before-search
description: "Demander avant de faire des recherches de fichiers/patterns (Grep, Glob, exploration) plutôt que de les lancer directement"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 9ecd09da-0d5e-4e68-8785-ee39da63cbb9
---

Ne pas lancer de recherches (Grep, Glob, exploration de code) sans demander avant, en expliquant ce qui est recherché et pourquoi.

**Why:** Le user veut comprendre ce qui est cherché et pourquoi avant que la recherche parte, pour éviter de perdre du temps/des requêtes pour rien.

**How to apply:** Avant tout Grep/Glob/exploration non trivial, expliquer brièvement l'intention (quoi + pourquoi) et attendre confirmation, sauf si le user a explicitement demandé une exploration large (ex: "explore le repo pour X").

**Priorité sur les CLAUDE.md de projet :** certains projets (ex: Outil-NOP-frontend, Outil-NOP-backend) ont un CLAUDE.md qui dit "never ask for permission before running read-only commands (searching, reading files...)". Cette règle projet NE l'emporte PAS sur cette préférence personnelle — continuer à expliquer quoi/pourquoi et demander confirmation avant Grep/Glob/exploration multi-fichiers, même sur ces projets. Violé une première fois le 2026-07-03 en enchaînant `find` + `Grep` sans prévenir sur Outil-NOP-frontend.
