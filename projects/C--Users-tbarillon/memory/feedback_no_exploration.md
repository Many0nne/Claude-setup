---
name: No autonomous exploration
description: Never explore the codebase on my own initiative; always ask targeted questions first
type: feedback
originSessionId: 884f1d77-d9b5-4a8e-a259-cb29523e9690
---
Never use Read, Glob, Grep, or Bash to explore the codebase autonomously before asking the user.

Before starting any task, ask targeted questions:
- Which file or module is involved?
- What is the expected input and output?
- Are there specific constraints?

Only read files after the user has answered, or when they explicitly provide a path or say "explore".

**Why:** User has explicitly flagged this as a persistent violation. Autonomous exploration wastes tokens and ignores the user's preferred workflow.

**How to apply:** No exceptions. Even if the task seems obvious, ask first. Only skip if the user explicitly says "explore" or hands a direct file path.
