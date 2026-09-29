---
name: feedback-no-autonomous-agents
description: "Ne jamais lancer d'agents (Agent tool / subagents) sans demander confirmation à l'utilisateur au préalable"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: eac7339b-9599-4a64-9a1e-6fdf089a858e
---

Ne pas invoquer l'outil Agent (spawn de subagents) de manière autonome — toujours demander confirmation à l'utilisateur avant de lancer un agent, même si la tâche semble s'y prêter (recherche large, revue de code, etc.).

**Why:** L'utilisateur a explicitement retiré l'autorisation de lancer des agents sans lui demander.

**How to apply:** Avant tout appel à l'outil Agent, demander l'accord de l'utilisateur (via AskUserQuestion ou simplement en texte). Si la tâche justifierait normalement un agent, proposer de le faire plutôt que de l'exécuter directement.
