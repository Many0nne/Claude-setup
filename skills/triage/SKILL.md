---
name: triage
description: |
  Trie des issues d'un projet (par defaut celles assignees a l'utilisateur dans l'iteration courante) pour determiner celles qui peuvent etre implementees en parallele sans marcher sur les PR ouvertes ni entre elles. Produit un rapport (lots parallelisables, issues bloquees et par quoi) et une commande de delegation prete par issue, sans rien lancer.
  Use when user invokes "/triage [depot...] [filtre]" or asks which issues can be started now / in parallel without conflicting with open PRs or with each other.
  Requires `gh` CLI authenticated. Lance depuis la racine du projet (mono-depot ou racine regroupant plusieurs depots).
---

# Triage

Objectif : parmi un ensemble d'issues, trouver celles qu'on peut demarrer tout de suite, et les grouper en lots qui ne se chevauchent pas. Lecture seule : ne rien modifier sur GitHub ni dans le code, ne creer aucun worktree.

Avant de commencer, lire le `CLAUDE.md` du projet (et ceux des depots) : il donne les depots, la branche d'integration, la notion d'iteration, les fichiers transverses, la documentation de reference, les outils exclusifs et le skill de delegation. Ce qu'il precise l'emporte sur les valeurs par defaut ci-dessous.

## Arguments

`/triage [depot...] [filtre]`

- Depots : sans argument, tous les depots du projet. Projet mono-depot : le depot du repertoire courant. Racine qui regroupe plusieurs depots (sous-dossiers avec leur propre `.git`, listes dans le `CLAUDE.md`) : tous, analyses ensemble, car une issue d'un depot depend souvent d'une PR d'un autre (ex. front et back). Un nom de depot (ou son alias du `CLAUDE.md`, ex. `back` / `front`) restreint les issues a ce depot, mais les PR ouvertes des autres restent lues pour detecter les dependances croisees.
- Filtre : sans filtre, issues ouvertes assignees a l'utilisateur dans l'iteration courante. Accepte aussi `tout` (toutes les issues ouvertes de l'iteration, quel que soit l'assignee), `milestone:<titre>`, `label:<label>`, ou une liste `#12 #15 #20`.
- `owner/repo` deduit de `git -C <depot> remote get-url origin` ; toutes les commandes `gh` avec `--repo`.

## 1. Iteration courante

Par defaut, l'iteration = un milestone (ne pas dependre des GitHub Projects : le token n'a pas forcement le scope `read:project`). Si le `CLAUDE.md` du projet definit l'iteration autrement, suivre sa definition.

- `gh api repos/<owner>/<repo>/milestones?state=open` sur chaque depot.
- Iteration = le milestone ouvert dont l'echeance (`due_on`) est la plus proche a partir d'aujourd'hui, **plus** les milestones ouverts deja echus (leurs issues sont marquees « en retard »). Les milestones sans echeance sont exclus.
- Plusieurs depots : raisonner sur le titre du milestone, souvent identique d'un depot a l'autre.
- Aucun milestone date : prendre toutes les issues ouvertes du filtre et le signaler.
- Annoncer en une ligne les milestones retenus (ou l'absence d'iteration).

## 2. Collecte

- Issues : `gh issue list --state open [--assignee @me] [--milestone "<titre>"] [--label "<label>"] --json number,title,body,labels,milestone,url --limit 100` selon le filtre, par depot ; liste explicite : `gh issue view <n> --json ...`.
- PR ouvertes de **tout le monde** : `gh pr list --state open --json number,title,author,headRefName,isDraft,body,closingIssuesReferences,files --limit 100`, sur tous les depots du projet (y compris ceux non cibles).
- Fichiers d'une PR : champ `files` ; s'il est tronque (PR > 100 fichiers), `gh pr diff <n> --name-only`.

## 3. Issues deja en cours

