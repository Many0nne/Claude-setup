# Claude Code config

Config `~/.claude` partagée entre mes PC.

## Contenu versionné
- `CLAUDE.md`, `settings.json` (+ `keybindings.json` si présent)
- `agents/`, `commands/`, `skills/` (hors `skills/synced/`, géré par claude.ai)
- Scripts de hook : `git-safe/` (PreToolUse), `hooks/worktree-reminder.ps1` (SessionStart)
- Statusline : `statusline.ps1`
- Mémoire : `memory/`, `agent-memory/`, `projects/*/memory/`

Tout le reste (credentials, historique, transcripts, caches, plugins installés, `settings.local.json`) est ignoré.

## Installation sur un nouveau PC
```powershell
cd ~/.claude
git init
git remote add origin <url-du-repo>
git fetch origin
git checkout -f -b main --track origin/main   # écrase les fichiers suivis existants
```

## Points d'attention
- Les hooks de `settings.json` utilisent `$env:USERPROFILE` (exécutés avec `"shell": "powershell"`), la statusline `$USERPROFILE` (exécutée via Git Bash, pas d'option `shell`) : ça fonctionne quel que soit le nom d'utilisateur Windows. Tous appellent `pwsh` : PowerShell 7 doit être installé (`winget install Microsoft.PowerShell`).
- Les dossiers `projects/<chemin-encodé>/memory` sont indexés par chemin absolu du projet : la mémoire d'un projet n'est reprise que s'il est cloné au même emplacement.
- Aucun plugin activé (`enabledPlugins` vide).
- `settings.local.json` reste local pour les réglages propres à chaque machine.
