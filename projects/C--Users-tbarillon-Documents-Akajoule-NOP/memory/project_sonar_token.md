---
name: project-sonar-token
description: "SONAR_TOKEN (SonarCloud perso, var d'env User Windows) utilise par /pr-feedback, expire le 2026-11-13"
metadata:
  node_type: memory
  type: project
  originSessionId: 3d5e0110-878d-4b55-be8b-cc64b47b1498
  modified: 2026-10-14T15:03:50.667Z
---

Le skill `/pr-feedback` lit les issues SonarCloud (projet prive `Akajoule_Outil-NOP-frontend`) via la variable d'env utilisateur Windows `SONAR_TOKEN` (token perso, cree le 2026-10-14, valable 30 jours -> expire le **2026-11-13**).

**Why:** sans token valide l'API repond "Project doesn't exist" et la section Sonar reste vide.
**How to apply:** a partir du 2026-11-10 environ, ou si l'API renvoie 401 / "Project doesn't exist", rappeler a l'utilisateur de regenerer le token (sonarcloud.io > My Account > Security) et de mettre a jour `SONAR_TOKEN`, puis relancer T3 Code.
