# Procedure : correction de CI (check en echec)

1. **Lire l'echec** : `gh pr checks <n>`, puis `gh run view <run-id> --log-failed`. Si un rebase vient d'etre fait, verifier d'abord que l'echec est toujours reproductible localement (lint, type-check, test cible) : il peut venir de la base.
2. **Diagnostiquer** : distinguer test faux / code faux. Si l'échec peut venir des deux, le signaler à l'utilisateur au lieu de choisir. Ne jamais adapter un test uniquement pour le faire passer.
3. **Corriger** puis relancer localement la commande qui echouait (lint, type-check ou test cible). Un test qui necessite la stack Docker (tests back) n'est relance que si la stack du worktree tourne deja ; sinon la CI valide apres le push.

## Recap

Check en echec, cause (test faux / code faux), correction, commande de verification locale et son resultat.
