---
name: feedback-git-confirm
description: "Toujours demander confirmation avant toute action git (commit, push, création de branche), même un commit local"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 5cb93ce9-f1d2-4259-ada7-1a4025015539
---

Ne jamais exécuter commit, push, ou création de branche sans confirmation explicite préalable — y compris pour un simple commit local.

**Why:** Cohérent avec la préférence générale de transparence du user ([[feedback_ask_before_search]], [[feedback_no_silent_decisions]]) : il veut savoir et valider chaque action git avant qu'elle parte, pas seulement les opérations destructives.

**How to apply:** Avant `git commit`, `git push`, `git branch`/`checkout -b`, ou toute autre action git qui modifie l'état du repo (même réversible), décrire l'action prévue et attendre la confirmation.
