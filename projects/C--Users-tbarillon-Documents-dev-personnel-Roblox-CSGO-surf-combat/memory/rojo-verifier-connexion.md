---
name: rojo-verifier-connexion
description: "Avant de demander de déconnecter Studio de Rojo, vérifier soi-même s'il est connecté (connexions TCP au port)"
metadata:
  node_type: memory
  type: feedback
  originSessionId: d4ff779b-eec1-4b43-a846-625d05a43ec7
  modified: 2026-11-05T21:19:38.090Z
---

Ne pas demander à l'utilisateur de faire Disconnect dans le plugin Rojo sans avoir vérifié qu'il est connecté :
`Get-NetTCPConnection -LocalPort <port> -State Established` (PowerShell). Aucune ligne = Studio pas connecté à ce
serveur, on peut réécrire le `.rbxm` directement.

**Why:** l'utilisateur s'est agacé qu'on lui demande de se déconnecter alors que c'était déjà fait (05/11/2026).

**How to apply:** avant toute réécriture d'un `.rbxm` (règle « jamais pendant que Studio est connecté » du CLAUDE.md
du projet), lancer ce contrôle sur le port du worktree ; ne demander que s'il y a une connexion établie.
