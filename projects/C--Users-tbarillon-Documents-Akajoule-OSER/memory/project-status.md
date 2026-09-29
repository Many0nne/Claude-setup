---
name: project-status
description: "État d'avancement du projet OSER : V1 archivée, V2 terminée le 2026-08-07, attentes côté ingénieur"
metadata: 
  node_type: memory
  type: project
  originSessionId: 212e3ea7-10c9-4142-ab37-f960f3c355d7
  modified: 2026-08-07T20:54:22.386Z
---

Projet **OSER, modèle hybride Thermique/Usage**. Terry (non expert) a repris le projet
après le départ de Racine Diatta.

**V1 clôturée et archivée** (tag git `v1-finale`, `outputs/v1/` non suivi — ne pas
supprimer ; les priors provisoires V2 viennent en fait des CSV d'exemple de l'ingénieur, D-24). Le plan Streamlit V1 a été abandonné et supprimé
de l'arbre en V2-0. Résultat principal V1 : sensibilité −2,85 %/°C (D-21), jamais présentée
comme baisse de consommation totale.

**V2 TERMINÉE le 2026-08-07 (sessions du cadrage à la session 10).** Livrables conformes au
format de l'ingénieur : `outputs/v2/params/{sei,pce}_parameters.csv` — 1065 seis, 1899 lignes
PCE (fit joint gaz/chaleur prioritaire sur 690 seis, élec-only sur 375). Campagnes 0 échec,
11/11 contrôles OK (`python -m src.audit.v2_check`). R² test médian 0,80 en joint (0,57
élec seule), biais énergétique médian +0,48 %. Cadrage détaillé : [[v2-engineer-specs]].

**Optimisation clé (session 10)** : la passe 1 de la grille MAP est en forme fermée exacte
(projection orthogonale, borne K ≥ 0 par clamp — équivalent prouvé à `lsq_linear`), ~50×
plus rapide ; campagne élec complète en ~6 min à n_jobs = 6. Ne pas revenir à la version
« gros blocs matriciels BLAS » : sursouscription des threads, effondrement sous charge.

**En attente côté ingénieur** (fin de session 10, voir plan §10) :
- son fichier de **priors définitif** (valeur centrale + écart-type) → remplacer
  `data/priors/priors_v2.csv` tel quel puis relancer les campagnes **avec `--restart`**
  (sinon la reprise saute tout : « Rien a faire ») (~20 min) ;
- confirmation activité **continue** (D-23) et définitions hp/hi ;
- 206 seis facturés hors du périmètre des 1065 éligibles (non traités) ;
- grilles tbal saturées en borne (537 seis à tbal_active = 24 °C) : élargir ?

**2026-09-24** : trame complète pour l'ingénieur `docs/v2/TRAME_V2_pipeline_detaille.md`
(pipeline + écarts). Audit docs/code : 15 seis sans lignes dans `pce_results.csv` →
`1000008-14/15` livrés sans ligne PCE ; correctif = Terry relance `train_all_v2 --restart`
puis `train_joint --export-final`. Contrôle Σw=1 de `v2_check` durci (échoue d'ici là) ;
signature du cache V2 modifiée (1re campagne suivante reconstruit le cache).

Repères : `CLAUDE.md` racine = carte du code + faits mesurés (à lire plutôt que réexplorer
`src/`) ; journaux `docs/v1/journal/` (D-01..D-22) et `docs/v2/journal/` (D-23..D-27) = source de vérité ;
campagnes lancées **par Terry uniquement** ([[no-heavy-background-runs]]) ; `pytest` jamais
lancé par l'assistant ; déterminisme D-22 (générateur joblib ordonné).

**2026-09-25 — séparation stricte V1/V2 (D-27, session 11)**, demandée par Terry qui
s'emmêlait entre les deux : docs dans `docs/v1/` (figé) / `docs/v2/`, sorties dans
`outputs/v1/` / `outputs/v2/`, code propre à la V1 retiré de l'arbre (tag `v1-finale`).
**How to apply:** toute nouvelle doc/sortie V2 va sous `docs/v2/` / `outputs/v2/` ; ne rien
réintroduire de V1 dans l'arbre ; citer la V1 comme archive. `.gitignore` corrigé :
`src/data/` et `docs/v2/data/` n'étaient pas versionnés avant.
