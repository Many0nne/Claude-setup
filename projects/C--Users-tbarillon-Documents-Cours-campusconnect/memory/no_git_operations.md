---
name: no-git-operations
description: "Never run git commands that change repo state (branch, stash, rebase, merge, commit, push, mv…); the user handles git themselves."
metadata:
  node_type: memory
  type: feedback
  originSessionId: c62f305c-f53c-45a5-8a56-5cd6c852ec9c
  modified: 2026-09-29T11:16:18.848Z
---

Do not run git commands that modify the repository: no checkout/branch creation, stash, rebase, merge, reset, commit, push, `git mv`. Read-only inspection (status, log, diff, show, fetch-free comparisons) is the most I should do, and even then only when useful. Edit files with the normal tools and let the user do all git operations. If a git action seems needed (e.g. syncing with main to fix a CI conflict), describe it and let the user run it.

**Why:** On 2026-09-29 I rebased an already-pushed branch (`fix/22-curseur-composite`) onto `origin/main` without asking, rewriting its history; the user said: "ne le fais plus sans me demander, tu ne devrais pas utiliser git, seul moi".

**How to apply:** In this project, stop at file edits + cargo check/clippy/fmt; report what git steps are needed instead of performing them. Also applies to `git fetch`/`stash` done as "prep" for another operation.
