---
name: plans-go-in-docs
description: "Les plans d'implémentation doivent être écrits dans docs/ du projet, pas dans le fichier de plan interne de la session"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: d4d11652-f397-41fb-9cba-b763349185d5
  modified: 2026-07-21T16:32:28.807Z
---

Sur le projet OSER, un plan d'implémentation se rédige dans **`docs/v2/PLAN_<sujet>.md` (dossier de la version courante depuis D-27)** du dépôt
(à côté de `PLAN_implementation_modele_hybride.md`), et non dans le fichier de plan temporaire
du mode plan.

**Why:** le projet capitalise tout son raisonnement dans `docs/` — plans, `journal/session_XX`,
ADR `DECISIONS.md`. Un plan qui reste hors du dépôt est perdu pour les sessions suivantes et
pour les autres intervenants. L'utilisateur demande souvent un plan **sans vouloir l'implémenter
tout de suite** : le document est alors le livrable, pas une étape vers du code.

**How to apply:** écrire le plan directement dans `docs/`, avec un renvoi croisé depuis le plan
parent s'il en existe un, et marquer explicitement « non implémenté ». Ne pas enchaîner sur
l'implémentation sans demande claire. Voir [[project-status]].
