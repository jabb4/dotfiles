---
name: secrets
description: "Scan the repo for accidentally-leaked secrets before they're committed or pushed. Triggers on /secrets and on phrases like 'check for leaked keys', 'scan for credentials', 'is my .env tracked?', 'audit for secrets', or any time the user is worried sensitive data might end up in git history. Also invoked as a pre-stage step from /commit. Flags sensitive filenames not in .gitignore, known credential formats in content (AWS, GitHub, Stripe, private keys, etc.), and suspicious variable assignments where a name like password/token/api_key is set to a string literal. Prompts per-finding so the user can add to .gitignore, ignore the finding, or abort."
---

Find secrets that are about to land in git — or are already tracked when they shouldn't be — and let the user decide what to do about each one before any commit happens. Better a noisy false-positive than a leaked production key.

## When invoked

- **Standalone (`/secrets`)**: scan the whole working tree — both tracked files and untracked ones not in `.gitignore`.
- **From `/commit`**: scan only the files that are about to be staged (or are already staged). The point is to catch leaks *before* they're committed.

Whichever path you're on, the scan + prompt + apply loop below is the same.

## Workflow

### 1. Build the scan list

Run `git status --porcelain` and `git ls-files` in parallel to enumerate:

- Tracked files (`git ls-files`)
- Untracked files not ignored (`git ls-files --others --exclude-standard`)
- Modified/staged paths (`git status --porcelain`)

