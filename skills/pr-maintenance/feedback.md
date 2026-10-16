# Procedure : retours de review et SonarCloud

1. **Recuperer les retours** avec le skill `pr-feedback` (threads non resolus, reviews, commentaires, issues et hotspots SonarCloud), lance depuis le worktree (il deduit le depot du `origin` courant). Deplacer ensuite le fichier produit vers `<racine NOP>/worktrees/.briefs/_pr<n>-feedback.md` : il ne doit jamais etre commite dans le worktree.
2. **Lister chaque point** (thread, review, issue ou hotspot Sonar) et le classer :
   - **a corriger** : demande claire et dans le perimetre de la PR. Une suggestion GitHub est appliquee telle quelle sauf incoherence ;
   - **decision** : le point demande un arbitrage (design, UX, regle metier, extension a d'autres fichiers que ceux de la PR, desaccord technique). Ne pas trancher : le remonter avec une recommandation ;
   - **sans action** : deja traite par un commit plus recent, ou faux positif Sonar (dire pourquoi). Ne jamais marquer une issue Sonar comme acceptee ou faux positif sur sonarcloud.io : l'utilisateur le fait.
3. **Corriger** les points "a corriger", un commit par groupe coherent de points.
4. **Verifier** : relire chaque point "a corriger" face au diff des commits pour confirmer qu'il est couvert.

## Recap

Tableau point -> traitement (commit, ou raison du non-traitement), avec la source (`@reviewer` ou `Sonar <rule>`) ; puis les decisions a prendre, chacune avec sa recommandation.