Une issue est « en cours » (exclue des lots) si une PR ouverte la reference :
- `closingIssuesReferences` la contient ;
- ou `#<n>` / l'URL de l'issue apparait dans le titre, le corps ou le nom de branche de la PR (beaucoup de PR ne lient pas l'issue formellement, ex. titre « ... (#407) »). Attention au depot : un `#n` sans prefixe designe le depot de la PR.

Les lister a part avec la PR qui les porte.

## 4. Empreinte de chaque issue restante

Pour chaque issue, estimer les fichiers/modules qu'elle touchera :
1. Lire le titre et le corps (criteres d'acceptation, fichiers ou composants cites, issues liees « suite #n », « depend de #n », « bloque par #n »).
2. Chercher dans le code du depot (checkout principal, branche d'integration, lecture seule) les fichiers concernes : noms de modeles, vues, composants, stores, routes, scripts, cles i18n cites ou deduits.
3. Noter : depot(s) concerne(s), fichiers probables, fichiers transverses (voir ci-dessous) et le niveau de confiance (haute si l'issue cite des fichiers, basse si deduit).
4. Signaler si l'issue a besoin d'un changement dans un autre depot (contrat d'API, format partage) ou d'une validation externe avant de livrer (label ou regle du `CLAUDE.md` du projet, ex. calcul a faire valider).
5. Documentation de reference (si le `CLAUDE.md` en cite une, ex. spec metier) : noter les documents qui decrivent ce que l'issue touche, et si l'issue change une regle qu'ils decrivent (le document sera alors modifie dans la tache).
6. Outil exclusif (projets dont le `CLAUDE.md` decrit un outil a interface partage entre worktrees, ex. un editeur de jeu, une session Blender) : classer le besoin de l'issue en `aucun` (code, tests, build), `sans interface` (script en mode batch, parallelisable), `verrou` (verification dans l'outil via le verrou partage), `interactif` (travail manuel dans l'outil) ou `avis` (rendu, gameplay ou UI a juger par l'utilisateur), avec les noms du `CLAUDE.md` du projet s'il en donne. Projet sans outil de ce type : sauter cette etape.

Fichiers transverses, a defaut de liste dans le `CLAUDE.md` : migrations de schema (meme app ou meme dossier de migrations), configuration globale (`settings`, `.env.example`, config du framework), routage central, store global, composants partages, manifestes et lockfiles de dependances (`package.json`, `requirements*`, `pyproject.toml`, `*.lock`, `rokit.toml`...), CI (`.github/workflows`).

L'invocation du skill vaut autorisation de lancer des sous-agents : au-dela de ~5 issues, repartir l'etape 4 sur des sous-agents `Explore` en parallele (un lot d'issues chacun, depot indique), qui rendent pour chaque issue la liste de fichiers, les fichiers transverses, les dependances et la confiance. Ne pas leur demander de modifier quoi que ce soit.

## 5. Conflits

Deux elements (issue/PR ou issue/issue) sont en conflit si :
- ils modifient un meme fichier ;
- ou ils ajoutent tous deux une migration dans le meme ensemble de migrations (numerotation concurrente) ;
- ou ils touchent un meme fichier transverse a fort risque (lockfile, manifeste de dependances, configuration globale, workflow CI) ;
- ou l'un depend explicitement de l'autre (« suite de », « bloque par », contrat d'API cree par une PR non mergee) ;
- ou ils modifient tous deux un meme document de reference (regle changee de part et d'autre). Le simple fait de lire le meme document n'est pas un conflit.

Meme module mais fichiers differents = « chevauchement leger » : autorise, a signaler.

Classement :
- **Bloquee** : en conflit avec une PR ouverte (indiquer laquelle, son auteur, le fichier ou la raison, et si c'est un brouillon). Elle redevient disponible au merge de cette PR.
- **Disponible** : aucun conflit avec les PR ouvertes.

Puis construire les lots parmi les disponibles : graphe de conflits issue/issue, et grouper glouton en commencant par les issues en retard, puis par priorite (label ou champ du projet s'il y en a), puis par echeance, de sorte qu'aucune paire d'un meme lot ne soit en conflit. Lot 1 = ce qu'on peut lancer tout de suite en parallele ; lots suivants = a lancer apres le merge du lot precedent.

Outil exclusif (etape 4.6) : dans un meme sous-lot, au plus une issue `interactif` ; `verrou` et `avis` sont acceptes (les taches se relaient sur le verrou) mais au plus 2 par sous-lot, completes par des issues `aucun` / `sans interface`. Le signaler dans les remarques.

Capacite du poste : si chaque issue lancee demarre sa propre stack (Docker ou serveurs de dev, voir la section worktrees du `CLAUDE.md` du projet) et que le lot 1 depasse la limite de stacks demarrees en meme temps (rubrique « Capacite du poste » du `~/.claude/CLAUDE.md`, 5 a defaut), le decouper en sous-lots 1a, 1b... de cette taille, par ordre de priorite : un sous-lot demarre quand des stacks du precedent se liberent (PR ouverte et thread ferme), sans attendre de merge. Projet sans stack par worktree : pas de decoupage.

## 6. Rapport

En chat, dans cet ordre :

1. **Iteration** : milestones retenus (ou filtre applique), nombre d'issues par depot.
2. **Lot 1 (parallelisable maintenant)**, par sous-lot s'il a fallu le decouper : tableau `issue | depot | titre | fichiers principaux | outil | confiance | remarques` (colonne `depot` seulement si plusieurs depots, colonne `outil` seulement si l'etape 4.6 s'applique ; remarques : en retard, validation externe, multi-depots, document de reference modifie).
3. **Lots suivants** : meme tableau, avec pour chaque issue l'issue du lot precedent avec laquelle elle entre en conflit.
4. **Bloquees par une PR ouverte** : `issue | PR bloquante (auteur, brouillon ?) | raison`.
5. **Deja en cours** : `issue | PR`.
6. **Incertitudes** : issues trop vagues pour estimer l'empreinte (confiance basse), dependances supposees a confirmer.
7. **Commandes de delegation** pour le lot 1 uniquement, une par issue, groupees par sous-lot, pretes a copier. Skill : celui du projet s'il en a un (skill de projet dans `.claude/skills/` ou cite par le `CLAUDE.md`, ex. `/delegate-nop`), sinon `/delegate`.
   `/<skill> <fix|feature>/<num>-<slug-court> Implementer <owner>/<repo>#<num> : <titre>`
   (`fix/` pour un bug, `feature/` sinon, ou la convention de branches du `CLAUDE.md` ; issue multi-depots : une seule commande qui le precise). Ne pas les lancer.

## Limites

- Lecture seule : pas de commentaire, label, assignation ni changement de milestone sur GitHub ; pas de worktree ni de stack.
- Ne pas lire de `.env`.
- L'empreinte est une estimation : le dire, et ne jamais presenter un lot comme garanti sans conflit quand la confiance est basse.
