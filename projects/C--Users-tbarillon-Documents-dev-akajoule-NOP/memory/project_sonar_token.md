---
name: project-sonar-token
description: "SONAR_TOKEN (SonarCloud perso, var d'env User Windows) utilise pour lire les issues SonarCloud des PR (consignes dans le CLAUDE.md NOP), expire le 2026-11-13"
metadata:
  type: project
---

La lecture des issues SonarCloud des PR (section « Retours SonarCloud » du CLAUDE.md NOP) passe (projet prive `Akajoule_Outil-NOP-frontend`) par la variable d'env utilisateur Windows `SONAR_TOKEN` (token perso, cree le 2026-10-14, valable 30 jours -> expire le **2026-11-13**).

**Why:** sans token valide l'API repond "Project doesn't exist" et la section Sonar reste vide.
**How to apply:** a partir du 2026-11-10 environ, ou si l'API renvoie 401 / "Project doesn't exist", rappeler a l'utilisateur de regenerer le token (sonarcloud.io > My Account > Security) et de mettre a jour `SONAR_TOKEN`, puis relancer T3 Code.
