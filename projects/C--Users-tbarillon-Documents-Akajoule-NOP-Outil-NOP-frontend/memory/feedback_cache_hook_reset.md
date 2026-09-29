---
name: feedback-cache-hook-reset
description: Si le hook context-cache bloque la lecture d'un fichier, vider file_context_cache.json
metadata:
  type: feedback
---

Le hook de context-cache empêche de lire deux fois un même fichier. Si l'utilisateur fournit des fichiers en contexte mais annule pendant la lecture, Claude ne possède pas le fichier mais le hook marque quand même le fichier comme "lu" — bloquant toute relecture.

**Why:** Le PostToolUse hook se déclenche à la fin de la lecture ; si la lecture est annulée en cours, l'état du cache peut être incohérent.

**How to apply:** Informer l'utilisateur qu'il peut débloquer la situation en vidant le cache via :
`! echo '{"session_id":"","files":{}}' > .claude/file_context_cache.json`
Sinon : attendre que la lecture soit complète avant d'annuler, ou annuler avant que le tool Read soit lancé.
