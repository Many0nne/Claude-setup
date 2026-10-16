---
name: project-video-presentation
description: "Video promo Datajoule NOP en motion design code (Revideo) dans NOP/Outil-NOP-video, storyboard 10 scenes, prototype scene 7"
metadata:
  node_type: memory
  type: project
  originSessionId: abb16a1e-1382-48d3-b34d-d3c64c59281a
  modified: 2026-10-16T12:28:37.322Z
---

Video de promotion de Datajoule NOP (prospects, salons, LinkedIn ; focus outil, Akajoule en signature) dans `NOP/Outil-NOP-video/` (hors depots back/front, non versionne). Demarree le 2026-10-16.

Choix delegues a Claude par l'utilisateur ("j'attends que le resultat soit bon") : Revideo (MIT ; Remotion ecarte car Akajoule 20-49 salaries = licence payante ; Motion Canvas plus publie depuis 02/2025), 16:9 + declinaison carree 30 s LinkedIn plus tard, texte a l'ecran + musique sans voix off.

Storyboard ~80 s, 10 scenes : accroche, logo, creer une note, situation de reference, EnR'Choix, multi-EnR, comparaison (prototype fait), reseau de chaleur, rapport PPT, CTA.

**Why:** l'utilisateur veut une video modifiable au fil des evolutions de l'app, pas a refaire.
**How to apply:** une scene = un fichier ; captures a terme automatisees (Playwright, donnees de demo, deviceScaleFactor 2) ; rendu `npm run render` avec DISABLE_TELEMETRY=true. Sous Windows Revideo impose `--single-process` qui fait planter Chrome : retire via `puppeteer.ignoreDefaultArgs` dans src/render.ts. Txt avec texte calcule (fonction) = erreur "scene not available" : mettre a jour le texte via tween. Pieges detailles dans le README du projet (encodeur ffmpeg obligatoire, calques en coordonnees ecran).

Retours utilisateur 2026-10-16 sur le prototype : pas de teinte bleue translucide sur les lignes grises (cadres sans remplissage), ombres neutres (pas bleues), texte lisible pendant les dezooms (voile blanc), sons courts sur les animations voulus (effets synthetises, pas de musique pour l'instant). Donnees : garder les donnees de test, recapturer quand les fixtures de demo existeront.

Etat 2026-10-16 (soir) : les 10 scenes existent (accroche, logo, note, situation, enrchoix, scenario, comparaison, reseau, rapport, cta), rendu complet 1 min 53 (plus long que les ~80 s vises). Briques communes dans src/lib/composants.tsx, captures automatisees par `npm run capturer` (puppeteer, projets de test 4/16 ; reset EnR'Choix du projet 16 via docker). Rendu partiel : `npm run render -- note situation`. Piege : ombre sur le parent d'un calque anime = opacite des enfants figee. Vraie URL : nop.datajoule.fr, contact datajoule-nop@akajoule.com. Reste : validation utilisateur du rendu, duree, copy, musique, declinaison carree 30 s.
