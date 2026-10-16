---
name: feedback-up-stack-avant-verif
description: "NOP - toujours creer ET demarrer la paire back+front (worktrees, containers, donnees) moi-meme avant de demander une verification ; l'utilisateur ne fait qu'ouvrir le lien"
metadata:
  node_type: memory
  type: feedback
  originSessionId: a0f1019d-231f-40e7-96ab-f979270ff43c
  modified: 2026-10-14T18:47:54.950Z
---

Avant de demander a l'utilisateur de verifier quoi que ce soit dans le navigateur, tout doit etre pret : worktrees back ET front de la branche, containers des deux cotes demarres (`docker compose up -d --build` dans chaque worktree, ou `nop-worktree.ps1 <branche> -Up`), migrations et donnees de test chargees. Le protocole ne contient qu'une URL directe et quoi observer, jamais de commande a lancer.

**Why:** il ne veut pas monter de containers lui-meme ; si je ne cree/demarre qu'un cote, je finis par lire ou tester le mauvais code (front `dev` du checkout principal au lieu de la branche).

**How to apply:** des le debut d'une tache sur une branche, lancer `nop-worktree.ps1 <branche>` (idempotent depuis 2026-10-14 : reutilise les worktrees existants, cree le cote manquant, demarre et verifie les deux stacks ; ne pas forcer `-BackBranch`/`-FrontBranch` sans raison), meme si un worktree existe deja. Avant le protocole de test : verifier que les deux URL repondent et donner un lien profond (projet/batiment precis). Lie a [[feedback-pas-claude-in-chrome]].
