---
name: da-composer-pas-empiler
description: "Scènes et DA - composer une image (plans, échelle, silhouette) à partir de références visuelles et d'une planche Blender validée, au lieu d'empiler des primitives Roblox"
metadata:
  node_type: memory
  type: feedback
  originSessionId: bf67c866-9229-40aa-8051-1c36dd808dcd
  modified: 2026-11-07T00:27:37.599Z
---

Pour une scène ou une direction artistique (menu #106), ne pas traduire un concept en mots en pièces Roblox primitives construites à la volée (`execute_luau`) : ça donne des objets empilés, pas une composition. L'utilisateur a rejeté une douzaine de maquettes faites ainsi (anneaux, étiquettes, particules, néons, objets flottants dispersés).

**Why:** il juge sur la qualité de l'image ; « original » ne veut pas dire ajouter des effets, mais une forme de décor et un cadrage forts (premier plan / fond, rapports d'échelle, silhouette lisible en miniature, matériaux crédibles).

**How to apply:** demander des références visuelles dès le début (cf. [[demander-reference-tot]]) ; produire d'abord une planche de 3-4 rendus Blender au cadrage final, reproductibles dans Roblox ; faire valider ; puis blockout Blender, MeshParts, intégration Roblox en comparant aux rendus. Valider à chaque étape. Complète [[ui-prototyper-dans-le-moteur]] : le moteur sert à vérifier la faisabilité, pas à chercher la composition.
