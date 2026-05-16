---
name: commit
description: "Stage, commit, and push the current branch's uncommitted changes with a Conventional Commits message. Triggers on /commit and on phrases like 'commit my changes', 'commit and push', 'ship this', or any time the user wants to turn their working-tree edits into a commit and send it to the remote. Generates a concise Conventional Commits message from the diff (type-paren-scope colon subject form), suggests splitting unrelated changes into separate commits, gates commit and push behind user confirmations, warns when pushing to main/master, and never uses --no-verify or --force."
---

Turn the working tree into a clean Conventional Commits commit (or several) and push it to the remote. The user is delegating the analysis and the typing; they confirm the call before anything reaches the remote.

The point of the two confirmations (one before `git commit`, one before `git push`) is not bureaucracy — it's that the user wants to see the message you wrote and the commits you're about to publish *before* either lands. Don't skip them.

## Workflow

### 1. Survey the working tree

Run these in parallel — they're independent:

- `git status` (never `-uall`; it can OOM on large repos)
- `git diff` — unstaged changes
- `git diff --staged` — already-staged changes
- `git log --oneline -10` — recent commit-message style in this repo
- `git rev-parse --abbrev-ref HEAD` — current branch
- `git remote -v` — confirm a remote exists

If the working tree is clean, say so and stop. Don't create an empty commit.

If `HEAD` is detached, or there's an active merge/rebase/cherry-pick, refuse and tell the user to resolve their git state first — committing on top of that is a footgun.

### 1b. Branch guardrail (main/master)

If the current branch is `main` or `master`, **stop immediately** and ask via the `AskUserQuestion` tool before doing anything else — no staging, no message drafting, no secret scan. Phrase it as something like:

> You are about to commit directly to `main`. Continue?
>
> - "Yes, commit to main"
> - "Abort"

Do not proceed past this step until the user picks "Yes". If they abort, stop the workflow cleanly — nothing has been staged or committed yet, so there's nothing to undo. A freeform "yes" / "commit and push" from the user **does not** satisfy this gate; the question must be asked and answered every time the branch is `main` or `master`.

This is separate from the per-message confirmation in step 6 and the pre-push confirmation in step 9 — all three gates fire when committing to main.

### 2. Decide what to stage

If the **index already has staged changes**, the user has curated them — commit exactly that and tell them which unstaged files you're leaving behind. Don't quietly fold the rest in.

If nothing is staged, stage files by **explicit name** (`git add path/to/file ...`). Avoid `git add -A` / `git add .` — those sweep in sensitive files or large binaries.

### 3. Secret scan (delegate to `/secrets`)

Before any `git add`, run the secret-scan workflow defined at `~/.claude/skills/secrets/SKILL.md`. Read that file and follow its instructions, restricted to the files you intend to stage (or files that are already staged).

The `/secrets` workflow will prompt the user per-finding and either:

- Add files to `.gitignore` (and `git rm --cached` if they were already tracked) — in this case the staging set has effectively changed; re-derive what to stage before continuing.
- Have the user dismiss findings as false positives — proceed with staging as planned.
- Have the user **abort** — if so, stop the `/commit` workflow immediately. Don't stage, don't commit, don't push. Tell the user what was found and what to handle manually.

Only continue to step 4 once the scan completes with a "proceed" outcome.

### 4. Look for distinct concerns

Read the diff for shape. If the changes split naturally into unrelated stories — a bug fix in one module plus an unrelated dep bump in `package.json`, or product code plus docs about something else — propose a **split**: one commit per concern, each with its own type and message. Show the user the proposed groups (file lists + draft messages) and let them accept or override.

If the changes form one coherent story, proceed as a single commit.

The user prefers this over a single sprawling commit because clean history makes bisect, revert, and PR review work properly. Don't split for the sake of splitting, though — a bug fix that touches three files in two directories is still one commit.

### 5. Compose the message

**Ground every claim in the staged diff — not in your conversational mental model of what you built.** Before drafting a single word:

1. **Re-read `git diff --staged` right now**, even though you already ran it in step 1. Files routinely change between those two moments — a linter reformats, the user edits, an intermediate tool call lands. The state you saw earlier is stale; the staged content *as of this instant* is what the message must describe.
2. **Every concrete claim in the body must point to a visible diff hunk.** Counts (layers, files, endpoints), specific behaviors, before/after framing, design choices — if you can't put your finger on the lines that justify the sentence, you're hallucinating from memory. When conversation history says one thing and the diff says another, **the diff wins.**
3. **Final-pass sanity check.** Before showing the message in step 6, walk each sentence of your draft body and identify the diff line(s) it refers to. Sentences with no corresponding hunk get deleted or rewritten.

This matters even for "obvious" commits: in a long session, what you built early may have been replaced, refactored, or partially reverted by the time you go to commit. Composing from memory instead of the diff is the #1 way commit messages drift from reality.

