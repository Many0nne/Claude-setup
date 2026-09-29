---
name: editor-vscode-no-tests
description: "User works in VS Code (not IntelliJ); never run builds/tests, give terminal commands instead"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 0be23544-3839-48b7-8143-e23e558b18ed
---

L'utilisateur travaille dans **VS Code** (pas IntelliJ). Il ne veut pas que je lance les
tests ni les builds moi-même : je dois implémenter le code puis **lui dire quelles commandes
exécuter** dans le terminal (ex. `mvn compile`).

**Why:** Il pilote l'exécution lui-même et partage le résultat si besoin (cf. CLAUDE.md global "Tests : never run unprompted").

**How to apply:** Après avoir écrit le code, fournir les commandes terminal à copier-coller plutôt que d'appeler Bash pour builder/tester.
