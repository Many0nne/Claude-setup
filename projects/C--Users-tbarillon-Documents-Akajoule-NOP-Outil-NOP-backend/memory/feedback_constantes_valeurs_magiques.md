---
name: feedback-constantes-valeurs-magiques
description: Extraire une valeur fixe répétée plusieurs fois dans un fichier en constante de module nommée
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f9df7be6-794f-4372-a0a7-218c0f04abd4
---

Quand une valeur littérale (nombre, chaîne) est codée en dur à plusieurs endroits du même fichier, l'extraire en constante de module en haut du fichier plutôt que de la laisser dupliquée ou de la réintroduire comme variable locale à chaque bloc.

**Why:** Sur `app/management/commands/import_communes.py`, le nombre `20` (limite d'affichage) était répété 4 fois dans `handle()`. Le fichier avait déjà `BATCH_SIZE = 1000` comme constante de module pour la même raison (valeur fixe utilisée à plusieurs endroits) — `LIMIT_AFFICHAGE = 20` suit ce même pattern déjà établi dans le fichier.

**How to apply:** Repérer ce pattern (constante de module existante + nouvelle valeur magique répétée) avant d'écrire du code, pas seulement en revue. Confirmé par l'utilisateur comme le bon réflexe à généraliser aux prochaines sessions, pas seulement à ce fix ponctuel.
