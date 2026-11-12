---
name: setup-worktrees
description: Equipe le projet courant pour faire tourner plusieurs branches en parallele (une branche = un git worktree = une stack isolee : Docker compose, CLI type Supabase, ou serveurs de dev sur ports dedies), afin de deleguer du travail a d'autres sessions Claude sans conflit de ports, de base ou de containers. Use when user invokes "/setup-worktrees", or asks to set up worktree parallelization / multiple instances on a project, or when a SessionStart reminder says the project is not equipped and the user accepts.
---

# Setup worktrees

Objectif : un script `scripts/<projet>-worktree.ps1` + son nettoyage automatique + les sections "Workflow d'une tache" et "Worktrees" dans le `CLAUDE.md` du projet, adaptes a CE projet. S'inspirer des modeles de `reference/` (dossier de ce skill), ne pas les copier tels quels.

## Modeles de `reference/`

Choisir le plus proche du projet :
- `nop-worktree.ps1` : Docker compose, deux depots (back/front) dans des sous-dossiers, mode "un seul cote". Son nettoyage n'est plus fourni (ancienne regle) : prendre celui d'Overload.
- `overload-worktree.ps1` + `overload-worktree-cleanup.ps1` : mono-depot, stack geree par une CLI (Supabase) + Vite en arriere-plan, isolation par fichiers `.env` non versionnes. Logique de nettoyage de reference (regles a jour).
- `csgo-worktree.ps1` + `csgo-worktree-cleanup.ps1` : mono-depot sans Docker ni `.env`, un seul serveur de dev (`rojo serve`) sur `base + N`, fichiers d'execution (port, pid, log) dans `worktrees/.run/` hors du worktree.
- Communs : `install-cleanup-task.ps1` (version CSGO, qui vise toujours le checkout principal) et `t3_threads.py` (lit la base T3 v2 `statev2.sqlite`, repli sur l'ancienne `state.sqlite`).

Originaux vivants (peuvent etre plus recents que `reference/`) : `C:\Users\tbarillon\Documents\dev\akajoule\NOP\scripts\`, `C:\Users\tbarillon\Documents\dev\personnel\Overload\scripts\`, `C:\Users\tbarillon\Documents\dev\personnel\Roblox\CSGO_surf_combat\scripts\`.

## 1. Analyser le projet (lecture seule)

- Structure : un depot git a la racine, ou plusieurs depots dans des sous-dossiers (cas NOP) ? Branche de base (`dev`, `main`...) ? Compte `gh` actif = proprietaire du depot (sinon `gh auth token --user <compte>` comme Overload) ?
- Docker : fichiers compose, services, ports publies. Les ports sont-ils parametres (`${WEB_PORT:-8000}`) ou en dur ?
- `.env` : quelles variables dependent des ports (URL d'API, CORS, URL front...) ? Ne lire que les cles (noms), jamais les valeurs (secrets).
- Autres ressources partagees : volumes nommes, `container_name:` fixes (bloquent `COMPOSE_PROJECT_NAME`), noms de reseau externes.
- Serveurs de dev hors Docker : commande, port par defaut, option de port, URL de sante a verifier (ex. Rojo : `--port`, `/api/rojo`).
- Clients externes qui se connectent a la stack (Studio, app mobile, extension) : comment les pointer vers le port d'un worktree, et leurs limites (ex. plugin Rojo : mode Edit uniquement, un serveur par fenetre).
- Worktrees existants : `git worktree list`. Un depot deplace laisse des worktrees "prunable" : `git worktree repair <chemin>` avant d'y toucher.

Sans Docker compose : si le projet n'a ni serveur ni port (lib, scripts), `git worktree` suffit : proposer seulement une courte section `CLAUDE.md`, puis s'arreter. S'il a des serveurs de dev a ports fixes, faire quand meme le script (meme contrat ci-dessous, "stack" = serveurs de dev lances en arriere-plan) : modele `csgo-worktree.ps1`.

## 2. Proposer le plan avant d'ecrire

Presenter a l'utilisateur, et attendre son accord :
- emplacement des worktrees (par defaut `<racine>/worktrees/<projet>-<slug>/`, a ajouter au `.gitignore` si la racine est un depot) ;
- variables de port et formule par slot N (`PORT = base + 100*N` quand la stack a plusieurs ports voisins, sinon `base + N`, ex. un seul serveur ou petits ports type pgAdmin) ;
- variables derivees a realigner dans le `.env` du worktree (ou ou stocker port/pid/log s'il n'y a pas de `.env`) ;
- modifications necessaires du compose (ports en dur -> `${VAR:-defaut}`, suppression des `container_name`). Ce sont des changements dans le code du projet : les lister explicitement.
- Si une issue du projet demande deja cet outillage, livrer sur sa branche avec `Closes #<n>`.

## 3. Ecrire les scripts

Contrat attendu par `/delegate`, a respecter : idempotent (worktree existant sur la bonne branche reutilise, slot garde), demarrage par defaut avec verification des URL et sortie `[OK (...)]`, options `-NoUp`, `-Stop`, `-Remove`, `-NoRegister`, `-RegisterThread <id>`, registre `worktrees/.owners.json` + script de nettoyage et tache planifiee.

Regles de nettoyage (workflow global du `CLAUDE.md` utilisateur), deja implementees dans les cleanups Overload et CSGO : threads T3 du worktree plus actifs -> arret de la stack seulement ; PR de la branche mergee (ou fermee sans merge) et aucune PR ouverte -> suppression du worktree et de sa stack, si tout est commite et pousse, plus la branche locale si la PR est mergee (gardee si fermee sans merge). Fermer ou archiver un thread ne supprime jamais rien a lui seul. A chaque passage, fast-forward du checkout principal sur la branche d'integration (s'il y est sans modification).

