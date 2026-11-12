---
name: animation-sans-reference-interdit
description: "Jamais d'animation d'arme sans vidéo de référence : à défaut de l'arme exacte, prendre l'arme CS:GO la plus proche ; une planche dessinée par Claude n'est pas une référence."
metadata:
  type: feedback
---

Sans vidéo de référence, une animation de viewmodel produite par Claude est une suite de poses interpolées : pas
d'anticipation, pas de déplacement en profondeur, pas de sortie de cadre, frappes trop lentes et retours trop longs.
Le Ka-Bar v3 (2026-11-11) a été fait « d'une planche validée, sans vidéo » et le résultat était mauvais alors que la
même méthode avec référence (M9, AWP) donnait un bon résultat.

**Why:** l'utilisateur ne sait pas décrire un mouvement avec des mots et ne peut pas juger un mouvement sur des images
fixes. Sans référence, il ne peut rien corriger utilement et Claude n'a aucun modèle du geste.

**How to apply:** avant la première clé, exiger une vidéo. Pas de vidéo de l'arme exacte : prendre l'arme CS:GO de la même
famille dans les références déjà fournies (vidéo « toutes les animations de couteaux » : couteau CT 6:20-6:44, couteau
T 6:44-7:14). Mesurer la trajectoire (`tools/anim/grid.py`, `track_blade.py`) comme pour la M9, et ne faire valider
qu'une vidéo côte à côte référence/rendu, jamais un rendu seul. Voir [[animation-reference-workflow]].
