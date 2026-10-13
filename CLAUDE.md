# RTK (Rust Token Killer)

Rappel : préfixer les commandes shell par `rtk`, y compris dans les chaînes `&&`. Sans filtre dédié, la commande passe telle quelle.

## Behavioral Rules

**Before exploring the codebase:** Read the request and any files already provided in context first. Only explore further if the provided information is clearly insufficient — and explain why.

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

**Commenting new methods:** Every new method must have 1–2 lines of comment (proportional to complexity), written as pseudo-code: "Cette méthode permet de [action] lorsque [condition/contexte]." One line for simple methods, two for complex ones.

**When stuck in a loop:** After 3–4 back-and-forth attempts on the same problem without resolution, stop and produce a structured recap: (1) problem summary, (2) what was tried and why it failed, (3) remaining hypotheses. Then propose a direction rather than continuing blind.

**Browser checks:** Never use Claude in Chrome (disabled, too costly on the Pro plan). When a front-end check needs a browser, give me a short test protocol (URL, steps, console snippet if useful, what to observe) and wait for my feedback.