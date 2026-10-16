---
name: pr-maintenance
description: |
  Prepare la maintenance des PR de l'utilisateur dans des git worktrees, sans jamais pousser : rebase si conflit, correction des retours de review et des issues SonarCloud, correction de CI.
  Use when user invokes "/pr-maintenance back|front [PR_NUMBER...]" or asks to rebase his PRs / fix failing CI / address review or Sonar feedback on his PRs.
  Requires `gh` CLI authenticated. Lancé depuis la racine NOP/, cible le sous-projet indiqué.
---

# PR Maintenance Skill

Orchestrateur : pour chaque PR, detecter son etat, creer le worktree, appliquer la ou les procedures concernees, valider, puis s'arreter avant le push et rendre un recap. Le detail de chaque procedure est dans un fichier a part, a lire **seulement** si l'etat correspondant est detecte.

| Etat detecte | Procedure |
|---|---|
| Conflit avec la base | [rebase.md](rebase.md) |
| Retours non resolus (threads de review, review `CHANGES_REQUESTED`, issues/hotspots SonarCloud) | [feedback.md](feedback.md) |
| Check de CI en echec (hors SonarCloud) | [ci.md](ci.md) |

Ordre d'application quand une PR cumule plusieurs etats : rebase, puis retours, puis CI (les corrections de retours peuvent changer le resultat de la CI).

## Arguments

`/pr-maintenance back|front [PR_NUMBER...]`

- `back` = `Outil-NOP-backend/`, `front` = `Outil-NOP-frontend/` (chacun est un dépôt git distinct). Si le premier argument est absent ou ambigu, demander avec AskUserQuestion.
- Les numéros de PR sont optionnels : sans numéro, prendre toutes les PR ouvertes de l'utilisateur sur ce dépôt qui sont dans au moins un des etats du tableau.
- Toutes les commandes git/gh s'exécutent dans le dépôt cible : `git -C <repo>` et `gh` avec `--repo <owner>/<repo>` (owner/repo déduit de `git -C <repo> remote get-url origin`).

## Process

1. **Identifier les PR et leurs etats, puis démarrer directement** (pas de validation de la liste).
   - `gh pr list --author @me --state open --json number,title,headRefName,baseRefName,mergeable,reviewDecision,statusCheckRollup`.
   - Conflit : `mergeable == CONFLICTING`.
   - Retours : `reviewDecision == CHANGES_REQUESTED`, ou au moins un thread non resolu (`gh api graphql` sur `pullRequest(number:) { reviewThreads(first: 100) { nodes { isResolved } } }`), ou check SonarCloud en echec.
   - CI : au moins un check en echec dont le nom ne contient pas `Sonar`.
   - Avec numéros : traiter ceux-là, même si tout est vert (le dire dans le récap).
2. **Créer un worktree par PR** (sauf s'il existe déjà pour la branche, vérifier avec `git -C <repo> worktree list` : le réutiliser sans relancer le script, cas d'une session lancée par `/delegate`) avec le script du projet, depuis la racine NOP/ : `.\scripts\nop-worktree.ps1 -BackBranch <headRefName> -NoUp` (ou `-FrontBranch <headRefName> -NoUp` pour le front). Le worktree est créé dans `worktrees/Outil-NOP-<backend|frontend>-<slug>` sur la branche de la PR elle-même (pas de branche `maint/`), avec `.env` copié et ports décalés. Ne pas créer de worktree à la main avec `git worktree add`. Si la branche est déjà checkout dans le checkout principal, le script échoue : le dire à l'utilisateur au lieu de contourner. Ne jamais toucher au working tree ni à la branche du checkout principal.
3. **Appliquer les procedures** des etats detectes, dans l'ordre ci-dessus, en lisant le fichier correspondant.
4. **Validation locale légère** (lint, type-check, build) si possible dans le worktree. Les tests complets sont validés par la CI : ne pas démarrer la stack Docker (pas de `-Up`), sauf si une procedure le demande explicitement.
5. **Commit local** des corrections (pas de `--no-verify`), 1re ligne prefixee `claude: `, trailer `Co-Authored-By` du modele utilise.

## Règles communes

- Toute decision douteuse (regle metier, design, perimetre, test faux ou code faux) : s'arrêter et la remonter avec une recommandation, ne pas deviner.
- Après 3 tentatives sans progrès sur un même point, s'arrêter et produire un récap structuré (problème, essais, hypothèses).

## Sous-agents

L'invocation du skill vaut autorisation de lancer des sous-agents. Avec plusieurs PR, traiter chaque PR dans un sous-agent en parallèle (un worktree chacun), en lui indiquant les etats detectes et les fichiers de procedure a lire. Un sous-agent qui rencontre un point douteux remonte la question dans son compte rendu au lieu de deviner.

## Limites

- Ne jamais pousser, ne jamais repondre aux commentaires ni resoudre les threads sur GitHub : l'utilisateur le fait (le push direct est interdit par les regles du depot). `git-safe` bloque de toute façon le force push.
- Le script copie le `.env` du checkout principal : ne pas le lire (hook `block-env`) ni le recopier vers le checkout principal. Un worktree ne contient ni `node_modules` ni `venv` ; ne pas les copier sans demande.
- Suppression : `.\scripts\nop-worktree.ps1 -BackBranch <branche> -Remove` (jamais `git worktree remove` à la main), après avoir quitté le dossier du worktree (répertoire de travail, terminaux).
- Ne jamais supprimer un worktree contenant des commits non poussés sans demander.

## Récap final

Pour chaque PR : numéro et titre, etats detectes, chemin du worktree et branche de la PR, puis la section de recap propre a chaque procedure appliquee (voir le fichier de procedure), les points douteux restants, et la commande de push suggérée depuis le worktree (`git push --force-with-lease origin <headRefName>` après un rebase, `git push origin <headRefName>` sinon).
