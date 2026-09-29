---
name: v2-engineer-specs
description: "Spécifications V2 (modèle PCE/bâtiment bayésien) recueillies auprès de l'ingénieur en août 2026"
metadata: 
  node_type: memory
  type: project
  originSessionId: 45f9f386-d292-4078-9d83-704834124806
  modified: 2026-08-07T13:12:48.749Z
---

Cadrage V2 issu de l'échange avec l'ingénieur (2026-08-06/07), relayé par Terry. La V1 reste figée ; la V2 est un modèle différent.

**Livrable** = deux tables de paramètres au format de `docs/data/{sei,pce}_parameters.csv` (format d'exemple, PAS des priors) : thermique par bâtiment (sei = ID_client_zone), usage + poids `w` par PCE. Les prédictions/projections ne servent qu'à la vérification.

**Spécifications confirmées** :
- Périmètre : les 1065 zones (périmètre Nantes instable, garder le maximum).
- Unités : énergies en **Wh**, températures en °C ; coefficients d'usage en Wh (régresseurs binaires).
- `tau`/`alpha` redondants : `alpha = 1 − exp(−1/tau)`.
- `b_activity` = surplus pendant les heures actives, au-dessus du talon `intercept`.
- Termes croisés (`b_peak_hour_vacation`…) **additifs** aux effets simples.
- Frontière actif/réduit : **par bâtiment**, fournie par `activity_prediction_sei.parquet` (script de Vincent, à copier depuis le lecteur P: — inaccessible depuis Claude). Deux tbal : active / reduced.
- Solaire (`k_sol_*`) et refroidissement : **hors scope** du premier rendu (colonnes livrables vides).
- Modèle strictement **horaire** ; élec ajustée 1:1, gaz/chaleur ajustés sur les **sommes par intervalle de facturation** (factures mensuelles).
- Bayésien : priors à venir dans un fichier **valeur centrale + écart-type** par paramètre (seul bloquant restant). Rendu = valeur ponctuelle (type MAP) ; incertitudes estimées = bonus apprécié.

**Données** : `energy_consumption_by_zone.parquet` contient déjà la colonne `PCE` (l'agrégation par zone était un choix V1, D-01). `sectorisation_des_pdl_par_bat.xlsx` = rattachement PDL→SEI avec colonne « Répartition zone » (un compteur peut être partagé entre zones, en %) — à relier au poids `w`.

Le plan complet est rédigé dans `docs/PLAN_V2_modele_pce_bayesien.md` (2026-08-07) : formulation, MAP, priors provisoires dérivés de V1, nettoyage du surplus (validation Terry requise avant suppression), phasage V2-0→V2-6. `activity_prediction_sei.parquet` copié dans `data/raw/` : activité **continue** [0,1] (pas binaire), 1684 seis, 2022-2025, les 1065 zones couvertes.

Voir [[external-review-critique]] pour la posture vis-à-vis des retours relayés, et [[project-status]] pour l'état V1.
