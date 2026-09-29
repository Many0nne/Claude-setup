---
name: project-gmi-appel-synchrone
description: Outil-NOP-backend / PR #304 — l'appel BRGM au save d'un bâtiment reste volontairement synchrone
metadata:
  type: project
---

Outil-NOP-backend, PR #304 (`feat/GMI`), décision prise le 2026-08-27 : `rafraichir_zones_gmi` reste appelé **synchrone** dans `BatimentSerializer.create/update`, malgré ~5 s de latence ajoutée en cas de panne du WFS BRGM et le fait que `_doit_interroger` rejoue systématiquement les statuts `INDISPONIBLE`.

**Why:** une panne BRGM est jugée exceptionnelle et hors de notre contrôle ; garder l'appel synchrone conserve la zone fraîche dans la réponse du POST/PUT, donc aucun refetch côté Outil-NOP-frontend. Les options écartées : cooldown sur les `INDISPONIBLE`, `transaction.on_commit` (qui ne rend pas le save instantané — Django exécute les callbacks dans le thread de la requête), et Celery.

**How to apply:** ne pas re-signaler cette latence comme un défaut dans une review du chemin bâtiment. Le `on_commit` du chemin chaufferie (`reseau_chaleur.py`) répond, lui, à un autre besoin : ne pas garder la transaction de `mettre_a_jour_arborescence` ouverte pendant les appels réseau.
