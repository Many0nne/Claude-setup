---
name: external-review-critique
description: "L'utilisateur relaie des retours de ChatGPT (qui n'a pas accès au code) et attend un regard critique, pas une exécution docile"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: cd97a441-81c2-4378-8b06-df680edf843f
  modified: 2026-07-21T09:15:56.294Z
---

Sur le projet OSER, l'utilisateur transmet régulièrement des **retours de ChatGPT** en précisant que celui-ci **n'a pas lu le code**, et demande explicitement d'avoir « un regard critique sur le sujet ».

**Why:** ces retours contiennent des demandes pertinentes sur le fond, mais aussi des erreurs factuelles (numérotation des phases, hypothèses sur ce que contiennent les fichiers) et des demandes techniquement impossibles telles que formulées (ex. « estimer le gain d'un élargissement de grille » ne se déduit pas de la table des paramètres, qui ne contient que l'optimum retenu, pas le profil de RMSE le long de la grille).

**How to apply:** traiter le retour comme un cahier des charges à instruire, pas à appliquer. Corriger explicitement les erreurs de fait dès le début de la réponse, expliciter la méthode retenue quand la demande est irréalisable telle quelle, et signaler les pièges méthodologiques avant de produire les chiffres (grille emboîtée ⇒ RMSE train non probante ; besoin d'un groupe témoin ; `expm1 ≥ −1` ne garantit pas la positivité). Voir [[project-status]] et [[hybrid-model-decisions]].