When called from `/commit`, narrow the list to whatever `/commit` plans to stage (or whatever's already staged). When standalone, use the full list.

Skip very large files (`> 1 MB`) and any obvious binaries — content scans on those are noise. The `file` command or a simple "has any NUL bytes in the first 8 KB" heuristic both work.

### 2. Pass A — sensitive filenames

Flag any file whose path matches one of these patterns and is **either** currently tracked **or** not covered by `.gitignore`:

- `.env`, `.env.*` — but NOT `.env.example`, `.env.sample`, `.env.template`, `.env.dist`
- `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.crt` (when in a source-controlled dir)
- `id_rsa`, `id_rsa.*`, `id_ed25519`, `id_ecdsa`, `*.ppk`
- `credentials`, `credentials.json`, `*credentials*.{json,yml,yaml}`
- `secrets.{json,yml,yaml}`, `secret.{json,yml,yaml}`
- `service-account*.json`, `gcp-key*.json`, `aws-credentials*`
- `*.kdbx` (KeePass)
- `.netrc`, `.pgpass`, `.npmrc` (if it contains an `_authToken`)
- `wallet.json`, `private-key*` files

A file is "covered by .gitignore" if `git check-ignore <path>` exits 0.

### 3. Pass B — known credential formats in content

For each text file in scope, scan content for these known prefixes/shapes. Use `grep -nE` so you get line numbers:

| What | Pattern (extended regex) |
|---|---|
| AWS access key | `AKIA[0-9A-Z]{16}` |
| AWS secret key (label heuristic) | `aws_secret_access_key\s*=\s*[A-Za-z0-9/+=]{40}` |
| GitHub PAT | `gh[oprsu]_[A-Za-z0-9]{36,}` |
| GitHub fine-grained | `github_pat_[A-Za-z0-9_]{82,}` |
| Stripe live key | `sk_live_[A-Za-z0-9]{20,}` |
| Stripe restricted | `rk_live_[A-Za-z0-9]{20,}` |
| Slack token | `xox[abprs]-[A-Za-z0-9-]{10,}` |
| OpenAI API key | `sk-[A-Za-z0-9]{32,}` (be careful, also matches Stripe — disambiguate by prefix) |
| Anthropic API key | `sk-ant-[A-Za-z0-9_-]{20,}` |
| Google API key | `AIza[0-9A-Za-z_-]{35}` |
| JWT | `eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+` |
| Private key block | `-----BEGIN ([A-Z]+ )?PRIVATE KEY-----` |
| Generic "looks like a secret" | `(?i)(api[_-]?key|secret|token|password|passwd)\s*[:=]\s*['"][^'"\s]{8,}['"]` |

Skip matches that look like obvious placeholders: `xxx`, `your-key-here`, `placeholder`, `example`, `<...>`, `changeme`, `TODO`.

### 4. Pass C — suspicious variable assignments

For source files (`.ts`, `.tsx`, `.js`, `.jsx`, `.py`, `.go`, `.rs`, `.rb`, `.java`, `.kt`, `.cs`, `.php`, `.yml`, `.yaml`, `.json`, `.env*`, `.toml`, `.ini`, `.cfg`), look for lines that look like a name → string assignment where the name suggests a credential:

Name (case-insensitive) contains one of: `password`, `passwd`, `secret`, `token`, `auth[_-]?token`, `bearer`, `api[_-]?key`, `apikey`, `access[_-]?key`, `private[_-]?key`, `client[_-]?secret`, `session[_-]?secret`, `credential`.

Assignment shapes to look for:

- `<name>\s*=\s*["']<value>["']` (most languages, env files)
- `"<name>"\s*:\s*"<value>"` (JSON)
- `<name>:\s*["']<value>["']` (YAML, TS object literals)
- `<name>:\s*[A-Za-z0-9+/=._-]{8,}\s*$` (YAML unquoted scalar)

Filter out lines that are clearly false positives:

- Value is empty, or shorter than 6 chars
- Value is a placeholder: `xxx`, `***`, `your-*`, `<...>`, `changeme`, `example`, `placeholder`, `TODO`, `null`, `undefined`
- Value looks like a URL (`https?://...`), file path (`/...`, `./...`), or env reference (`process.env.X`, `${...}`, `os.environ[...]`)
- Line is a TypeScript/Python type annotation: `apiKey: string` with no `=` and no actual value after the colon → skip
- Line is inside a `.test.*` / `__tests__/` / `*.spec.*` file AND value is obviously a fake (matches `test`, `fake`, `dummy`) → skip

This pass is the noisiest. Err on the side of flagging, but include the matched snippet so the user can dismiss false positives quickly with "Ignore".

### 5. Present findings and prompt — per finding

If passes A/B/C produced **zero** findings, say "No secrets detected." and stop (return success to the caller).

Otherwise, for **each finding** show:

- File path (+ line number for B/C)
- Why it tripped: `sensitive filename`, `pattern: <name>`, or `suspicious assignment: <snippet>`
- Current git state: `tracked`, `untracked`, `ignored-but-tracked-historically` (the trickiest case)
- A truncated snippet of the offending content (mask the middle of long secrets: show first 4 and last 4 chars only)

Then ask the user to pick:

1. **Add to `.gitignore` and continue** — appropriate when the file genuinely should not be tracked (`.env`, key files, etc.)
2. **Ignore and continue** — false positive, or an intentional decision (e.g., a public-key fixture, a known-fake test value)
3. **Abort** — something looks real and you need to handle this manually outside the skill

Wait for the user's choice before moving to the next finding. Don't batch.

### 6. Apply the chosen action

**Add to `.gitignore` and continue:**

- If `.gitignore` doesn't exist at the repo root, create it.
- Append a line that targets the file. Prefer the most specific pattern that still covers obvious siblings: a file at `apps/web/.env` should add `.env` (covers any future `.env` anywhere) only if the user agrees that's the intent; otherwise add the literal path. When unsure, ask. For a one-off cert at `secrets/prod.key`, the literal path is safer than `*.key`.
- If the file was **currently tracked**, run `git rm --cached <path>` to stop tracking it. The working-copy file stays on disk; only the index entry is removed. Make this explicit to the user — they should understand the file isn't being deleted, just untracked.
- Stage `.gitignore` (and the `git rm --cached` removal) so the user's next commit includes them. The caller (`/commit`) will pick those up.

**Ignore and continue:**

- Do nothing. Move to the next finding.
- Remember the user's choice for the rest of this session — don't re-prompt for the same finding if scanning runs again.

**Abort:**

- Stop the whole workflow. If invoked from `/commit`, signal abort to `/commit` so it does not stage or commit anything.
- Tell the user clearly what was found and what action they should consider taking manually (rotate the key, `git rm --cached`, scrub history with `git filter-repo` or `bfg`, etc.).

### 7. Re-scan after changes (only if necessary)

If the user picked "Add to .gitignore" for any finding, the file list may have shifted — but the *content* findings (B/C) for already-staged files are still valid. Don't loop forever. Re-scan once if multiple files were gitignored, then proceed.

## Already-leaked-to-history caveat

If a file is currently tracked because it was committed in the past, adding it to `.gitignore` + `git rm --cached` only prevents *future* commits from picking it up. The secret is still in history. Surface this to the user when you flag a tracked sensitive file:

> Note: this file has been committed in the past, so the secret may still exist in your git history. Consider rotating the credential and, if necessary, rewriting history (e.g., `git filter-repo --path <file> --invert-paths`).

You don't try to rewrite history yourself — that's the user's call, on a separate workflow.

## Output to caller

When invoked from `/commit`, return a short summary:

- `proceed` — the user resolved or dismissed every finding; `/commit` may continue. List anything added to `.gitignore` or untracked so `/commit` knows the staging set may have changed.
- `abort` — the user picked Abort on at least one finding; `/commit` must stop.

When invoked standalone, just give the user a recap of what was found and what they decided.

## Examples

**Standalone, finds a tracked `.env`:**

```
Found 1 sensitive item:

  .env (sensitive filename, currently tracked)
    DATABASE_URL=postgres://...
    API_KEY=sk_live_8a7df0c2...e6d5 (masked)

  Note: .env is already tracked. Past commits may still contain it.

Pick: [1] gitignore + untrack  [2] ignore  [3] abort
```

User picks 1 → append `.env` to `.gitignore`, run `git rm --cached .env`, stage both, tell the user about rotating the key.

**From `/commit`, finds a hardcoded Stripe key in a source file:**

```
Found 1 sensitive item:

  src/payments.ts:42 (pattern: Stripe live key)
    const stripe = new Stripe("sk_live_8a7d...e6d5");

Pick: [1] gitignore + untrack  [2] ignore  [3] abort
```

`gitignore + untrack` doesn't apply to a source file with an inline secret — explain to the user that gitignoring `src/payments.ts` is almost certainly not what they want. In that case the meaningful options are **Ignore** (if it's a known-fake test key) or **Abort** (real key — rotate and remove inline before committing). Tell the user that and re-prompt with just those two.

That last point matters generally: the three options aren't always all valid. Use judgment per finding.
