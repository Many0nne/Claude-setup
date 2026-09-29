---
name: no-heavy-background-runs
description: Ne pas lancer de campagnes lourdes en arrière-plan — la machine de Terry crashe
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 45f9f386-d292-4078-9d83-704834124806
  modified: 2026-08-07T17:27:57.283Z
---

Ne jamais lancer les campagnes d'entraînement (train_all_v2, train_joint) ou d'autres
travaux CPU-intensifs en arrière-plan depuis Claude.

**Why:** le 2026-08-07, deux campagnes joblib à n_jobs=-2 (13 workers sur 14 cœurs) lancées
en background ont fait crasher le PC de Terry à répétition ; il l'a explicitement interdit
(« plus d'agents background ça me fait crash »).

**How to apply:** fournir à Terry la commande exacte à lancer lui-même dans son terminal
(les campagnes ont une reprise automatique) ; `training.n_jobs` est plafonné à 6 dans
`config.yaml` — ne pas le remonter sans son accord. Les petits runs (< ~1 min, un seul
processus : contrôles, exports, rapports) restent OK en premier plan.

Voir [[v2-engineer-specs]] pour le contexte projet.
