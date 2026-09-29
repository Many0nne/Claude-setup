---
name: RTK has priority over all tools including Anthropic native tools
description: rtk comes first — before Read, Glob, Grep, and any Bash command
type: feedback
originSessionId: 884f1d77-d9b5-4a8e-a259-cb29523e9690
---
`rtk` has priority over everything, including Anthropic native tools:
- Reading a file → `rtk read <file>` (not Read tool)
- Searching content → `rtk grep <pattern>` (not Grep tool)
- Finding files → `rtk find <pattern>` (not Glob tool)
- Any shell command → `rtk <command>`

Default reflex: want to do something? → `rtk ...`

The full list of supported commands and savings is in CLAUDE.md.

**Why:** User has flagged this as a persistent violation. RTK reduces token consumption by 60-99%. It wraps both shell commands AND file operations.

**How to apply:** Before reaching for any tool (Read, Glob, Grep, Bash), check if rtk covers it. If yes, use `rtk` via Bash. No exceptions.
