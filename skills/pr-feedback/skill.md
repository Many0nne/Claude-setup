---
name: pr-feedback
description: |
  Fetch unresolved review comments from a GitHub PR and write them to a structured feedback file.
  Use when user invokes "/pr-feedback <PR_NUMBER>" or asks to retrieve unresolved PR comments.
  Requires `gh` CLI authenticated. Queries GitHub GraphQL API, groups comments by file with line ranges, and writes a `pr_<number>_feedback.md` file in the project root.
---

# PR Feedback Skill

Retrieve all unresolved review threads from a GitHub PR and write them to a structured markdown feedback file.

## Process

1. **Parse the PR number** from the skill argument. If missing, ask with AskUserQuestion.
2. **Detect the GitHub repo** by running: `git remote get-url origin` — extract `owner/repo` from the URL.
3. **Query GitHub GraphQL API** via `gh api graphql` to fetch unresolved review threads.
4. **Format and write** the feedback file to the project root as `pr_<number>_feedback.md`.

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
- `comments`: general PR comments (Conversation tab). Keep all of them, they may give context on the suggestions.

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
```

Rules:
- The "Commentaires généraux" section comes first. It merges non-empty review bodies and PR conversation comments, ordered by date ascending. Omit the section if there are none.
- Group thread comments by file path (one `##` header per file).
- Within a file, order threads by line number ascending. Threads with no line go at the bottom of that file's section under "### Fichier (commentaire général)".
- Include every comment of a thread: the original review comment first, then replies in chronological order, each prefixed with its author (`↳` for replies).
- Preserve code blocks and suggestions verbatim inside the `>` quote blocks (use fenced code blocks inside blockquotes).
- Use `---` separators between threads.
- Files with no line info get `### Fichier (commentaire général)` as heading.

## Error Handling

- If `gh` is not authenticated: tell the user to run `! gh auth login` and stop.
- If the PR number does not exist: report the error clearly.
- If there are no unresolved threads: write the file with a "Aucun commentaire non résolu." note and inform the user.

## Completion

After writing the file, report:
- How many unresolved threads were found (and how many replies they contain)
- How many general comments were found
- The output file path
