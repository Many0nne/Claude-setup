---
name: delegate
description: Delegue une tache a une autre session Claude qui travaille dans son propre git worktree (et sa stack Docker isolee), lancee dans un nouvel onglet de terminal avec un brief valide par l'utilisateur. Use when user invokes "/delegate [branche] [tache]", or asks to delegate / hand off / parallelize a task to another Claude instance or worktree.
---

# Delegate

Objectif : une tache = une branche = un worktree = une session Claude interactive dans un nouvel onglet, partie d'un brief que l'utilisateur a valide. La session courante reste libre.

## 1. Cadrer la tache

A partir de la demande et de la conversation (ne pas explorer le code pour cela, sauf si la tache est inintelligible sans) :
- branche : celle donnee, sinon proposer `feature/<slug>` ou `fix/<slug>` ;
- objectif, criteres d'acceptation verifiables, perimetre (fichiers/modules concernes) et hors-perimetre explicite ;
- depots concernes si le projet en a plusieurs (cas NOP : back, front ou les deux).

Si un point manque pour ecrire des criteres d'acceptation verifiables, poser la question plutot que d'inventer.

## 2. Faire valider le brief

Rediger le brief avec le modele ci-dessous (sans la section Environnement, encore inconnue) et l'afficher a l'utilisateur. **Ne rien creer avant son accord explicite.** Integrer ses corrections et reafficher si elles sont substantielles.

## 3. Creer le worktree et la stack

- Projet equipe (`scripts/*worktree*.ps1` a la racine, voir la section "Worktrees" du `CLAUDE.md` du projet) : lancer le script avec la branche et `-Up`. Relever dans sa sortie le slot, les URL et les dossiers crees.
- Projet non equipe sans Docker : `git worktree add <racine>/worktrees/<slug> -b <branche> origin/<base>` (ou sans `-b` si la branche existe). Si `worktrees/` n'est pas ignore (`git check-ignore -q worktrees`), l'ajouter a `.git/info/exclude` (local, pas de modification suivie).
- Projet non equipe avec Docker compose : s'arreter et proposer `/setup-worktrees` d'abord.

Si le script echoue (ports en dur, branche a rebaser...), rapporter l'erreur telle quelle et ne pas lancer de session.

## 4. Ecrire le brief et lancer

- Ecrire le brief complet dans `<racine>/worktrees/.briefs/<slug>.md` (dossier ignore par git).
- Dossier de lancement :
  - racine multi-depots non versionnee (cas NOP) : la racine du projet, pour charger son `CLAUDE.md` et ses memoires ; le brief impose de ne travailler que dans le(s) worktree(s) ;
  - depot unique : le dossier du worktree (memoire et `CLAUDE.md` partages entre worktrees).
- Lancer : `pwsh -NoProfile -File "$env:USERPROFILE\.claude\skills\delegate\launch.ps1" -Dir <dossier> -Brief <chemin du brief> -Title <slug>`.
- Annoncer en 3 lignes : branche, URL de la stack, commande de nettoyage (`<script> <branche> -Remove`, a lancer par l'utilisateur apres relecture).

## Modele de brief

```markdown
# Brief : <titre court>

## Environnement
- Branche : `<branche>` (base `<base>`)
- Worktree(s) : `<chemin>` [, `<chemin>`]. Ne modifier aucun fichier en dehors.
- Stack : <URL back> / <URL front>. Lancer les commandes `docker compose` depuis le worktree concerne.
- Ne pas lire ni recopier les fichiers `.env`.

## Objectif
<2-3 phrases : quoi et pourquoi>

## Criteres d'acceptation
- [ ] <critere verifiable>

## Perimetre
- Concerne : <fichiers / modules>
- Hors perimetre : <ce qu'il ne faut pas toucher>. Toute modification hors perimetre est proposee dans le compte rendu, pas appliquee.

## Contexte utile
<decisions deja prises, pieges connus, liens vers spec/issue ; omettre si vide>

## Avant de rendre la main
1. Lancer les tests et le lint concernes **dans la stack Docker du worktree**, corriger jusqu'a ce qu'ils passent.
2. Invoquer le skill `code-review` (niveau medium) sur le diff de la branche ; corriger les points confirmes qui sont dans le perimetre, lister les autres.
3. Ne pas commiter, ne pas pousser : l'utilisateur relit le diff non commite.
4. Terminer par un compte rendu court : statut (FINI / BLOQUE), criteres d'acceptation coches, resultat des tests, points de review non traites, questions ouvertes.
```
