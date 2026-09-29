---
name: feedback-no-out-of-scope-changes
description: "Ne jamais appliquer une modification qui sort du périmètre de la demande sans validation expresse — la signaler et attendre"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 01BUCZus76QsVyAVqaPNuKn1
---

Toute modification de code qui diverge de ce qui a été explicitement demandé ne doit pas être appliquée d'office : la décrire au user et attendre son accord, même quand elle paraît manifestement correcte ou nécessaire.

**Why:** Corrigé le 2026-09-02 sur Outil-NOP-frontend — analyse demandée d'une régression signalée en review sur `ReseauChaleurView.vue` (PR #339) ; j'ai enchaîné directement sur l'application du correctif alors que seule l'analyse avait été demandée. Le user veut décider lui-même de ce qui entre dans un commit, en particulier quand la correction touche une autre PR que celle en cours. Prolonge [[feedback_no_silent_decisions]] (qui cite déjà « portée d'un changement ») et rejoint [[feedback_no_unprompted_checks]] et [[feedback_git_confirm]].

**How to apply:** Livrer d'abord le résultat demandé (diagnostic, analyse, réponse). Si un correctif ou un changement annexe s'impose, l'exposer — fichier, nature du changement, diff proposé — et demander « je l'applique ? » plutôt que de l'écrire puis de l'annoncer. Une formulation comme « et potentiellement faire les corrections » n'est pas une autorisation : elle ouvre la discussion, elle ne la clôt pas.
