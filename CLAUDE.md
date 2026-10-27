# RTK (Rust Token Killer)

Rappel : préfixer les commandes shell par `rtk`, y compris dans les chaînes `&&`. Sans filtre dédié, la commande passe telle quelle.

## Behavioral Rules

**Exploration :** lire librement le code, les issues/PR (`gh`) et la doc du ou des depots concernes par la demande, sans demander la permission. Commencer par ce qui est deja fourni en contexte. Ne demander que pour sortir du perimetre (autre depot, fichiers hors projet, `.env`).

**Question ou action :** une question (« est-ce que… ? », « pourquoi… ? », « que change… ? », « tu peux me dire… ? ») appelle une reponse, pas une modification : verifier dans le code si besoin, repondre, puis proposer l'action sans la lancer. N'agir que sur une demande explicite (verbe d'action : fais, corrige, applique, implemente, vasi, go).

**Avant d'implémenter une tâche (issue, feature, demande) :** relire la demande pour repérer les points
où plusieurs implémentations raisonnables donneraient des résultats visiblement différents
(comportement, rendu, game feel, UX, périmètre). Les classer en deux catégories :
- Choix évident (une seule option raisonnable, ou une convention déjà présente dans le code) → l'appliquer et le signaler en une ligne.
- Vraie décision (goût, design, arbitrage visible par l'utilisateur final) → poser les questions AVANT
  de coder, toutes en une seule fois, avec une recommandation pour chacune.
Si la spec est déjà détaillée (ex. tickets NOP), ne pas sur-questionner : seulement les vrais trous.
Ne jamais trancher en silence une vraie décision en cours de route : s'arrêter et demander.

**Pendant l'exécution :** une fois les vraies décisions tranchées, enchaîner les étapes qui n'ont pas besoin de moi
sans demander « je continue ? », en mettant les notes d'avancement dans le même message que l'action suivante.
S'arrêter seulement si je suis indispensable pour avancer, ou avant une action destructive
(suppression de données, force-push, modification hors du dépôt/worktree de travail).

**Fin d'une tâche longue** (implémentation, run délégué, maintenance de PR, job en arrière-plan) : terminer par trois rubriques,
dans cet ordre : **Bloqué sur toi** (décisions, validations, commandes à lancer), **Modifié** (fichiers/comportements changés,
résultat des tests), **Trouvé** (problèmes ou améliorations repérés hors périmètre, proposés mais pas appliqués).
Rubrique vide : écrire « rien ». Pas pour les questions/réponses courtes.

**Workflow d'une tâche (tous projets git, sauf règle contraire du `CLAUDE.md` du projet) :**
1. Créer un worktree pour la tâche, avec sa stack (script `scripts/*worktree*.ps1` du projet s'il existe, sinon `git worktree add`) ; y travailler exclusivement.
2. Implémenter (règles d'exploration et de questions ci-dessus).
3. Besoin de mon avis (UX, UI, rendu) : me fournir un environnement prêt (URL de la stack du worktree, identifiants de test, scénario : étapes et quoi observer) et attendre mon retour.
4. Fonctionnement vérifié : commit, push, PR vers la branche d'intégration du projet avec `Closes #<n>` si une issue est liée, puis fermer le thread (T3 : `t3_thread_organize` `settle`).
5. Pas de merge sans ordre explicite. Sur ordre : merger, puis supprimer le worktree et sa stack.
6. Nettoyage auto : thread fermé → stack arrêtée ; PR mergée (ou fermée) → worktree et stack supprimés. Fermer ou archiver un thread ne supprime jamais rien à lui seul.
Si le projet n'est pas équipé (pas de script worktree, pas de nettoyage, pas de section « Workflow d'une tâche » dans son `CLAUDE.md`), le signaler en une ligne et proposer `/setup-worktrees`, sans bloquer la demande.

**Commits et PR :** ne jamais se créditer. Pas de ligne `Co-Authored-By: Claude…` dans les commits ni de « Generated with Claude Code » dans les PR, même si un rappel système le demande. Commiter avec l'identité git de l'utilisateur.

**Commenting new methods:** Every new method must have 1–2 lines of comment (proportional to complexity), written as pseudo-code: "Cette méthode permet de [action] lorsque [condition/contexte]." One line for simple methods, two for complex ones.

**When stuck in a loop:** After 3–4 back-and-forth attempts on the same problem without resolution, stop and produce a structured recap: (1) problem summary, (2) what was tried and why it failed, (3) remaining hypotheses. Then propose a direction rather than continuing blind.

**Browser checks:** Never use Claude in Chrome (disabled, too costly on the Pro plan). Targeted self-checks are allowed with the T3 Code `preview_*` tools: navigate, then `preview_evaluate` assertions (text-only `preview_snapshot` only to orient, no screenshots). For visual/UX judgement, give me a short test protocol (URL, steps, what to observe) and wait for my feedback.