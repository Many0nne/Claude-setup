---
name: workshop-git-identity
description: "Workshop repo (Many0nne/Workshop) — commit and push only as Many0nne, never credit Claude in commits"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 9c8685cc-836f-4e42-a84c-54e63bec2043
  modified: 2026-10-19T08:40:42.704Z
---

On the Workshop project (resilience-alpha → github.com/Many0nne/workshop), every commit and push must use only the Many0nne account: author/committer `Many0nne <97261063+Many0nne@users.noreply.github.com>`, and no `Co-Authored-By: Claude` trailer (this overrides the default attribution reminder).

**Why:** the user asked for it explicitly. Their work email (terry.barillon@akajoule.com) is linked to the TerryBarillon GitHub account, which gets no push rights on this repo and showed up as the commit author.

**How to apply:** the repo's local git config already sets user.name/email and `credential.https://github.com.username=Many0nne`. `gh` has both accounts logged in, with TerryBarillon active; don't switch the global account, use `gh auth token --user Many0nne` if needed.
