---
name: feedback-no-unprompted-checks
description: "Ne pas lancer type-check/build/lint de son propre chef pendant un refacto, même pour vérifier son propre travail — continuer la tâche, laisser le développeur vérifier"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 238164f9-0e73-46ff-8506-2a9ad1822d69
---

Ne pas lancer `yarn type-check`, `vue-tsc`, build ou autre commande de vérification sans que le user le demande, même pour valider une modification qu'on vient de faire.

**Why:** Corrigé le 2026-07-17 pendant un refacto sur Outil-NOP-frontend — j'ai tenté de lancer vue-tsc après avoir réécrit BuildingView.vue, le user a coupé l'exécution avec "laisse les checks pour l'instant juste continue". Cohérent avec la règle globale CLAUDE.md "Tests: Never run tests unprompted" — s'étend aussi au type-check/lint/build.

**How to apply:** Après une modification de code, ne pas exécuter de commande de vérification (test, type-check, lint, build) de sa propre initiative. Continuer le travail demandé ; le développeur lance les vérifications et partage le résultat si besoin.
