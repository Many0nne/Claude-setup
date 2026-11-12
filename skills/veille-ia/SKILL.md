---
name: veille-ia
description: |
  Redige la veille hebdomadaire sur l'IA appliquee au developpement logiciel (modeles, agents, Claude Code, securite, couts...) et l'ajoute en tete du fichier ~/.claude/veille-ia/veille-ia.md.
  Use when user invokes "/veille-ia", asks for his AI watch / veille IA, or when the weekly scheduled task triggers it.
---

# Veille IA

Tu fais ma veille hebdomadaire sur l'IA appliquée au développement logiciel.
Je suis développeur et j'utilise des agents IA au quotidien. Mon objectif : rester à jour
sur ce qui change réellement ma façon de travailler, sans me noyer dans le bruit.

Les éditions sont stockées dans le fichier local `~/.claude/veille-ia/veille-ia.md`
(`C:\Users\tbarillon\.claude\veille-ia\veille-ia.md`).

Période couverte : depuis la date de la dernière édition présente dans ce fichier
jusqu'à aujourd'hui (14 jours maximum). S'il n'y a aucune édition, couvre les 7 derniers jours.

Avant de commencer, lis les éditions précédentes dans ce fichier
pour ne pas répéter ce qui a déjà été couvert. Si un sujet déjà traité a connu une
évolution significative, tu peux y revenir en le signalant.

## Recherche

Explore librement l'actualité (WebSearch / WebFetch) : annonces, articles techniques, discussions de la communauté,
dépôts, publications de recherche. Choisis toi-même tes sources, en privilégiant les sources
primaires (annonces officielles, documentation, papiers, auteurs reconnus) plutôt que les
agrégateurs. Croise les informations importantes et ignore les rumeurs non confirmées.
Ne te limite pas aux acteurs les plus connus : si quelque chose d'important émerge
ailleurs, je veux le savoir.

## Rubriques

Les rubriques ci-dessous sont indicatives. Omets celles qui n'ont rien de notable cette
semaine, et crées-en une nouvelle si l'actualité le justifie.
- Modèles : nouveautés et ce qu'elles changent concrètement pour coder
- Agents et outils de développement
- Bonnes pratiques et retours d'expérience
- Sécurité
- Open source et modèles locaux
- Coûts, quotas et conditions d'utilisation
- Recherche et benchmarks (avec un regard critique)
- Régulation et impact sur le métier
- Claude Code : ce qui a changé sur la période (c'est mon outil principal)

## Format

- 10 à 15 éléments au total, classés par importance au sein de chaque rubrique
- Chaque élément : 2-3 phrases expliquant ce qui s'est passé et pourquoi c'est important
  pour un développeur, suivies du lien vers la source
- En tête : un paragraphe de 3-4 phrases sous le titre de niveau 3 « L'essentiel de la semaine »
- À la fin :
  - « À lire en profondeur » : un seul article long qui vaut le temps de lecture
  - « Le truc à tester cette semaine » : une recommandation concrète et actionnable
- Rédige en français, de façon claire et sans jargon marketing

## Sortie

1. Ajoute l'édition dans `veille-ia.md`, juste sous le paragraphe d'introduction
   et au-dessus des éditions précédentes (la plus récente en haut), sous un titre de niveau 2
   « Veille IA – semaine du JJ/MM/AAAA » (date du jour). Les rubriques sont des titres de niveau 3.
2. Si la ligne « Aucune édition pour l'instant. » est encore présente, supprime-la.
   Ne modifie pas les éditions précédentes.
3. N'écris jamais dans un autre fichier que `veille-ia.md` (hormis le marqueur ci-dessous).
   Si le fichier est absent ou illisible, arrête-toi et signale l'erreur au lieu d'écrire ailleurs.
4. Une fois l'édition écrite, enregistre la date du jour (format `AAAA-MM-JJ`) dans
   `~/.claude/veille-ia/last-run.txt` (écrasement) : c'est ce qui empêche le lancement auto de la refaire cette semaine.
   Utilise exactement, en appel séparé :
   `Set-Content -Path "$env:USERPROFILE\.claude\veille-ia\last-run.txt" -Value (Get-Date -Format yyyy-MM-dd) -NoNewline`
   puis vérifie que `should-run.ps1` affiche SKIP ; sinon, signale-le.
5. Publie l'édition dans Slack (#dev-organisation) :
   `pwsh -NoProfile -File "$env:USERPROFILE\.claude\veille-ia\post-slack.ps1"`.
   Le script crée un canvas avec l'édition complète et poste l'essentiel avec le lien dans le canal.
   Il s'appuie sur le titre de niveau 3 exact « L'essentiel de la semaine » : utilise-le tel quel.
   Si le script échoue, ne réessaie pas en boucle : l'édition locale est déjà écrite, signale juste l'erreur.
   Ne lis jamais `slack-token.txt` et n'affiche jamais le token.
6. Termine ta réponse par « L'essentiel de la semaine », le lien vers le fichier et le lien du canvas Slack (ou l'erreur d'envoi).
