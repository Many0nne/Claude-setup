---
name: No autonomous codebase exploration
description: Do not explore the codebase on your own — ask the user to provide the resources needed instead
type: feedback
originSessionId: 84a13e7d-5493-4c0e-afce-4f0dbb91df07
---
Do not use Glob, Grep, Read, or any other tool to explore the codebase autonomously. Instead, ask the user to paste or share the specific files or code snippets you need, and they will provide them directly in the conversation context.

**Why:** User preference — they want to control what context is loaded rather than having Claude browse files independently.

**How to apply:** At the start of any task, identify what files or information you need and ask the user to provide them. Do not self-initiate file reads or searches.
