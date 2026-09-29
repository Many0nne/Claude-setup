---
name: feedback-commenter-methodes
description: Toujours documenter les nouvelles méthodes avec 1-2 lignes de commentaire style pseudo-code
metadata:
  type: feedback
---

Lors de l'ajout d'une méthode, la documenter avec 1 à 2 lignes de commentaire (variable selon la taille et la complexité), rédigées dans un style pseudo-code : "Cette méthode permet de ... lorsque ... est visible."

**Why:** Le reviewer doit comprendre ce que fait la méthode sans avoir à la déchiffrer entièrement.

**How to apply:** Toujours ajouter un commentaire au-dessus de chaque nouvelle méthode. La longueur du commentaire est proportionnelle à la complexité : 1 ligne pour une méthode simple, 2 lignes pour une méthode plus complexe. Style : "Cette méthode permet de [action] lorsque [condition/contexte]."
