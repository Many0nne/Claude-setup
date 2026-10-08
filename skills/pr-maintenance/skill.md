---
name: pr-maintenance
description: |
  Prepare les rebases et les corrections de CI des PR de l'utilisateur, dans des git worktrees, sans jamais pousser.
  Use when user invokes "/pr-maintenance back|front [PR_NUMBER...]" or asks to rebase his PRs / fix failing CI on his PRs.
  Requires `gh` CLI authenticated. Lancé depuis la racine NOP/, cible le sous-projet indiqué.
---

# PR Maintenance Skill

Pour chaque PR de l'utilisateur en conflit ou avec une CI en échec : créer un worktree, rebaser et/ou corriger, valider, puis s'arrêter avant le push et rendre un récap.

## Arguments

`/pr-maintenance back|front [PR_NUMBER...]`

- `back` = `Outil-NOP-backend/`, `front` = `Outil-NOP-frontend/` (chacun est un dépôt git distinct). Si le premier argument est absent ou ambigu, demander avec AskUserQuestion.
- Les numéros de PR sont optionnels : sans numéro, prendre toutes les PR ouvertes de l'utilisateur sur ce dépôt qui sont en conflit ou dont la CI échoue.
- Toutes les commandes git/gh s'exécutent dans le dépôt cible : `git -C <repo>` et `gh` avec `--repo <owner>/<repo>` (owner/repo déduit de `git -C <repo> remote get-url origin`).

## Process

1. **Identifier les PR à traiter, puis démarrer directement** (pas de validation de la liste). Sans numéro : `gh pr list --author @me --state open --json number,title,headRefName,baseRefName,mergeable,statusCheckRollup`, ne garder que `mergeable == CONFLICTING` ou au moins un check en échec. Avec numéros : traiter ceux-là, même si tout est vert (le dire dans le récap).
2. **Créer un worktree par PR** : `git -C <repo> fetch origin`, puis `git -C <repo> worktree add ../.worktrees/<repo>-pr-<n> -b maint/pr-<n> origin/<headRefName>`. Ne jamais toucher au working tree ni à la branche de l'utilisateur.
3. **Rebase** (si conflit) : `git rebase origin/<baseRefName>` dans le worktree. Pour chaque conflit :
   - lire les deux côtés ET l'intention de chacun (`git log` / `git show` des commits concernés des deux branches) ;
   - résoudre, puis noter la décision et un niveau de confiance (sûr / probable / douteux) ;
   - si douteux : s'arrêter et demander à l'utilisateur, ne pas deviner. Cas typiques : règle métier divergente, migration Django (régénérer plutôt que fusionner), renommage d'un côté et usage de l'autre.
4. **Contrôle du rebase** : `git range-diff origin/<headRefName>...HEAD` pour vérifier qu'aucune modification n'a disparu.
5. **Correction de CI** (si échec) : `gh pr checks <n>`, puis `gh run view <run-id> --log-failed`. Distinguer test faux / code faux. Si l'échec peut venir des deux, le signaler à l'utilisateur au lieu de choisir. Ne jamais adapter un test uniquement pour le faire passer. Après 3 tentatives sans progrès, s'arrêter et produire un récap structuré (problème, essais, hypothèses).
6. **Validation locale légère** (lint, type-check, build) si possible dans le worktree. Les tests complets sont validés par la CI, ne pas démarrer la stack Docker dans un worktree.
7. **Commit local** des corrections (pas de `--no-verify`).

## Sous-agents

L'invocation du skill vaut autorisation de lancer des sous-agents. Avec plusieurs PR, traiter chaque PR dans un sous-agent en parallèle (un worktree chacun). Un sous-agent qui rencontre un point douteux remonte la question dans son compte rendu au lieu de deviner.

## Limites

- Ne jamais pousser. Le push (`--force-with-lease` après un rebase) est fait par l'utilisateur. `git-safe` bloque de toute façon le force push.
- Un worktree ne contient ni `node_modules`, ni `venv`, ni `.env`. Ne pas les copier sans demande.
- Ne jamais supprimer un worktree contenant des commits non poussés sans demander.

## Récap final

Pour chaque PR : numéro et titre, chemin du worktree et branche `maint/pr-<n>`, conflits résolus (fichier, décision, confiance), corrections de CI, points douteux restant, et la commande de push suggérée.
