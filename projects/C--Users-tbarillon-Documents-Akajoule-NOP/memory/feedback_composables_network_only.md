---
name: feedback-composables-network-only
description: "Dans Outil-NOP-frontend, les composables (useXxx) sont réservés aux appels réseau/API, jamais pour regrouper de la logique réutilisable générique"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 238164f9-0e73-46ff-8506-2a9ad1822d69
---

Ne pas créer de composable (`useXxx`) pour extraire de la logique métier/UI réutilisable (state de formulaire, orchestration de sauvegarde, sélection...). Les composables de ce projet ne contiennent que des appels réseau (cf. `useSituationReference`, `useBudget`, `useMoyensProduction` dans le CLAUDE.md du projet).

**Why:** Convention du projet Outil-NOP-frontend — corrigé par l'utilisateur le 2026-07-17 pendant la rédaction d'un plan de refacto (BuildingView.vue, ScenarioEditView.vue) où j'avais proposé d'extraire la logique de sauvegarde/orchestration dans des composables `useBuildingEditForm`/`useScenarioMoyenSelection`.

**How to apply:** Pour extraire de la logique de vue non-réseau (state + handlers), utiliser un `utils/*.ts` (fonctions pures/quasi-pures) ou un nouveau dossier dédié si le state est intrinsèquement lié (à valider avec l'utilisateur au cas par cas — pas de convention encore fixée au 2026-07-17). Voir [[feedback_style_project_scoped]].
