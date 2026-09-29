---
name: feedback-no-silent-decisions
description: "Ne jamais prendre de décision faute d'information, même si le sujet n'est pas ambigu — toujours demander"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 5cb93ce9-f1d2-4259-ada7-1a4025015539
---

Dès qu'une décision doit être prise et que l'information nécessaire n'a pas été fournie, demander au user avant d'agir — même si la situation n'est pas "ambiguë" au sens strict, juste non abordée dans la conversation. Ne pas combler le vide par une hypothèse "raisonnable" silencieuse.

**Why:** Le user veut garder le contrôle total sur les décisions non couvertes explicitement par ses instructions ; il préfère être interrompu plutôt que de découvrir après coup une supposition non validée. Cohérent avec [[feedback_ask_before_search]] et [[feedback_no_autonomous_agents]] — le fil conducteur est la transparence avant action.

**How to apply:** Face à un choix technique non précisé (nom de variable ambigu à trancher, approche parmi plusieurs équivalentes, portée d'un changement, etc.), poser la question plutôt que trancher soi-même et l'annoncer après coup.
