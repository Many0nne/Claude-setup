---
name: RTK — règles complètes d'utilisation
description: Toujours préfixer toutes les commandes bash avec rtk, y compris ls/read/grep/find qui remplacent les outils Claude natifs
type: feedback
originSessionId: 98521fc1-0bcb-4872-b78c-21d5d74d5d98
---
**Golden Rule : toujours préfixer avec `rtk`. C'est always safe — si RTK n'a pas de filtre dédié, il passe la commande telle quelle.**

## Remplacement des outils Claude natifs par rtk (Bash)

Ces outils Claude NE DOIVENT PAS être utilisés quand rtk couvre le cas :

| Outil Claude natif | Commande rtk à utiliser à la place |
|--------------------|-------------------------------------|
| `Read`             | `rtk read <file>`                   |
| `Grep`             | `rtk grep <pattern>`                |
| `Glob`             | `rtk ls <path>` ou `rtk find <pattern>` |

## Commandes rtk par catégorie (toutes via Bash)

### Fichiers & Recherche
```bash
rtk ls <path>       # listing compact
rtk read <file>     # lecture avec filtrage
rtk grep <pattern>  # recherche groupée par fichier
rtk find <pattern>  # find groupé par dossier
```

### Git (TOUS les sous-commandes, pas seulement ceux listés)
```bash
rtk git status / log / diff / show / add / commit / push / pull / branch / fetch / stash / worktree
```

### Build & Compile
```bash
rtk tsc / rtk lint / rtk next build / rtk prettier --check
```

### Tests
```bash
rtk vitest run / rtk playwright test
```

### JS/TS Tooling
```bash
rtk npm run <script> / rtk npx <cmd> / rtk pnpm install / rtk pnpm list
```

### GitHub
```bash
rtk gh pr view / rtk gh pr checks / rtk gh run list / rtk gh issue list / rtk gh api
```

### Réseau
```bash
rtk curl <url> / rtk wget <url>
```

### Analyse & Debug
```bash
rtk err <cmd> / rtk log <file> / rtk json <file> / rtk summary <cmd>
```

## Dans les chaînes &&
```bash
# ✅ Correct
rtk git add . && rtk git commit -m "msg" && rtk git push
```

**Why:** Instructions explicites dans le CLAUDE.md global. L'utilisateur a signalé plusieurs violations et insiste que ces règles priment sur les préférences par défaut de Claude Code (utiliser les outils natifs).

**How to apply:** Avant chaque action, vérifier si rtk couvre le cas. Si oui → Bash + `rtk`. Les outils natifs (Read, Grep, Glob) uniquement si rtk ne couvre pas le cas.
