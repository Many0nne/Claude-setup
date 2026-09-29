---
name: no-feedback-on-corrections
description: Never draft SendFeedback to Anthropic when the user corrects/forbids a behavior
metadata:
  node_type: memory
  type: feedback
  originSessionId: 70384bf0-926b-4f1a-92ac-a06593d0524b
  modified: 2026-09-29T11:27:30.002Z
---

Quand l'utilisateur signale quelque chose à ne pas faire, ne pas appeler SendFeedback.

**Why:** l'utilisateur trouve ces brouillons inutiles et ne veut pas qu'ils soient créés (demandé le 2026-09-29).
**How to apply:** appliquer la correction (et la mémoriser si utile), sans rédiger de feedback. Voir aussi [[no-git-operations]].
