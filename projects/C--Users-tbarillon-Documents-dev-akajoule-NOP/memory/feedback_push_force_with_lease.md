---
name: feedback-push-force-with-lease
description: Jamais git push --force ; apres un rebase, toujours --force-with-lease
metadata:
  type: feedback
---

Ne jamais proposer ni utiliser `git push --force` : toujours `git push --force-with-lease` apres un rebase.

**Why:** `--force` peut ecraser des commits pousses entre-temps par un collegue.

**How to apply:** tout push apres rebase (skill /delegate compris) passe par `--force-with-lease`. Un force-push reste une action a confirmer avec l'utilisateur (CLAUDE.md global).
