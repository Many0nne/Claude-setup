---
name: issues-github-project
description: "Toute issue NOP se cree via scripts/nop-issue.ps1 : ajout au projet n°4 et tous les champs remplis (status, labels, type, priorite, iteration, milestone, complexite) ; pas d'assignee depuis le 10/11/2026 (un agent s'en charge)"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 81483591-87ba-4b9b-a5a3-45108a5a57d4
  modified: 2026-11-10T09:53:08.781Z
---

Créer les issues NOP (back, front, racine) avec `.\scripts\nop-issue.ps1` (voir section « Issues » du CLAUDE.md racine), jamais `gh issue create` seul.

**Why:** 30/10/2026 l'utilisateur a dû lier lui-même 5 issues au projet ; 03/11/2026 il a redit que je ne remplissais pas les champs régulièrement (Assignees, Status, Labels, Type, Priorité si utile, Itération, Milestone, Complexité). Une simple note ne suffisait pas, d'où le script.

**How to apply:** choisir Type, labels `D:`/`T:` et Complexité (suite de Fibonacci, confirmé le 03/11/2026) d'après le contenu de l'issue ; Priority seulement si elle a du sens ; Size volontairement ignoré. Pas d'assignee (10/11/2026 : l'assignation revient à un agent), `-Assignee` seulement sur demande explicite. `-DryRun` en cas de doute. Si le script manque (autre branche), remplir les mêmes champs à la main.

Astuces projet (Akajoule #4, https://github.com/orgs/Akajoule/projects/4) : vues 13 « Backlog priorisé », 14 « Par domaine », 15 « À classer ». L'API crée vue + filtre + champs visibles (`createProjectV2View` / `updateProjectV2View`), mais pas group/slice/sort : à régler dans l'UI. Les requêtes GraphQL passent mieux via Bash (guillemets cassés en PowerShell).
