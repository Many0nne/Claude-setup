# Memory Index

- [Tests via Docker](feedback_tests_docker.md) — Toujours `docker compose exec web python manage.py test --settings settings.test_settings`, jamais le venv local
- [Composables = réseau uniquement](feedback_composables_network_only.md) — Outil-NOP-frontend : useXxx = appels API seulement, jamais de logique réutilisable générique
- [Convention src/forms/](project_forms_convention.md) — Outil-NOP-frontend : nouveau dossier createXxxForm() pour state+orchestration hors composables réseau
- [Confiance des points de review](feedback_review_confidence_labels.md) — Dans une review, préciser si un point est vérifié (testé) ou une supposition à tester
- [Proposer la factorisation](feedback_propose_factorisation.md) — Proposer d'extraire un composant/fonction dès qu'on duplique du markup ou de la logique
- [Appel BRGM synchrone assumé](project_gmi_appel_synchrone.md) — PR #304 : latence save bâtiment acceptée, ne pas re-signaler en review
- [Pas de changement hors périmètre](feedback_no_out_of_scope_changes.md) — Ne pas appliquer une modification hors de la demande sans accord explicite, la proposer d'abord
- [Placement des const en Vue](feedback_const_placement.md) — Const en haut du script setup ; extraction vers fichier dédié seulement si déjà utilisée ailleurs, jamais par anticipation
- [Pas d'Unicode ambigu dans le code](feedback_ascii_only_python.md) - Jamais d'espace fine (ni " "), ×, tirets/guillemets typographiques : ASCII simple uniquement (ruff RUF001 bloque le commit)
- [Imports en haut du fichier](feedback_imports_en_haut.md) — NOP : jamais d'import local dans une fonction, même pour un cycle ; proposer une alternative
- [Subventions #389](project_subventions_389.md) — spec specs/subventions-389.md, travail non commité sur dev, points ouverts
- [BDD de dev modifiable](feedback_dev_db_modifiable.md) — Tester de bout en bout en modifiant la BDD dev via docker, sans rollback
