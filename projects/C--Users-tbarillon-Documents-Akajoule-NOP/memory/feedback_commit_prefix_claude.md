---
name: feedback-commit-prefix-claude
description: "Tout commit fait par Claude doit avoir un message prefixe par \"claude: \" pour etre identifiable"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 0b20c6d0-47ae-431a-96a1-37d02a32fab9
  modified: 2026-10-12T15:36:52.418Z
---

Quand je fais un commit (back ou front), prefixer la premiere ligne du message par `claude: ` (ex. `claude: fix calcul surface batiment`). Garder aussi le trailer `Co-Authored-By: Claude ...` en fin de message.

**Why:** l'utilisateur pousse lui-meme les commits, ils apparaissent donc sous son nom ; il veut savoir d'un coup d'oeil lesquels viennent de Claude.

**How to apply:** a chaque `git commit` que je redige, y compris dans les skills /pr-maintenance et /delegate. Si un hook de convention de message (commitlint, etc.) refuse le prefixe, le placer apres le type (ex. `fix: claude: ...`) et le signaler. Voir aussi [[feedback-push-force-with-lease]].
