---
name: modeles-skins-blender-pas-threejs
description: "Créer un modèle ou un skin d'arme : Blender directement, plus d'aperçus three.js ni de planche 2D (décidé le 2026-11-10)"
metadata:
  node_type: memory
  type: feedback
  originSessionId: d9b743fd-1c45-4793-9f7d-c748053941a3
  modified: 2026-11-10T21:27:28.696Z
---

Pour créer un modèle (couteau de base, nouvelle arme) ou un skin, l'utilisateur veut travailler dans Blender. Ne plus
proposer d'aperçus three.js ni de planche 2D comme étape de recherche de forme.

**Why:** essai du 2026-11-10 pour trouver un couteau de base (remplaçant de la M9) : modèles générés par code en three.js
(5 pistes, puis un Paracord reproduit d'une capture) jugés « pas dingues » à côté de la M9 : formes, détails et
textures trop pauvres. Le plafond tient à la finition (cordage tressé, usure peinte, biseaux, UV propres) que Blender
obtient par cuisson d'un modèle détaillé. Il a aussi trouvé les allers-retours coûteux, et a refusé le Creator Store.
Tout ce travail a été jeté (worktree et branche supprimés).

**How to apply:** modéliser par script `blender -b --factory-startup` (cf. `docs/maps.md`, `docs/animations.md`), avec
de vraies UV et des cartes PBR cuites depuis un modèle détaillé. La section « Aperçus three.js » de `docs/assets.md`
existe toujours mais n'est plus la méthode voulue pour un nouveau modèle ; proposer de la corriger si le sujet revient.
Demander tôt une référence propre de profil plutôt qu'une capture en vue subjective ([[demander-reference-tot]]) : la
perspective de la main déforme les proportions. Générer des modèles par IA (`generate_3d`, peut coûter un crédit) :
seulement avec son accord explicite.
