---
name: feedback_tests_docker
description: "Tests Django doivent être lancés via docker compose exec, pas directement avec le venv local"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 7bdbb051-7eb7-43f7-a376-4067b08c2bc9
---

Toujours lancer les tests via docker compose, jamais avec le venv local directement.

**Why:** PostgreSQL est requis, Django ne démarre pas sans les dépendances installées dans le container. Le venv local ne suffit pas.

**How to apply:** `docker compose exec web python manage.py test --settings settings.test_settings <test_path>`
