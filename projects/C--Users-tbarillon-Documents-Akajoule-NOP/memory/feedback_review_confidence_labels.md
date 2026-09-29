---
name: feedback-review-confidence-labels
description: "Dans une revue de code, indiquer pour chaque point si c'est vérifié empiriquement ou une supposition à tester"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: dec7499f-a7c7-4412-ab04-a2f8db53a5ae
  modified: 2026-07-31T12:19:40.307Z
---

Pour chaque point soulevé dans une /review ou code-review, préciser explicitement le niveau de confiance : soit "vérifié" (testé/exécuté, ex. compté les requêtes SQL réelles), soit "à tester pour confirmer" (raisonnement à partir de la lecture du code, pas encore exécuté).

**Why:** Sur la revue de la PR #261 (Outil-NOP-backend), un point de performance (N+1 potentiel sur `_silos_genie_civil`) a été avancé comme un risque probable en se basant uniquement sur la lecture du code (comportement supposé de `prefetch_related` sur le cache FK inverse). Après un test réel (`CaptureQueriesContext` en conditions de prod), le point s'est avéré faux : Django back-populate bien le cache FK inverse lors d'un `prefetch_related`, donc pas de N+1. Présenter ce genre d'hypothèse comme un risque confirmé induit en erreur.

**How to apply:** Dans les futures revues, formuler differemment un point selon qu'il a été vérifié par exécution (tests, requêtes comptées, etc.) ou qu'il s'agit d'une déduction de lecture de code non testée — dans ce dernier cas, dire clairement "à vérifier/tester" plutôt que de l'affirmer comme un fait. Voir aussi [[feedback_tests_docker]] pour comment lancer les vérifications (toujours via `docker compose exec web`, jamais le venv local), et [[feedback_no_unprompted_checks]] : ne lancer ces tests de vérification que si l'utilisateur le demande explicitement (comme ici).
