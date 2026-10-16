---
name: github-project-nop
description: "GitHub Project v2 \"Organisation Outil NOP\" (Akajoule #4) - iterations, statuts, priorite, taille des issues back+front"
metadata:
  node_type: memory
  type: reference
  originSessionId: 4f928344-dfaf-47e0-a8f8-e9284075d35f
  modified: 2026-10-15T17:23:20.243Z
---

Les issues des deux depots (Outil-NOP-backend, Outil-NOP-frontend) sont suivies dans le Project v2 **Akajoule #4 "Organisation Outil NOP"** (https://github.com/orgs/Akajoule/projects/4). Les iterations, statuts, priorites, tailles n'existent que la, pas dans les issues.

- Champs : `Iteration` (sprints de 21 jours, "Iteration N"), `Status` (To be defined by anyone / by Alban / To be planned by Janina / To be developed / Dev in progress / PR in progress / Done), `Priority` (P0-P2, source de verite de la priorite des issues depuis le 2026-10-15), `Complexité` (estimation en Fibonacci), `Size` (volontairement inutilise), `Start date`, `Target date`.
- Labels des issues (depuis le 2026-10-15, identiques back+front) : `domaine: ...` (zone fonctionnelle, plusieurs possibles, sert a reperer les taches qui se chevauchent), `technique: ...`, `impact: calculs` (validation metier). Type d'issue GitHub Feature/Bug/Task. Les labels `Fusion : priorite N` / `Fusion : non prioritaire` = ordre de fusion des PR uniquement. Reference : `NOP/reorganisation-labels-nop.md`.
- Token gh (compte TerryBarillon) a le scope `project` depuis le 2026-10-15 : l'utilisateur m'autorise a creer des issues et a les ajouter au Project (`gh project item-add 4 --owner Akajoule --url <issue>`).
- Items d'une iteration : `gh project item-list 4 --owner Akajoule --limit 500 --format json --jq '.items[] | select(.iteration.title=="Iteration N")'`
- Liste des iterations (en cours / passees) : GraphQL `organization(login:"Akajoule"){projectV2(number:4){field(name:"Iteration"){... on ProjectV2IterationField{configuration{iterations{title startDate duration} completedIterations{title startDate}}}}}}` (lancer via Bash, les guillemets cassent en PowerShell).
- Vues creees le 2026-10-16 : 13 « Backlog priorisé » (group by Priority), 14 « Par domaine » (slice by Labels), 15 « À classer » (`no:priority`). L'API cree vue + filtre + champs visibles (`createProjectV2View` / `updateProjectV2View`, sans jq : `-f ids[]=...`), mais pas group/slice/sort : a regler dans l'UI.
