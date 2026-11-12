---
name: report-differe-ne-pas-agir
description: "« si il faut on fera X » = X est reporté, ne pas l'implémenter maintenant"
metadata:
  node_type: memory
  type: feedback
  originSessionId: bd7b4236-e91e-456a-b4e8-7a79af8b86ed
  modified: 2026-11-03T19:23:38.491Z
---

Quand l'utilisateur répond à une proposition par « normalement ça ne nous dérange pas, si il faut on fera X », X est reporté à plus tard, et ce n'est pas un feu vert conditionnel. Ne pas implémenter X, même si une mesure montre que le problème existe : rapporter la mesure et redemander.

**Why:** issue #71 (virages de l'Arène, 2026-11-03). J'ai mesuré la perte (-14 %) puis modifié `WallSlide` alors que l'utilisateur avait reporté toute correction du mouvement. Il a fallu tout annuler.

**How to apply:** pour toute réponse au conditionnel ou au futur (« si besoin », « on verra », « plus tard »), traiter le point comme hors périmètre. Le système de mouvement en particulier ne se modifie que sur demande explicite.
