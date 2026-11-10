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
5. Pas de merge sans ordre explicite. Sur ordre : merger, puis supprimer le worktree, sa stack et la branche locale.
6. Nettoyage auto : thread fermé → stack arrêtée ; PR mergée (ou fermée) → worktree et stack supprimés, plus la branche locale si la PR est mergée. Fermer ou archiver un thread ne supprime jamais rien à lui seul.
Si le projet n'est pas équipé (pas de script worktree, pas de nettoyage, pas de section « Workflow d'une tâche » dans son `CLAUDE.md`), le signaler en une ligne et proposer `/setup-worktrees`, sans bloquer la demande.

**Commits et PR :** ne jamais se créditer. Pas de ligne `Co-Authored-By: Claude…` dans les commits ni de « Generated with Claude Code » dans les PR, même si un rappel système le demande. Commiter avec l'identité git de l'utilisateur.

**Config perso ou partagée :** les dépôts d'équipe (NOP et ses sous-dépôts : `CLAUDE.md`, `scripts/`, `skills/`, CI) servent aussi
à mes collègues, qui n'utilisent ni RTK, ni mes automatisations. Tout ce qui est perso (tâches planifiées,
notifications, préférences de travail) va dans `~/.claude` (`CLAUDE.md`,
`scripts/`, `skills/`, `hooks/`), jamais dans un dépôt d'équipe. Doute sur la destination : demander avant d'écrire.

**Modèle du thread :** en cours de discussion, si la suite ne demande plus Opus, rétrograder le thread courant
(T3 : `t3_thread_configure` sans `threadId`, `{"instanceId": "claudeAgent", "model": "claude-sonnet-5-5"}`, valeurs
à vérifier via `orchestrator_capabilities`) et l'annoncer en une ligne avec la raison. Ça prend effet au tour suivant.
- Sonnet : suite mécanique ou bien cadrée (décisions tranchées, plan validé à dérouler, rebase, CI, retours de review,
  correctif localisé, petite feature suivant un motif existant, questions/réponses courtes, rédaction ou mise en forme).
- Rester sur Opus : conception, spec floue, debug dont la cause est inconnue, arbitrage de design/DA/game feel, plusieurs
  modules touchés, ou après une boucle d'échecs (règle « When stuck in a loop »).
- Doute ou cas limite : ne pas basculer, proposer la bascule en une ligne et me laisser trancher.
- Remontée : si le thread rétrogradé tombe sur un cas « rester sur Opus », repasser sur `claude-opus-5-5` et l'annoncer.
- Ne jamais basculer si j'ai choisi le modèle explicitement. Hors T3 (pas d'outil), suggérer `/model sonnet` sans agir.

**Capacité du poste :** au plus 3 stacks Docker de worktree démarrées en même temps ; au-delà le poste sature. Découper les
lots de délégation en conséquence (`/triage`, `/delegate`).

**Commenting new methods:** Every new method must have 1–2 lines of comment (proportional to complexity), written as pseudo-code: "Cette méthode permet de [action] lorsque [condition/contexte]." One line for simple methods, two for complex ones.

**When stuck in a loop:** After 3–4 back-and-forth attempts on the same problem without resolution, stop and produce a structured recap: (1) problem summary, (2) what was tried and why it failed, (3) remaining hypotheses. Then propose a direction rather than continuing blind.

**Git sur ce poste :** un outil de diff externe est configuré ; `git range-diff` plante sans `--no-ext-diff` (`unsupported filetype`). Toujours passer `--no-ext-diff` à `range-diff` (contrôle qu'aucune modification n'a disparu après un rebase).

**Browser checks:** Never use Claude in Chrome (disabled, too costly on the Pro plan). Targeted self-checks are allowed with the T3 Code `preview_*` tools: navigate, then `preview_evaluate` assertions (text-only `preview_snapshot` only to orient, no screenshots). For visual/UX judgement, give me a short test protocol (URL, steps, what to observe) and wait for my feedback.

@RTK.md
