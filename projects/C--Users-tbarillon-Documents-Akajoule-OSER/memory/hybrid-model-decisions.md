---
name: hybrid-model-decisions
description: "Décisions métier actées pour le modèle hybride Thermique/Usage (granularité, nettoyage, régresseurs, validation)"
metadata: 
  node_type: memory
  type: project
  originSessionId: a97a31d4-56e4-4aee-9106-616f0f96a34d
  modified: 2026-07-20T13:51:58.632Z
---

Refonte du modèle hybride Thermique/Usage (projet OSER, Nantes Métropole), plan dans `docs/PLAN_implementation_modele_hybride.md`. Décisions validées par le métier (2026-07-20) :

- **Granularité** : un modèle = un `ID_client_zone`. On agrège `Valeur` par `(ID_client_zone, Horodatage_Début)` en **somme** (les PCE d'une même zone sont sommés ; PCE gardé pour traçabilité seulement). Le poids `g`/répartition zone n'est PAS utilisé à ce niveau.
- **Départ** : vecteur `ÉLECTRICITÉ`, fréquence `Horaire`. Ensuite gaz journalier, puis chaleur/élec mensuel.
- **Nettoyage** (validé 2026-07-20 via `outputs/reports/data_quality.md` + `zone_diagnostics.md`) : élec négatifs → NaN (0 cas en élec horaire, les 28 étaient en élec mensuelle) ; **zéros conservés** (~3,3 %, plausibles : bâtiment fermé/nuit/vacances) ; gaz négatifs (426) inchangés, à réévaluer au modèle gaz. Règle codée dans `src/preprocessing/cleaning.py`.
- **Éligibilité des zones** : exclure zone si <12 mois de données OU <80 % de couverture temporelle. Sur élec horaire : **1234 zones → 1065 éligibles, 169 exclues** (6 <12 mois, 163 <80 %). Période données 2022-08-19 → 2024-12-31.
- **Régresseurs d'usage** (configurables dans `src/config/config.yaml`) : is_weekend, is_holiday_bridge, is_school_vacation, is_summer_break, is_hp, **is_hi** + intercept β0.
- **Grilles** (source `docs/idee_procedure_regression_modele.md`) : α ∈ [0.01, 0.5], T_balance ∈ [12, 22].
- **Contrainte** : coefficient thermique K (colonne HDD) borné ≥ 0 via `scipy.optimize.lsq_linear`.
- **Validation** : split temporel train/test (période finale en test), métriques MAE/RMSE/MAPE sur le test.
- **Env** : Python 3.14 dans `.venv` fonctionne (scipy 1.18, pandas 3.0, pyarrow 25). Le métier se moque de la version Python.

Modèle : `Conso = K·HDD + β0 + Σβᵢ·usageᵢ`, `Tf(t)=α·T+(1−α)·Tf(t−1)` (Tf(0)=T(0)), `HDD=max(0,T_balance−Tf)`. Estimation 2 temps : grid search (α,T_balance) puis lsq_linear.
