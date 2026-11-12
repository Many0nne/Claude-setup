---
name: feedback-tester-moi-meme
description: "NOP - faire soi-meme les tests fonctionnels dans le navigateur (preview_* + captures) au lieu de les mettre en \"Bloque sur toi\""
metadata:
  node_type: memory
  type: feedback
  originSessionId: 2d0c86a6-184f-4b44-ad39-7eec2cfa2147
  modified: 2026-11-04T13:58:34.135Z
---

Les verifications fonctionnelles d'un ecran (champs presents, valeurs, enregistrement, recalcul) se font moi-meme avec
les outils `preview_*` (evaluate, et captures d'ecran via `preview_snapshot` quand c'est utile), puis je montre la
capture. Ne laisser a l'utilisateur que le jugement de gout (UX/UI) s'il en reste un, et le dire explicitement.
Quand je donne un acces de test : URL complete, identifiant complet (email) et mot de passe (comptes de fixtures du
README back), jamais un simple nom.

**Why:** l'utilisateur a demande (2026-11-04, #428) pourquoi le test etait « bloque sur lui » alors que je pouvais le
faire, et s'est plaint d'avoir recu un nom sans adresse ni mot de passe.

**How to apply:** avant d'ecrire « Bloque sur toi » pour un test, le faire moi-meme ; captures autorisees. Lie a
[[feedback-up-stack-avant-verif]] et [[reference-t3-preview-couts]].
