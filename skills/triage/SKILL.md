---
name: triage
description: |
  Trie les issues assignees a l'utilisateur dans l'iteration courante (milestone) du projet, pour determiner celles qui peuvent etre implementees en parallele sans marcher sur les PR ouvertes ni entre elles. Produit un rapport (lots parallelisables, issues bloquees et par quoi) et une commande /delegate prete par issue, sans rien lancer.
  Use when user invokes "/triage [back|front]" or asks which assigned issues can be started now / in parallel without conflicting with open PRs.
  Requires `gh` CLI authenticated. Lance depuis la racine NOP/ (ou un projet mono-depot).
---

# Triage

Objectif : parmi les issues qui me sont assignees dans l'iteration, trouver celles qu'on peut demarrer tout de suite, et les grouper en lots qui ne se chevauchent pas. Lecture seule : ne rien modifier sur GitHub ni dans le code, ne creer aucun worktree.

## Arguments

`/triage [back|front]`

- Sans argument : tous les depots du projet (cas NOP : `Outil-NOP-backend/` et `Outil-NOP-frontend/`, analyses ensemble car une issue front depend souvent d'une issue ou d'une PR back).
- `back` / `front` : un seul depot, mais les PR ouvertes de l'autre restent lues pour detecter les dependances croisees.
- Projet mono-depot : le depot du repertoire courant. `owner/repo` deduit de `git -C <depot> remote get-url origin` ; toutes les commandes `gh` avec `--repo`.

## 1. Iteration courante

L'iteration = un milestone (le token n'a pas forcement le scope `read:project`, ne pas dependre des GitHub Projects).

- `gh api repos/<owner>/<repo>/milestones?state=open` sur chaque depot.
- Iteration = le milestone ouvert dont l'echeance (`due_on`) est la plus proche a partir d'aujourd'hui, **plus** les milestones ouverts deja echus (leurs issues sont marquees « en retard »). Les milestones sans echeance (ex. `V 2027`) sont exclus.
- Les milestones portent le meme titre dans les deux depots : raisonner sur le titre.
- Annoncer en une ligne les milestones retenus.

## 2. Collecte

- Issues : `gh issue list --assignee @me --state open --milestone "<titre>" --json number,title,body,labels,milestone,url --limit 100` par milestone retenu et par depot.
- PR ouvertes de **tout le monde** : `gh pr list --state open --json number,title,author,headRefName,isDraft,body,closingIssuesReferences,files --limit 100`, sur tous les depots du projet (y compris celui non cible).
- Fichiers d'une PR : champ `files` ; s'il est tronque (PR > 100 fichiers), `gh pr diff <n> --name-only`.

## 3. Issues deja en cours

Une issue est « en cours » (exclue des lots) si une PR ouverte la reference :
- `closingIssuesReferences` la contient ;
- ou `#<n>` / l'URL de l'issue apparait dans le titre, le corps ou le nom de branche de la PR (beaucoup de PR ne lient pas l'issue formellement, ex. titre « ... (#407) »). Attention au depot : un `#n` sans prefixe designe le depot de la PR.

Les lister a part avec la PR qui les porte.

## 4. Empreinte de chaque issue restante

Pour chaque issue, estimer les fichiers/modules qu'elle touchera :
1. Lire le titre et le corps (criteres d'acceptation, fichiers ou composants cites, issues liees « suite #n », « depend de #n », « bloque par #n »).
2. Chercher dans le code du depot (checkout principal, branche `dev`, lecture seule) les fichiers concernes : noms de modeles, vues, serializers, composants, stores, routes, cles i18n cites ou deduits.
3. Noter : depot(s) concerne(s), fichiers probables, fichiers transverses (migrations du meme app Django, `settings`, `urls.py`, `package.json`, lockfiles, router, store global, composants partages, CI `.github/workflows`), et le niveau de confiance (haute si l'issue cite des fichiers, basse si deduit).
4. Signaler aussi si l'issue a besoin d'un changement de l'autre depot (contrat d'API) ou porte le label `... Calculs a valider` (validation metier requise avant de livrer).

L'invocation du skill vaut autorisation de lancer des sous-agents : au-dela de ~5 issues, repartir l'etape 4 sur des sous-agents `Explore` en parallele (un lot d'issues chacun, depot indique), qui rendent pour chaque issue la liste de fichiers, les fichiers transverses, les dependances et la confiance. Ne pas leur demander de modifier quoi que ce soit.

## 5. Conflits

Deux elements (issue/PR ou issue/issue) sont en conflit si :
- ils modifient un meme fichier ;
- ou ils ajoutent tous deux une migration dans la meme app Django (numerotation concurrente) ;
- ou ils touchent un meme fichier transverse a fort risque (lockfile, `package.json`, `requirements*`, `settings`, workflow CI) ;
- ou l'un depend explicitement de l'autre (« suite de », « bloque par », contrat d'API cree par une PR non mergee).

Meme module mais fichiers differents = « chevauchement leger » : autorise, a signaler.

Classement :
- **Bloquee** : en conflit avec une PR ouverte (indiquer laquelle, son auteur, le fichier ou la raison, et si c'est un brouillon). Elle redevient disponible au merge de cette PR.
- **Disponible** : aucun conflit avec les PR ouvertes.

Puis construire les lots parmi les disponibles : graphe de conflits issue/issue, et grouper glouton en commencant par les issues en retard puis par echeance, de sorte qu'aucune paire d'un meme lot ne soit en conflit. Lot 1 = ce qu'on peut lancer tout de suite en parallele ; lots suivants = a lancer apres le merge du lot precedent.

## 6. Rapport

En chat, dans cet ordre :

1. **Iteration** : milestones retenus, nombre d'issues par depot.
2. **Lot 1 (parallelisable maintenant)** : tableau `issue | depot | titre | fichiers principaux | confiance | remarques` (en retard, calcul a valider, back+front).
3. **Lots suivants** : meme tableau, avec pour chaque issue l'issue du lot precedent avec laquelle elle entre en conflit.
4. **Bloquees par une PR ouverte** : `issue | PR bloquante (auteur, brouillon ?) | raison`.
5. **Deja en cours** : `issue | PR`.
6. **Incertitudes** : issues trop vagues pour estimer l'empreinte (confiance basse), dependances supposees a confirmer.
7. **Commandes /delegate** pour le lot 1 uniquement, une par issue, pretes a copier :
   `/delegate <fix|feature>/<num>-<slug-court> Implementer <owner>/<repo>#<num> : <titre>`
   (`fix/` pour un bug, `feature/` sinon ; issue back+front : une seule commande qui le precise). Ne pas les lancer.

## Limites

- Lecture seule : pas de commentaire, label, assignation ni changement de milestone sur GitHub ; pas de worktree ni de stack.
- Ne pas lire de `.env`.
- L'empreinte est une estimation : le dire, et ne jamais presenter un lot comme garanti sans conflit quand la confiance est basse.
