---
name: delegate
description: Delegue une tache a une autre session Claude qui travaille dans son propre git worktree (et sa stack Docker isolee), lancee dans un nouveau thread T3 Code (onglet de terminal en secours) avec un brief (valide par l'utilisateur, ou lance directement si la DoD est claire) et un modele adapte a la tache. Use when user invokes "/delegate [branche] [tache]", or asks to delegate / hand off / parallelize a task to another Claude instance or worktree.
---

# Delegate

Objectif : une tache = une branche = un worktree = une session Claude interactive dans un nouveau thread T3, partie d'un brief (valide par l'utilisateur ou lance directement). La session courante reste libre.

## 1. Cadrer la tache

A partir de la demande et de la conversation (ne pas explorer le code pour cela, sauf si la tache est inintelligible sans) :
- branche : celle donnee, sinon proposer `feature/<slug>` ou `fix/<slug>` ;
- objectif, criteres d'acceptation verifiables, perimetre (fichiers/modules concernes) et hors-perimetre explicite ;
- depots concernes si le projet en a plusieurs (cas NOP : back, front ou les deux).

Si un point manque pour ecrire des criteres d'acceptation verifiables, poser la question plutot que d'inventer.

## 2. Niveau d'autonomie et modele

Rediger le brief avec le modele ci-dessous (sans la section Environnement, encore inconnue), puis choisir le niveau :
- **Lancement direct** : l'issue (ou la demande) donne deja une DoD ou des criteres verifiables, le perimetre est clair et aucune vraie decision (UX, regle metier, schema de donnees) n'est a trancher. Afficher le brief pour info et enchainer sur l'etape 3 sans attendre.
- **Validation** : sinon. Afficher le brief avec les questions ouvertes (une recommandation par question) et **ne rien creer avant l'accord explicite**. Integrer les corrections et reafficher si elles sont substantielles.

Choisir aussi le modele de la session deleguee (l'annoncer en une ligne avec la raison) :
- `sonnet` : tache mecanique ou bien cadree (conflits, rebase, CI, retours de review/Sonar, correctif localise, petite feature avec spec claire suivant un motif existant) ;
- `opus` : conception ou ambiguite (plusieurs modules ou back + front, schema/migration non trivial, regle metier a interpreter, spec incomplete).
En cas de doute, `opus`. L'utilisateur peut imposer le modele dans sa demande.

## 3. Creer le worktree et la stack

- Worktree deja present pour la branche (`git -C <depot> worktree list`) : le reutiliser tel quel, ne pas relancer le script. Si la stack manque et que la tache en a besoin, lancer `docker compose up -d --build` depuis ce worktree.
- Tache confiee a un skill qui cree lui-meme ses worktrees (ex. `/pr-maintenance`) : creer le worktree selon les conventions de ce skill (ex. sans `-Up`), et l'indiquer dans le brief (« worktree deja cree, sauter l'etape de creation »). Adapter aussi la section « Avant de rendre la main » aux regles du skill (validation sans Docker...).
- Projet equipe (`scripts/*worktree*.ps1` a la racine, voir la section "Worktrees" du `CLAUDE.md` du projet) : lancer le script avec la branche, `-NoUp` (quelques secondes, pas de build Docker) et `-NoRegister` (le thread courant ne fait que deleguer : il ne doit pas compter parmi les proprietaires du worktree, sinon le nettoyage attend aussi sa fin). Relever dans sa sortie le slot, les URL et les dossiers crees. Le demarrage des stacks est delegue a la session (etape « Demarrer la stack » du brief), pour que la delegation soit quasi instantanee.
  - Indiquer dans le brief la commande de demarrage exacte : le meme script avec la branche, sans `-NoUp` (idempotent, gere la 2e instance du cote absent et verifie les URL).
  - Si la tache n'a besoin que d'un cote (ex. review back sans verification visuelle), le preciser : la session peut se contenter de `docker compose up -d --build` dans le worktree concerne.
- Projet non equipe sans Docker : `git worktree add <racine>/worktrees/<slug> -b <branche> origin/<base>` (ou sans `-b` si la branche existe). Si `worktrees/` n'est pas ignore (`git check-ignore -q worktrees`), l'ajouter a `.git/info/exclude` (local, pas de modification suivie).
- Projet non equipe avec Docker compose : s'arreter et proposer `/setup-worktrees` d'abord.

Si le script echoue (ports en dur, branche a rebaser...), rapporter l'erreur telle quelle et ne pas lancer de session.

## 4. Ecrire le brief et lancer

- Ecrire le brief complet dans `<racine>/worktrees/.briefs/<slug>.md` (dossier ignore par git).
- Dossier de lancement :
  - racine multi-depots non versionnee (cas NOP) : la racine du projet. Les memoires auto sont rattachees au dossier de lancement : une session lancee dans le worktree n'a pas celles de la racine (verifie sur NOP). Le brief impose de ne travailler que dans le(s) worktree(s) ;
  - depot unique : le dossier du worktree (memoire et `CLAUDE.md` partages entre worktrees).
