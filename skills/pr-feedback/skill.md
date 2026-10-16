---
name: pr-feedback
description: |
  Fetch unresolved review comments (and SonarQube Cloud issues, if analysed) from a GitHub PR and write them to a structured feedback file.
  Use when user invokes "/pr-feedback <PR_NUMBER>" or asks to retrieve unresolved PR comments.
  Requires `gh` CLI authenticated. Queries GitHub GraphQL API, groups comments by file with line ranges, and writes a `pr_<number>_feedback.md` file in the project root.
---

# PR Feedback Skill

Retrieve all unresolved review threads from a GitHub PR and write them to a structured markdown feedback file.

## Process

1. **Parse the PR number** from the skill argument. If missing, ask with AskUserQuestion.
2. **Detect the GitHub repo** by running: `git remote get-url origin` — extract `owner/repo` from the URL.
3. **Query GitHub GraphQL API** via `gh api graphql` to fetch unresolved review threads.
4. **Fetch SonarQube Cloud issues** if the PR has a `sonarqubecloud` comment (see "SonarQube Cloud" below).
5. **Format and write** the feedback file to the project root as `pr_<number>_feedback.md`.

## GraphQL Query

```bash
gh api graphql -f query='
{
  repository(owner: "OWNER", name: "REPO") {
    pullRequest(number: NUMBER) {
      title
      reviewThreads(first: 100) {
        nodes {
          isResolved
          comments(first: 50) {
            nodes {
              body
              author { login }
              createdAt
              path
              line
              originalLine
              startLine
              originalStartLine
            }
          }
        }
      }
      reviews(first: 100) {
        nodes {
          body
          state
          author { login }
          submittedAt
        }
      }
      comments(first: 100) {
        nodes {
          body
          author { login }
          createdAt
        }
      }
    }
  }
}'
```

Replace `OWNER`, `REPO`, `NUMBER` with the values detected from git remote and the argument.

- `reviewThreads`: keep only nodes where `isResolved: false`. Keep **all** comments of each thread (original + replies).
- `reviews`: global review bodies (text submitted with "Approve / Request changes / Comment"). Ignore reviews with an empty `body`.
- `comments`: general PR comments (Conversation tab). Keep all of them, they may give context on the suggestions, **except** the `sonarqubecloud` bot comment (summary only, replaced by the SonarQube section below).

## SonarQube Cloud

The `sonarqubecloud[bot]` comment only holds the Quality Gate summary; the actual issues live on sonarcloud.io (private project, token required).

1. **Detect the project key** from the bot comment: extract `id=<key>` from its `sonarcloud.io/dashboard?id=<key>&pullRequest=<n>` link (e.g. `Akajoule_Outil-NOP-frontend`). No bot comment → skip this whole section silently (repo not analysed by Sonar).
2. **Check the token**: `[ -n "$SONAR_TOKEN" ]`. If missing, do not fail: write the section with a note "SONAR_TOKEN absent, problèmes Sonar non récupérés" + the dashboard link, and tell the user. Never print the token.
3. **Fetch open issues** (max 500 per page, paginate with `p=2..` if `total` > 500):
   ```bash
   curl -s -u "$SONAR_TOKEN:" "https://sonarcloud.io/api/issues/search?componentKeys=<key>&pullRequest=<n>&issueStatuses=OPEN,CONFIRMED&ps=500&p=1"
   ```
   Useful fields per issue: `component` (`<key>:<path>`, strip the `<key>:` prefix), `line` (may be absent), `textRange.startLine/endLine`, `severity`, `type`, `rule`, `message`, `key`.
4. **Fetch security hotspots to review**:
   ```bash
   curl -s -u "$SONAR_TOKEN:" "https://sonarcloud.io/api/hotspots/search?projectKey=<key>&pullRequest=<n>&status=TO_REVIEW&ps=500"
   ```
   Fields: `component`, `line`, `vulnerabilityProbability`, `ruleKey`, `message`, `key`.
5. A `{"errors":[{"msg":"Project doesn't exist"}]}` or 401 response means the token is invalid or lacks access: report it, keep the GitHub part of the file.

## Output Format

File: `pr_<number>_feedback.md` in the current working directory.

```markdown
# Feedback PR #<number> — Commentaires non résolus

> Généré depuis la PR [#<number>](<github_url>/pull/<number>) — Reviewer(s) : @<author>

---

## Commentaires généraux

### @<author> — <date> (<review state, if from a review>)

> <comment body, verbatim>

---

## `<file_path>`

### Lignes <startLine>–<line>     ← use "Ligne <line>" if no startLine, omit if both null

**@<author>** :

> <original comment body, verbatim>

**↳ @<reply_author>** :

> <reply body, verbatim>

---

## SonarQube Cloud

> [Dashboard](https://sonarcloud.io/dashboard?id=<key>&pullRequest=<number>) — <N> issue(s) ouverte(s), <M> hotspot(s) à revoir

### `<file_path>`

- **Ligne <line>** — `<severity>` `<type>` `<rule>` : <message> ([voir](https://sonarcloud.io/project/issues?id=<key>&pullRequest=<number>&open=<issue_key>))
- **Ligne <line>** — hotspot `<vulnerabilityProbability>` `<ruleKey>` : <message> ([voir](https://sonarcloud.io/security_hotspots?id=<key>&pullRequest=<number>&hotspots=<hotspot_key>))

---
```

Rules:
- The "Commentaires généraux" section comes first. It merges non-empty review bodies and PR conversation comments, ordered by date ascending. Omit the section if there are none.
- Group thread comments by file path (one `##` header per file).
- Within a file, order threads by line number ascending. Threads with no line go at the bottom of that file's section under "### Fichier (commentaire général)".
- Include every comment of a thread: the original review comment first, then replies in chronological order, each prefixed with its author (`↳` for replies).
- Preserve code blocks and suggestions verbatim inside the `>` quote blocks (use fenced code blocks inside blockquotes).
- Use `---` separators between threads.
- Files with no line info get `### Fichier (commentaire général)` as heading.
- The "SonarQube Cloud" section comes last. Group by file, then line ascending (issues without line first, as "Fichier"). If Sonar returns 0 issues and 0 hotspots, keep the section with "Aucun problème Sonar ouvert." Omit the section entirely if the PR has no Sonar bot comment.

## Error Handling

- If `gh` is not authenticated: tell the user to run `! gh auth login` and stop.
- If the PR number does not exist: report the error clearly.
- If there are no unresolved threads: write the file with a "Aucun commentaire non résolu." note and inform the user.

## Completion

After writing the file, report:
- How many unresolved threads were found (and how many replies they contain)
- How many general comments were found
- How many Sonar issues / hotspots were found (or why they were skipped)
- The output file path
