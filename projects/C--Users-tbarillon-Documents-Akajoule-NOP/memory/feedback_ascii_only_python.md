---
name: feedback-ascii-only-python
description: "Jamais de caractères Unicode ambigus (espace fine insécable, ×, tirets/guillemets typographiques) ni leurs échappements dans le code : ASCII simple, ruff RUF001 bloque le commit backend"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 07f05ff1-6162-4653-bcd7-4c2dadc98dad
  modified: 2026-09-25T08:12:24.758Z
---

Dans tout le code que j'écris (backend Python en priorité, mais aussi le reste), ne jamais utiliser de caractères Unicode ambigus : espace fine insécable U+202F, espace insécable U+00A0, signe ×, tirets typographiques (– —), guillemets typographiques (’ “ ” « »), points de suspension (…), etc.
- Espaces (y compris séparateur de milliers) : **espace simple ASCII**. Pas d'échappement `" "` non plus : l'utilisateur l'a refusé.
- Multiplication dans les textes d'explication : lettre `x`.
- Tiret : `-`, apostrophe : `'`, guillemets : `"`.
- `€` et les accents français sont OK.

**Why:** le hook pre-commit ruff (RUF001) fait échouer le commit ; l'utilisateur l'a signalé plusieurs fois ("tu utilises toujours des caractères qu'il ne faut pas", "il faut utiliser un espace simple").
**How to apply:** avant d'écrire une chaîne, un commentaire ou une docstring contenant un symbole typographique, utiliser l'équivalent ASCII simple.
