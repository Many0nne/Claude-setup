---
name: chiffrage-jours-homme
description: "Comment chiffrer une charge pour l'utilisateur — vitesse de Claude, demi-journées, valeur haute unique"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 1ac3ac61-c881-4f4b-b301-42843ed888d3
  modified: 2026-11-02T23:00:18.481Z
---

Chiffrer une charge sur la vitesse réelle de Claude (temps de travail + calcul + validation par l'utilisateur), pas comme si l'utilisateur faisait tout seul ; exprimer en jours-homme arrondis à la demi-journée ; en cas de doute, donner une seule valeur = la borne haute (pas de fourchette « 0,5-1 j », écrire « 1 j »).

**Why:** l'utilisateur trouve mes estimations souvent trop larges (référence : toute l'étude STFMO jusqu'à la synthèse a pris ~5 h de session le 2026-10-28), et veut un chiffre unique présentable.

**How to apply:** pour tout chiffrage (lots, tâches, devis), tableau par étape avec charge unique et cumul, en demi-journées.
