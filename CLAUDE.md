# RTK (Rust Token Killer)

**Toujours préfixer les commandes shell par `rtk`**, y compris dans les chaînes `&&` (`rtk git add . && rtk git commit -m "msg"`). Sans filtre dédié, RTK passe la commande telle quelle : c'est toujours sûr.

Filtres dédiés : `git`, `gh`, `cargo`, `tsc`, `lint`, `prettier`, `vitest`, `playwright`, `pnpm`, `npm run`, `npx`, `docker`, `kubectl`, `curl`, `ls`, `read`, `grep`, `find`. Utilitaires : `rtk err <cmd>` (erreurs seules), `rtk test <cmd>` (échecs seuls), `rtk proxy <cmd>` (sans filtre), `rtk gain` (statistiques).

## Behavioral Rules

**Before exploring the codebase:** Read the request and any files already provided in context first. Only explore further if the provided information is clearly insufficient — and explain why.

**Commenting new methods:** Every new method must have 1–2 lines of comment (proportional to complexity), written as pseudo-code: "Cette méthode permet de [action] lorsque [condition/contexte]." One line for simple methods, two for complex ones.

**When stuck in a loop:** After 3–4 back-and-forth attempts on the same problem without resolution, stop and produce a structured recap: (1) problem summary, (2) what was tried and why it failed, (3) remaining hypotheses. Then propose a direction rather than continuing blind.