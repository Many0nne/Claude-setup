---
name: dev-db-modifiable
description: "La BDD de dev dans Docker peut etre modifiee librement pour tester une implementation de bout en bout, sans rollback"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 8b4baac2-e839-4441-9c1a-40095e45e164
  modified: 2026-10-07T09:04:36.827Z
---

Pour verifier "litteralement" une implementation, modifier directement la BDD de dev via `docker compose exec web python manage.py shell` (changer localisation, porteur, lignes de budget...) est autorise. Pas besoin de transaction avec rollback.

**Why:** l'utilisateur a refuse un script avec rollback en disant que c'est "purement dev". Quand il demande de "tester", il veut un appel reel (API/shell), pas seulement la suite de tests unitaires.

**How to apply:** pour un test de bout en bout, appeler l'endpoint (APIClient avec `SERVER_NAME="localhost"` dans le shell Django, `testserver` n'est pas dans ALLOWED_HOSTS) sur les donnees de fixtures. Rester prudent hors dev (prod, pre-prod). Voir aussi [[feedback-tests-docker]].