Fonctionnalites minimales :
- `<Branch>` [-Base] [-Slot] [-NoUp] [-Stop] [-Remove] [-NoRegister] [-RegisterThread] ; slug = branche avec `/` -> `-` ;
- racine du checkout principal resolue par `git rev-parse --path-format=absolute --git-common-dir` (pas `Split-Path $PSScriptRoot`) : le script peut etre lance depuis la copie d'un worktree ;
- cree la branche depuis `origin/<Base>` si elle n'existe ni en local ni sur origin ; sinon worktree sur la branche existante (suivi d'origin) ;
- Docker : copie le `.env` du checkout principal puis fixe `COMPOSE_PROJECT_NAME=<projet>-<slug>` et les ports du slot ; `-Up` = `docker compose up -d --build` ; `-Remove` = `docker compose down -v --rmi local` puis `git worktree remove` (branche conservee) ; avertir si le compose du worktree a encore des ports en dur (branche a rebaser) ;
- serveurs de dev : lances via `Start-Process pwsh -WindowStyle Hidden` (sortie redirigee vers un journal), pid enregistre, arret par `taskkill /T` du pid puis de tout processus du serveur encore a l'ecoute sur le port du slot ;
- fichiers d'execution non versionnes (pid, log, port) : dans un fichier deja ignore du projet, sinon hors du worktree (`worktrees/.run/<slug>.*`). Un fichier non ignore dans le worktree rend `git status` sale (sur les vieilles branches qui n'ont pas la regle `.gitignore`) et bloque `-Remove` et le nettoyage ;
- slot libre auto : ports deja attribues aux autres worktrees + ports reellement ecoutes (`Get-NetTCPConnection`).

Multi-depots seulement : ajouter le mode "un seul cote" (2e instance de l'autre depot via un override compose), comme dans `nop-worktree.ps1`. Sinon, ne pas l'implementer.

Respecter les regles globales : commentaire d'une ligne par fonction ("Cette methode permet de..."), ASCII uniquement dans le code (verifier avec `Select-String -Pattern '[^\x00-\x7F]'`).

## 4. Documenter et verifier

- Ajouter au `CLAUDE.md` du projet une section "Worktrees" : usage du script, convention de dossiers, ports par slot, "lancer les commandes (docker compose, tests, build) depuis le worktree concerne", "ne pas lire ni recopier le `.env` d'un worktree", connexion des clients externes au port d'un worktree (en trois etapes maximum), regles de nettoyage et tache planifiee.
- Ajouter aussi une section "Workflow d'une tache" (modele : `CLAUDE.md` d'Overload), adaptee au projet : commande de creation du worktree, URL (ou port) de test et comment creer un compte de test pour les validations UX, branche d'integration cible des PR, `Closes #<n>`, fermeture du thread, merge uniquement sur ordre puis `-Remove`. Le hook `worktree-reminder.ps1` repere cette section a son titre.
- Projet deja equipe mais incomplet (rappel du hook) : n'ajouter que ce qui manque (section workflow, regles de nettoyage, tache planifiee).
- Tester de bout en bout sur des branches jetables (`-NoRegister`) : creation, demarrage, stack du worktree et stack du checkout principal qui repondent en meme temps, relance idempotente, deuxieme worktree sur le slot suivant, `-Stop`, `-Remove`. Tester le nettoyage en `-DryRun` : `-RegisterThread fake-id` sur une branche jetable (attendu : palier arret) puis sur une branche dont la PR est mergee (attendu : suppression), et retirer ces entrees. Annoncer le resultat tel quel.
- Inscrire le worktree de la tache de setup (`<script> <branche> -NoUp`) pour qu'il soit nettoye apres le merge.
- Installer la tache planifiee (`install-cleanup-task.ps1`) : elle vise le script du checkout principal, qui n'existe qu'apres le merge de la PR du setup ; le signaler.
- Livrer selon le workflow global (branche, PR vers la branche d'integration, sans credit Claude), pas de merge sans ordre.
