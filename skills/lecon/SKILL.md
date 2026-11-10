---
name: lecon
description: Transforme une erreur repetee (d'un agent, d'une revue, de la CI) en garde-fou durable, au niveau le plus fort possible - test, regle de lint, etape de CI, hook, sinon regle ecrite dans le bon CLAUDE.md ou procedure dans un skill. Use when user invokes "/lecon [description de l'erreur]", or says something like "encore cette erreur", "retiens que...", "a chaque fois tu...", "il faut que ca ne se reproduise plus", or when a delegate compte rendu lists a candidate for /lecon.
---

# Lecon

Objectif : une erreur vue deux fois ne doit pas revenir une troisieme. La lecon devient un garde-fou qui bloque l'erreur
(prefere) ou, a defaut, une regle ecrite courte, placee la ou l'agent la lira au bon moment.

## 1. Comprendre l'erreur

A partir de la demande et de la conversation (ou du compte rendu de delegation cite) :
- l'erreur concrete (fichier, PR ou extrait), le comportement attendu, et pourquoi c'est un probleme ;
- si elle est generale (s'appliquerait a d'autres taches) ou propre a un cas ponctuel. Cas ponctuel : le dire et
  s'arreter, une regle pour un cas isole alourdit les CLAUDE.md pour rien.

Si l'erreur ou le comportement attendu restent flous, poser la question avant d'ecrire quoi que ce soit.

## 2. Choisir le niveau de garde-fou

Du plus fort au plus faible, retenir le premier qui convient :
1. **Blocage automatique** si l'erreur se detecte mecaniquement : test (unitaire ou de non-regression), regle de lint
   (ruff, eslint), etape de CI, hook pre-commit / husky, ou hook Claude Code (`settings.json` du depot ou de
   `~/.claude`, hooks existants dans `~/.claude/hooks/` et `git-safe/`). Une erreur bloquee n'a pas besoin de regle ecrite.
2. **Regle ecrite** sinon, dans le fichier le plus proche du code concerne :
   `CLAUDE.md` de sous-dossier (ex. `app/tests/CLAUDE.md`, `src/utils/CLAUDE.md`) > `CLAUDE.md` du depot >
   `CLAUDE.md` racine du projet (outillage, worktrees) > `~/.claude/CLAUDE.md` (vaut pour tous les projets).
3. **Skill** si la lecon est une procedure en plusieurs etapes : modifier le skill qui fait deja ce travail
   (`/delegate`, `/triage`...) plutot qu'en creer un.

Pour un garde-fou automatique, verifier qu'il echoue bien sur l'erreur d'origine et passe sur le code actuel
(sinon il casse la CI de toute l'equipe).

## 3. Ecrire

- Lire d'abord le fichier cible en entier : si une regle proche existe, la preciser ou la corriger plutot que d'en
  ajouter une ; si une regle contredit la lecon, la signaler et demander laquelle garder.
- Regle ecrite : une a deux lignes, a l'imperatif, avec la raison (« ... : sinon ... »). Pas d'historique du probleme,
  pas de date dans le texte : l'origine va dans le message de commit ou la PR.
- Respecter le style du fichier (titres, accents ou non, puces).

## 4. Livrer

- Depot d'equipe (back, front, racine NOP) : la regle touche toute l'equipe, donc elle passe par une branche et une PR,
  jamais directement sur le checkout principal. Creer le worktree selon le `CLAUDE.md` du projet (cas NOP :
  `git -C <depot> worktree add <racine>/worktrees/<depot>-lecon-<slug> -b chore/lecon-<slug> origin/dev`, sans stack
  Docker sauf si un test doit tourner), puis suivre les regles de commit du `CLAUDE.md` du depot (si le commit est
  bloque, preparer le message et la description de PR pour l'utilisateur).
- `~/.claude` (regle globale, hook, skill personnel) : commit et push directs sur `main` si l'utilisateur l'a autorise
  (voir la memoire), sinon proposer le commit. Si le skill a une copie partagee dans `skills/` du depot racine NOP,
  la mettre a jour dans la meme PR que les autres changements, ou dans une PR dediee.
- Annoncer en trois lignes : l'erreur, le garde-fou choisi (niveau et fichier), et comment il a ete verifie.
