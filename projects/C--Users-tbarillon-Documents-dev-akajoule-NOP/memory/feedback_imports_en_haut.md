---
name: feedback-imports-en-haut
description: "Projet NOP - imports toujours en haut du fichier, jamais d'import local dans une fonction/méthode"
metadata:
  type: feedback
---

Les imports se placent toujours en haut du fichier, jamais dans le corps d'une fonction ou d'une méthode (pas d'import local "pour éviter un cycle").

**Why:** demande explicite de l'utilisateur sur Outil-NOP-backend (app/models/projet.py contenait des imports locaux justifiés par des cycles).

**How to apply:** dans le code NOP, ne jamais écrire d'import local. Si un cycle d'import semble l'imposer, le signaler et proposer une autre solution (référence par chaîne "app.Model", apps.get_model, déplacement de code) au lieu de faire un import local. Voir [[feedback-style-project-scoped]].
