---
name: feedback-propose-factorisation
description: "Proposer spontanément d'extraire un composant//une fonction quand du markup ou de la logique est dupliqué entre deux endroits"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: d019bfd9-b04f-464a-b4e7-0e41596bdf2c
  modified: 2026-08-06T13:03:43.766Z
---

Quand je m'apprête à dupliquer du markup ou de la logique entre deux fichiers (ou que je
constate une duplication existante), **proposer l'extraction en composant/fonction partagée**
plutôt que de recopier — sans attendre que le développeur le demande.

**Why:** la copie dérive silencieusement. Cas vécu : la légende de la carte réseau de chaleur
recopiée de `CarteReseau.vue` vers `CaptureCarteReseau.vue` avait déjà perdu une entrée
(« Séparation / jonction non raccordée »), donc le rapport PPTX affichait une légende
incomplète sans que rien ne le signale.

**How to apply:** avant de coller un bloc dupliqué, s'arrêter et proposer le composant partagé.
Si la duplication est déjà en place, la signaler et proposer de la résorber. Ne pas le faire
en silence : c'est une proposition, le développeur tranche. Voir aussi
[[feedback_no_silent_decisions]] et [[project_forms_convention]].
