# Procedure : rebase (PR en conflit)

1. **Rebase** : `git rebase origin/<baseRefName>` dans le worktree. Si la branche contient des commits déjà squash-mergés dans la base (conflits sur des fichiers étrangers à la PR), ne pas résoudre : comparer `git log origin/<base>..origin/<headRefName>` aux commits de la PR et rejouer seulement les siens avec `git rebase --onto origin/<baseRefName> <dernier-commit-étranger>`.
2. **Pour chaque conflit** :
   - lire les deux côtés ET l'intention de chacun (`git log` / `git show` des commits concernés des deux branches) ;
   - résoudre, puis noter la décision et un niveau de confiance (sûr / probable / douteux) ;
   - si douteux : s'arrêter et demander à l'utilisateur, ne pas deviner. Cas typiques : règle métier divergente, migration Django (régénérer plutôt que fusionner), renommage d'un côté et usage de l'autre.
3. **Contrôle du rebase** : `git range-diff --no-ext-diff origin/<headRefName>...HEAD` (ou `<anciens commits propres à la PR>` vs `origin/<baseRefName>..HEAD` après un `--onto`) pour vérifier qu'aucune modification n'a disparu. Le `--no-ext-diff` est obligatoire : l'outil de diff externe configuré fait planter `range-diff` (`unsupported filetype`).

## Recap

Conflits résolus (fichier, décision, confiance), résultat du `range-diff`.
