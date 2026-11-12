---
name: dizzy-map-retour-v1
description: "Retour de l'utilisateur sur la première tentative de la map Dizzy (seconde map) : trop petite, pleine de trous, abandonnée"
metadata:
  node_type: memory
  type: project
  originSessionId: 3d296f4f-b71d-4fe5-8d01-c1004e6607b2
  modified: 2026-11-04T23:56:58.577Z
---

Seconde map demandée : recréer `ar_dizzy` (CS:GO, port CS2 `ar_dizzy.vpk` de ModDB, gardé dans `worktrees/.archive`, outil d'extraction et .glb dans `worktrees/.tools`). Première tentative (relevé de la collision par rayons verticaux, reconstruction en boîtes et coins) rejetée et supprimée (stash `dizzy-v1-abandonnee-2026-11-05` dans le worktree `feature/dizzy-map`).

Retours de l'utilisateur à respecter pour la suite :
1. **Trop petite** : il faut au moins 1,5 à 2 fois plus grande que la version à ~310 × 330 studs (5 studs/m en plan, 3,5 en hauteur). Viser ~470 à 620 studs de côté.
2. **Des trous à plein d'endroits** (l'utilisateur n'en connaît pas la cause) : la map doit être pleine, sans trou ni mur manquant. Une hypothèse non vérifiée : les rayons verticaux ne voient pas les murs et la collision d'origine est faite de surfaces fines.

**Why:** la map doit être fidèle à l'originale et jouable ; une map trop petite complique aussi peu le déplacement (décision antérieure : jouable sans savoir surfer, mouvement et gravité du jeu inchangés, thème chantier, chute = mort).

**How to apply:** avant de reconstruire Dizzy, partir sur l'échelle agrandie, et vérifier l'absence de trous (relever les hauteurs par raycast dans Studio ou vérifier le maillage dans Blender) avant de présenter le résultat. Voir [[animation-reference-workflow]] pour l'esprit : valider avec l'utilisateur avant de produire en masse.