- Lancer, par defaut **dans un nouveau thread T3 Code** (visible dans la sidebar, avec notifications et diff) :
  `pwsh -NoProfile -File "$env:USERPROFILE\.claude\skills\delegate\t3-thread.ps1" -ProjectRoot <dossier de lancement> -Title <slug> -Model <sonnet|opus> -Prompt "Lis le brief <chemin du brief> puis execute-le en respectant toutes ses consignes."`
  Le thread est cree dans le projet T3 dont la racine est le dossier de lancement (NOP pour NOP). Projet equipe : inscrire aussitot ce thread (id affiche par le script) comme proprietaire du worktree avec `<script worktree> <branche> -RegisterThread <id>`. Le nettoyage automatique s'appuie dessus : thread settled -> containers arretes, thread archive -> worktree supprime (si tout est commite et pousse). Ne passer `-WorktreePath <worktree>` / `-Branch <branche>` que pour un depot unique (pour NOP, la session doit partir de la racine pour avoir les memoires). Effort `medium` par defaut (`-Effort high` pour une tache `opus` de conception).
- Secours, si le script echoue (T3 ferme, API changee apres une mise a jour) : signaler l'erreur en une ligne puis lancer dans un onglet Windows Terminal avec `pwsh -NoProfile -File "$env:USERPROFILE\.claude\skills\delegate\launch.ps1" -Dir <dossier> -Brief <chemin du brief> -Title <slug> -Model <sonnet|opus>`.
- Annoncer en 4 lignes : branche, modele, URL de la stack, cycle de vie (projet equipe : settle du thread = stacks arretees, archive = worktree supprime si tout est pousse ; sinon commande `<script> <branche> -Remove` a lancer apres relecture).

## Modele de brief

```markdown
# Brief : <titre court>

Statut : EN COURS

## Environnement
- Branche : `<branche>` (base `<base>`)
- Worktree(s) : `<chemin>` [, `<chemin>`]. Ne modifier aucun fichier en dehors.
- Tous les chemins utiles sont dans ce brief : ne pas lister ni explorer le dossier de lancement ni les checkouts principaux. Premiere commande shell : `cd <worktree>`.
- Stack : <URL back> / <URL front>. Lancer les commandes `docker compose` depuis le worktree concerne.
- Demarrer la stack (non demarree a la creation) : lancer `<commande de demarrage>` en arriere-plan (`run_in_background`) des le debut, puis lire le code pendant le build ; attendre la sortie `[OK]` avant tout test ou appel API.
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

## Suivi
Ce brief sert de liste de taches : cocher chaque critere d'acceptation des qu'il est rempli, et ajouter en bas (section `## Taches decouvertes`) tout ce qui apparait en cours de route, coche une fois fait. Le relire apres un resume de contexte (compaction) avant de reprendre.

## Avant de rendre la main
1. Lancer les tests et le lint concernes **dans la stack Docker du worktree**, corriger jusqu'a ce qu'ils passent.
2. Invoquer le skill `code-review` (niveau medium) sur le diff de la branche ; corriger les points confirmes qui sont dans le perimetre, lister les autres.
3. Relecture croisee legere : lancer un sous-agent (outil Agent, `model: haiku`) avec ce brief et le diff de la branche, charge de verifier critere par critere que le diff couvre les criteres d'acceptation, et de relever les oublis classiques (tests manquants, migration/fixtures non mises a jour, composant existant non reutilise, texte en dur). Corriger ce qui est confirme.
4. Ne pas pousser : l'utilisateur relit puis pousse lui-meme.
5. Preparer la verification humaine : stack du worktree demarree (back et front), donnees de test chargees. Pour un changement front, se verifier d'abord soi-meme par assertions `preview_evaluate` (outils `preview_*` de T3, pas de capture d'ecran) ; l'utilisateur ne garde que le jugement visuel.
6. Ecrire le compte rendu **a la fin de ce fichier de brief** (section `## Compte rendu`) et passer la ligne `Statut :` a `FINI` ou `BLOQUE` (le tableau de bord de l'utilisateur la lit), puis l'afficher aussi dans la session. Contenu, dans cet ordre :
   - **Bloque sur toi** : questions ouvertes, decisions, validations ;
   - **A verifier** (dossier de revue) : les 3 zones les plus risquees du diff (fichier:ligne, pourquoi) ; ce qui a ete verifie et comment (tests, requetes, appels API) ; pour chaque comportement visible, un lien direct vers l'ecran de la stack du worktree et le scenario a suivre (etapes, resultat attendu) ;
   - **Modifie** : criteres d'acceptation coches, fichiers touches, resultat des tests ;
   - **Trouve** : points de review non traites, modifications hors perimetre proposees.
   Rubrique vide : "rien".
```
