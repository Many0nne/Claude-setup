---
name: feedback-push-force-with-lease
description: "Jamais `git push --force`, toujours `--force-with-lease` ; c'est l'utilisateur qui pousse"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 3e219bb6-7fce-4688-9687-d1be9d9bf371
  modified: 2026-10-12T09:50:33.008Z
---

Ne jamais proposer ni utiliser `git push --force` : toujours `git push --force-with-lease` apres un rebase. Par defaut, c'est l'utilisateur qui pousse (rebase fait en local dans le worktree, il pousse lui-meme).

**Why:** `--force` peut ecraser des commits pousses entre-temps par un collegue ; l'utilisateur prefere garder la main sur les push.

**How to apply:** apres un rebase de branche distante (ex. via le skill delegate), laisser le resultat en local et indiquer `git push --force-with-lease` comme commande a lancer par l'utilisateur.
