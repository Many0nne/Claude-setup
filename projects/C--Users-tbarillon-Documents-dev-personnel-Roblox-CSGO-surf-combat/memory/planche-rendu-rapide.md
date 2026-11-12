---
name: planche-rendu-rapide
description: "Planches Blender (map, DA) - privilégier un rendu de quelques secondes (Workbench), pas EEVEE qui prend 30+ min sur ce poste"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 194c3a05-4cb8-482b-90ed-9662790388e6
  modified: 2026-11-10T22:14:08.677Z
---

Une planche Blender de 7 vues de Dizzy en EEVEE a pris plus de 30 minutes (carte graphique Intel intégrée) ; l'utilisateur
l'a jugé trop long et demande de simplifier dès que possible pour les itérations suivantes. En Workbench (couleurs des
pièces, ombres orientées comme le soleil du jeu), la même planche se rend en 7 s et reste lisible pour valider une
composition.

**Why:** les planches se refont à chaque itération ; un rendu long bloque la boucle de validation.

**How to apply:** planche en Workbench par défaut (`tools/map/render_dizzy.py`), EEVEE seulement pour une image finale
isolée ; toujours mesurer le temps d'un rendu avant d'en lancer une série. Complète [[da-composer-pas-empiler]].
