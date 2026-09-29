---
name: feedback-const-placement
description: "Vue - consts en haut du script setup, extraction vers un fichier dédié seulement si réellement réutilisées ailleurs"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 353b3deb-06f4-4325-8209-0db653e39686
  modified: 2026-09-04T10:00:08.150Z
---

Dans les composants Vue (`<script setup>`), toutes les `const` doivent être regroupées en haut du fichier (après les imports et le setup global éventuel, avant `defineProps`/`defineEmits`). Une const n'est extraite vers un fichier dédié (ex. `src/constantes/*.ts`) que si elle est **effectivement** utilisée par un autre fichier — pas parce qu'elle est "théoriquement réutilisable" (valeur pure, sans dépendance au composant).

**Why:** Confirmé sur Outil-NOP-frontend, `components/reseau-chaleur/CarteLeaflet.vue` : deux const définies au milieu du fichier (`CLASSE_CERCLE_SURVOLE`, `METRES_PAR_DEGRE_LAT`) ont été remontées en haut du fichier mais **non extraites**, bien qu'un fichier `constantes/reseauChaleur.ts` existe déjà pour ce domaine et que `METRES_PAR_DEGRE_LAT` soit une constante générique candidate à la réutilisation. L'utilisateur a explicitement choisi l'option "tout remonter en haut, rien extraire" plutôt que d'anticiper une réutilisation future.

**How to apply:** Quand on range des const dans un composant : 1) toujours les regrouper en haut du `<script setup>` ; 2) grep le nom de la const dans le projet — si aucun autre fichier ne l'utilise déjà, la laisser locale, même si elle a l'air générique ou pure ; 3) si le choix n'est pas évident (const potentiellement utile ailleurs), demander plutôt que de décider seul (voir [[feedback_no_silent_decisions]]).
