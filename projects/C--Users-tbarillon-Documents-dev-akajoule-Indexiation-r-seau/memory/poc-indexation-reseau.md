---
name: poc-indexation-reseau
description: "Contexte du POC de recherche documentaire sur les partages SMB d'Akajoule (périmètre, poste, dépôt)"
metadata:
  node_type: memory
  type: project
  originSessionId: 8489366a-8256-47f6-83bd-bd1a2329ef0a
  modified: 2026-11-13T13:27:16.258Z
---

POC de recherche full-text (Python crawler, Tika, OpenSearch, FastAPI, React) sur les partages du serveur Windows stn-srv-data-01 (+ NAS-ARCHIVES). Dépôt privé GitHub Akajoule/Indexation-reseau (renommé le 2026-11-13 ; le dossier local garde l'ancien nom pour l'instant), branche d'intégration `main`.

- Le POC tourne sur le poste de l'utilisateur (16 Go RAM, Docker) : crawler natif Windows (session utilisateur pour l'UNC), OpenSearch/Tika en Docker.
- Dossier de départ validé le 2026-11-13 : `OPERATIONS\CHALEUR RENOUVELABLE` (OPERATIONS accessible à tous).
- `data/` et `rapports/` sont gitignorés : chemins internes et noms de personnes, ne jamais les commiter ni citer de noms de personnes dans le dépôt.

**Why:** cadrage fait avec l'utilisateur, consigné dans docs/besoin.md.
**How to apply:** partir de docs/besoin.md comme référence ; voir [[doc-poc-a-ma-charge]].
