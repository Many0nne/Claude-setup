---
name: project-forms-convention
description: "Outil-NOP-frontend : nouveau dossier src/forms/ pour extraire le state+orchestration des vues formulaire, distinct des composables réseau"
metadata: 
  node_type: memory
  type: project
  originSessionId: 238164f9-0e73-46ff-8506-2a9ad1822d69
---

Décision prise le 2026-07-17 pendant la planification d'un refacto de réduction de taille de fichiers (BuildingView.vue, ScenarioEditView.vue, EnrEditView.vue, NoteCreateForm.vue) : création d'un nouveau dossier `src/forms/` dans Outil-NOP-frontend.

Ce dossier contient le state réactif + l'orchestration (validation, clonage, handlers de save/load) qui étaient auparavant codés en dur dans les vues. Ces fichiers appellent les composables réseau existants (`useSituationReference`, `useMoyensProduction`...) mais ne sont pas eux-mêmes des composables réseau.

**Convention de nommage :** `createXxxForm()` / `createXxxSelection()` — jamais de préfixe `use*`, réservé aux composables réseau (cf. [[feedback_composables_network_only]]).

**Why:** 4 des 5 fichiers identifiés comme trop longs partagent la même forme (empty-object factory + clone + validate + save/load handlers) — pattern jugé assez récurrent pour justifier une convention dédiée plutôt qu'une extraction ad-hoc en utils/.

**How to apply:** Pour toute nouvelle vue formulaire volumineuse dans ce projet, envisager `src/forms/` en priorité pour le state+orchestration extrait, avant de considérer une extraction en `utils/` (réservé aux fonctions pures sans state réactif) ou en sous-composants Vue.
