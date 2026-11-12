---
name: recap-jour
description: |
  Genere le recap de la journee (PR creees/mergees, issues creees, commits) de l'utilisateur sur les depots du projet, avec une section « A relire » qui indique au reviewer ce qui merite une vraie relecture et ce qui peut etre survole. Ecrit le resultat dans recaps/recap-AAAA-MM-JJ.md.
  Use when user invokes "/recap-jour [AAAA-MM-JJ]" or asks for a recap / summary of what he did today, or a hand-off for the reviewer.
  Requires `gh` CLI authenticated. Lance depuis la racine NOP/.
---

# Recap du jour

Objectif : produire un recap factuel de la journee, dont le but premier est de dire au reviewer **quoi relire en priorite et quoi survoler**. Lecture seule sur GitHub et sur le code ; seul `recaps/recap-<date>.md` est ecrit. Ne rien commiter sans demande.

## Arguments

`/recap-jour [AAAA-MM-JJ]` : date par defaut = aujourd'hui (fuseau local). Les depots sont `Outil-NOP-backend/` et `Outil-NOP-frontend/` ; `owner/repo` deduit de `git -C <depot> remote get-url origin`, toutes les commandes `gh` avec `--repo`.

## 1. Collecte (par depot)

Auteur = `@me`. Jour = `<date>`.

- PR mergees ce jour : `gh pr list --author @me --state merged --search "merged:<date>" --json number,title,url,headRefName,createdAt,mergedAt,additions,deletions,changedFiles,files,body,closingIssuesReferences,reviews,labels --limit 50`
- PR ouvertes/mises a jour ce jour (non mergees) : `gh pr list --author @me --state open --search "updated:<date>" --json <memes champs> --limit 50`
- Issues creees ce jour : `gh issue list --author @me --state all --search "created:<date>" --json number,title,url,labels,state --limit 50`
- Une PR creee un jour precedent mais mergee ce jour est incluse, avec la mention *(creee le X, mergee le Y)*.
- Si `files` est tronque (> 100 fichiers), `gh pr diff <n> --repo ... --name-only`.
- Lire le corps de chaque PR (et la spec `docs/specs/...` citee si elle existe dans le depot) pour resumer le « quoi » et le « pourquoi » ; ne pas deviner a partir du seul titre.
- Prendre les `Closes #n` / issues liees pour la colonne de liens.

Ne reprendre que le travail de l'utilisateur. Si rien ce jour-la : le dire en une ligne et ne pas creer de fichier.

## 2. Classer chaque PR par priorite de relecture

Lire le diff (`gh pr diff <n> --repo ...`) des PR a risque pour decider ; ne pas classer a l'aveugle sur les seuls noms de fichiers.

**A relire attentivement** (au moins un critere) :
- logique metier ou calcul (plafonds, subventions, scenarios, formules, serializers/vues API) ;
- migrations, modeles, contrats d'API (champs ajoutes/renommes/supprimes, change cote back ET front) ;
- authentification, permissions, secrets, donnees personnelles ;
- bug fix dont la cause racine n'est pas evidente ou qui touche du code partage ;
- comportement modifie « pour tous » (ex. CI, hooks, config commune) ;
- aucune ou peu de couverture de test pour le code modifie.

**Relecture normale** : feature ou fix localise, avec tests, diff moyen (a la louche < 300 lignes utiles).

**A survoler** (tous les criteres) :
- changement mecanique ou sans effet de comportement (renommage, typage, a11y `type="button"`, reduction de complexite, lint/Sonar) ;
- doc, specs, commentaires, recaps ;
- fichiers generes, lockfiles, snapshots ;
- diff couvert par des tests existants qui passent.

Pour chaque PR, donner **une raison courte et concrete** (« calcul du plafond, nouveaux champs API », « 56 corrections de types, aucun changement de comportement ») et, pour « A relire », **les fichiers ou zones precis** a regarder. Signaler aussi ce qui est ignorable dans la PR (ex. « snapshots, ignorer »). En cas de doute entre deux niveaux, prendre le plus prudent.

Mentionner les risques/limites connus (CI verte ou non, tests manquants, limites citees dans la PR) sans les inventer.

## 3. Rediger `recaps/recap-<date>.md`

Suivre le format de `recaps/recap-2026-10-29.md` (le relire pour le ton et la mise en page). Francais, accents corrects. Structure :

1. Titre `# Récap du JJ/MM/AAAA : PR et issues (<nom git de l'utilisateur>)` ; une ligne d'etat (« mergées dans `dev` » ou mix mergees/ouvertes, dire lequel).
2. **`## À relire en priorité`** : tableau en tete, trie du plus important au moins important.

   | Priorité | Dépôt | PR / issue | Titre | Pourquoi / où regarder |
   |---|---|---|---|---|
   | 🔴 À relire | ... | ... | ... | ... |
   | 🟡 Normale | ... | | | |
   | 🟢 Survol | ... | | | |

   Avec les liens des PR. Les PR « Survol » peuvent tenir en une ligne chacune.
3. **`## Vue d'ensemble`** : tableau Dépôt / PR / Titre / Type (feat, fix, ci, doc, refactor) / Lien, comme le recap existant (inclure les issues creees, avec leur etat).
4. **Détail par thème** (`## Fonctionnel`, `## Qualité de code`, `## CI`, `## Issue créée`...) : par PR, 2 a 6 puces sur ce qui change vraiment, les issues fermees, la spec, les limites connues. Une note `> **Impact pour tous** : ...` si un changement affecte les autres developpeurs.
5. Les PR 🟢 n'ont pas besoin de detail long.

Rester concis : le recap doit se lire en moins de 2 minutes ; la section « À relire en priorité » doit suffire a elle seule au reviewer pressé.

## 4. Fin

Afficher le chemin du fichier et le tableau « À relire en priorité » dans la reponse. Proposer (sans le faire) de commiter le recap dans le depot racine.
