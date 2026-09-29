---
name: project-subventions-389
description: "Issue frontend #389 (subventions : catalogue en code, SubventionScenario, gel, modale) — spec dans specs/subventions-389.md, état au 2026-09-24"
metadata:
  node_type: memory
  type: project
  originSessionId: 4eff3279-3aa1-4ddf-a29c-e8b8bf4ab5b5
  modified: 2026-09-24T21:17:32.642Z
---

Issue #389 (Outil-NOP-frontend) implémentée back + front le 2026-09-24, non commitée, sur `dev` dans les deux dépôts. Tests backend passés (confirmé par l'utilisateur) ; tests/type-check/lint frontend pas encore lancés.

Spec de référence : `specs/subventions-389.md` (à la racine NOP, hors git).

**Why:** décisions prises avec l'utilisateur (figer l'existence et non le montant, gel à l'expiration par commande plutôt qu'écriture au GET, liste groupée par financeur, montant personnalisé prioritaire).

**How to apply:** repartir de la spec. Points encore ouverts à ce moment-là :
- où lancer `geler_subventions_expirees` au déploiement Clever Cloud (cron ou manuel) ;
- textes (descriptions, lien fondschaleur.ademe.fr, explications) à faire valider par le métier ;
- MCD non régénéré.
Les CEE et les aides régionales auront leurs propres issues ([[feedback-no-out-of-scope-changes]]).
