---
name: setup-worktrees
description: Equipe le projet courant pour faire tourner plusieurs branches en parallele (une branche = un git worktree = une stack Docker isolee), afin de deleguer du travail a d'autres sessions Claude sans conflit de ports, de base ou de containers. Use when user invokes "/setup-worktrees", or asks to set up worktree parallelization / multiple instances on a project, or when a SessionStart reminder says the project is not equipped and the user accepts.
---

# Setup worktrees

Objectif : un script `scripts/<projet>-worktree.ps1` + une section "Worktrees" dans le `CLAUDE.md` du projet, adaptes a CE projet. Modele de reference (projet NOP, deux depots back/front) : `reference/nop-worktree.ps1` dans le dossier de ce skill. S'en inspirer, ne pas le copier tel quel.

## 1. Analyser le projet (lecture seule)

- Structure : un depot git a la racine, ou plusieurs depots dans des sous-dossiers (cas NOP) ? Branche de base (`dev`, `main`...) ?
- Docker : fichiers compose, services, ports publies. Les ports sont-ils parametres (`${WEB_PORT:-8000}`) ou en dur ?
- `.env` : quelles variables dependent des ports (URL d'API, CORS, URL front...) ? Ne lire que les cles (noms), jamais les valeurs (secrets).
- Autres ressources partagees : volumes nommes, `container_name:` fixes (bloquent `COMPOSE_PROJECT_NAME`), noms de reseau externes.

Sans Docker compose : pas de script, `git worktree` (ou `EnterWorktree` / `claude --worktree`) suffit. Proposer seulement une courte section `CLAUDE.md`, puis s'arreter.

## 2. Proposer le plan avant d'ecrire

Presenter a l'utilisateur, et attendre son accord :
- emplacement des worktrees (par defaut `<racine>/worktrees/<depot>-<slug>/`, a ajouter au `.gitignore` si la racine est un depot) ;
- variables de port et formule par slot N (`PORT = base + 100*N`, sauf petits ports type pgAdmin : `base + N`) ;
- variables derivees a realigner dans le `.env` du worktree ;
- modifications necessaires du compose (ports en dur -> `${VAR:-defaut}`, suppression des `container_name`). Ce sont des changements dans le code du projet : les lister explicitement.

## 3. Ecrire le script

Fonctionnalites minimales, reprises du modele :
- `<Branch>` [-Base] [-Slot] [-Up] [-Remove] ; slug = branche avec `/` -> `-` ;
- cree la branche depuis `origin/<Base>` si elle n'existe ni en local ni sur origin ; sinon worktree sur la branche existante (suivi d'origin) ;
- copie le `.env` du checkout principal puis fixe `COMPOSE_PROJECT_NAME=<projet>-<slug>` et les ports du slot ;
- slot libre auto : lire les ports deja pris dans les `.env` des worktrees existants ;
- `-Up` : `docker compose up -d --build` dans le worktree ;
- `-Remove` : `docker compose down -v --rmi local` puis `git worktree remove` (la branche est conservee) ;
- avertir si le compose du worktree a encore des ports en dur (branche trop ancienne, a rebaser).

Multi-depots seulement : ajouter le mode "un seul cote" (2e instance de l'autre depot via un override compose), comme dans le modele. Sinon, ne pas l'implementer.

Respecter les regles globales : commentaire d'une ligne par fonction ("Cette methode permet de..."), ASCII uniquement dans le code.

## 4. Documenter et verifier

- Ajouter au `CLAUDE.md` du projet une section "Worktrees" sur le modele de NOP : usage du script, convention de dossiers, ports par slot, "lancer les commandes docker compose depuis le worktree concerne", "ne pas lire ni recopier le `.env` d'un worktree".
- Tester de bout en bout sur une branche jetable : creation, `-Up`, les deux stacks repondent sur leurs ports, puis `-Remove`. Annoncer le resultat tel quel.
- Ne pas commiter sans demande explicite.