Follow Conventional Commits 1.0 (https://www.conventionalcommits.org/en/v1.0.0/):

```
<type>[(scope)][!]: <subject>

[optional body]

[optional footers]
```

**Types** (use only these — this matches the user's global preferences):

- `feat` — a new user-facing capability
- `fix` — a bug fix
- `refactor` — internal change with no behavior change
- `perf` — performance improvement
- `docs` — documentation only
- `test` — tests only
- `chore` — maintenance (deps, config, repo hygiene)
- `build` — build system or external deps that affect output
- `ci` — CI configuration

**Scope** (optional): use when the change is clearly localized — `feat(auth):`, `fix(sheet):`. Skip the scope when the change spans the whole repo or no single component dominates. Don't manufacture a scope just to have one.

**Subject**: imperative mood ("add login", not "added login" or "adds login"), lowercase, no trailing period, ideally ≤72 characters. Focus on what the change accomplishes, not the mechanics.

**Body** (optional, blank-line separated): **max 2 sentences, ideally 0 or 1.** Keep it SIMPLE — a one-line plain-English summary of what's added/changed, not a technical writeup. Skip the body entirely if the subject is self-explanatory. **Don't** enumerate files, list config details, explain implementation, describe trade-offs, justify design choices, or write paragraphs about gotchas. If the why genuinely needs more than 2 sentences, the commit is doing too much — split it. Wrap around 72 chars.

The bar for including a body is "would a human reading the subject still wonder what this changes" — not "is there interesting context I could share." Most commits should have no body at all.

**Breaking changes**: append `!` after the type/scope and include a `BREAKING CHANGE: <description>` footer. Example: `feat(api)!: drop /v1 endpoints`.

**Never** add `Co-Authored-By: Claude` (or any other Claude/Anthropic) trailer. **Never** put emoji in the message. These are the user's standing preferences.

**Match the repo's style**: look at the last ~10 commits. If they have a particular convention (always-lowercase, no scopes, ticket prefixes, specific phrasing), match it as long as it's compatible with Conventional Commits.

### 6. Show the plan, ask for confirmation

Before committing, show the user:

- Which files are being staged (per commit, if splitting)
- The exact commit message(s) you'll use, including subject and any body

Then **always** ask via the `AskUserQuestion` tool — never assume a prior "go" covers the message. Phrase it as a selection question about the proposed message itself, e.g. "Commit with this message?" with options like:

- "Yes, commit as proposed"
- "Edit the message" (user supplies a replacement)
- "Cancel"

Do not run `git commit` until this question is answered. A freeform "yes" or "push" from the user does **not** satisfy this gate — the question must be asked and answered. If the user picks "Edit", use their version verbatim and re-confirm. If they cancel, stop the workflow.

This applies on every invocation, including when the user said "commit and push" up front, when only one file changed, or when the change looks trivial. The point is that the user sees the exact wording before it lands.

### 7. Commit

Stage with explicit file names, then run `git commit`. Pass the message via heredoc so multi-line bodies survive intact:

```sh
git commit -m "$(cat <<'EOF'
feat(auth): add JWT refresh flow

Lets clients renew sessions without re-entering credentials.
EOF
)"
```

If splitting into multiple commits, do them in sequence and stop on the first failure.

**Never** pass `--no-verify`, `--no-gpg-sign`, or `-c commit.gpgsign=false`. If a pre-commit hook fails: read the error, fix the underlying problem, re-stage, and create a **new** commit — not `--amend`. When a hook fails the commit didn't happen, so `--amend` would rewrite the *previous* commit and can destroy earlier work.

Run `git status` after each commit to confirm it landed.

### 8. Pre-push checks

Before pushing, verify:

- The branch tracks a remote. If `git rev-parse --abbrev-ref @{u}` fails, you'll need `git push -u origin <branch>` — surface this in the next confirmation so the user isn't surprised.
- The current branch is not `main` or `master`. If it is, **warn prominently** and ask the user to explicitly confirm the direct-to-main push. Don't proceed without that explicit "yes" — direct commits to main are usually a mistake.

### 9. Confirm the push

Show what's about to be pushed:

- If upstream exists: `git log @{u}..HEAD --oneline`
- Otherwise: list the new commits you just made

Wait for the user to confirm. Then push.

**Never** force-push (`--force` or `--force-with-lease`) from this skill — even if the user asks, treat it as a separate action they need to invoke explicitly outside `/commit`. If `git push` fails with a non-fast-forward error, tell the user and suggest `git pull --rebase`. Don't unilaterally rewrite remote history.

## Edge cases

- **Nothing to commit**: say so and stop. No empty commits.
- **Detached HEAD or in-progress merge/rebase**: refuse, ask the user to resolve git state first.
- **Pre-commit hook failure**: fix the cause, re-stage, new commit. Never `--no-verify`.
- **Non-fast-forward push**: never force-push; suggest `git pull --rebase`.
- **No remote configured**: tell the user the commit was made locally but there's no remote to push to. Don't try to add one yourself.

## Examples

**Single commit, simple fix:**

```
fix(sheet): show existing rating when re-opening a rated serving
```

**Single commit with body explaining the why:**

```
refactor(review-service): read clientId from cookie inside the service

The cookie is httpOnly, so client components can't pass it through.
Reading it in the server action keeps AddReviewInput unchanged.
```

**Breaking change:**

```
feat(api)!: switch /reviews response shape to v2

BREAKING CHANGE: userId is removed from the response; use clientId instead.
```

**Split plan (show this to the user before running anything):**

```
Split into 2 commits:

1. fix(api): return 409 when a client reviews the same serving twice
   files: src/services/reviewService.ts, src/services/reviewErrors.ts,
          src/app/api/reviews/route.ts

2. chore(deps): bump prisma to 7.8.0
   files: package.json, pnpm-lock.yaml
```
