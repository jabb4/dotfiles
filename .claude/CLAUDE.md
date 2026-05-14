# Global preferences

Loaded into every Claude Code session. Project-specific guidance belongs in that project's `CLAUDE.md`, not here.

## Who I am

Software engineering student at Chalmers University of Technology, Gothenburg, Sweden. Working on a MacBook Pro (M5, Apple Silicon).

**Strong:** Python (6+ years — primary language).
**Comfortable:** Java, C++, C, Go, TypeScript, C#.
**Frontend (not my strongest area):** Next.js + Tailwind. CSS/HTML knowledge is solid but design instincts are weaker than backend instincts — when a frontend decision has tradeoffs, explain them; don't assume I'll catch them.
**Data:** PostgreSQL, Prisma as ORM layer.
**Infra:** Linux servers, Docker, some Kubernetes.

## Response style

- **Answer + why.** Lead with the direct answer, then a short reason. Don't bury the answer under context.
- **Summarize what you did.** After edits or multi-step work, give a brief recap — don't expect me to reconstruct it from the diff.
- **Ask when ambiguous.** If a request has more than one reasonable interpretation, ask before committing to one. Don't pick silently.
- **No emojis.** Anywhere — prose, commits, code, file content.
- **Bullets are fine; headers are fine** when they help scanning. Avoid them for short answers.
- **Moderate verbosity.** Not terse, not verbose. A paragraph or two of explanation is usually right.

## Standing technical rules

**Never do without explicit ask:**
- Anything irreversible or destructive (rm -rf, dropping tables, deleting branches, `git clean -fd`).
- `git push --force` / `--force-with-lease`.
- `git commit --amend` on commits that might already be pushed.
- Installing global dependencies (`npm i -g`, `pip install` outside a venv, `brew install`).
- Running database migrations.
- Anything touching production environments.

**Comments and documentation:**
- No inline comments. Code should be self-explanatory; if it isn't, the fix is clearer naming or structure, not a comment.
- Public API documentation should follow the language's industry-standard format: Javadoc for Java, docstrings (PEP 257, Google or NumPy style) for Python, TSDoc/JSDoc for TypeScript/JavaScript, doc comments for Go, etc.
- General doc principles per Google's documentation style guide: https://google.github.io/styleguide/docguide/best_practices.html — write for the reader, document the why, keep it close to the code.

## Tools & workflow

**Git:**
- Always use the `/commit` skill for commits and pushes — never run `git commit` or `git push` directly. The skill handles Conventional Commits formatting, runs a secret scan, gates push behind a second confirmation, and refuses `--no-verify` / `--force`.
- I'll signal when it's time to commit. Don't proactively suggest committing after edits — wait for me to ask.
- **Shell:** zsh.
- **Python:** conda or pip (depends on the project — ask if unclear which the project uses).
- **Node:** pnpm.
- **OS:** macOS (Apple Silicon). Prefer Homebrew-installed tools; watch for arch mismatches in Docker/native builds.

## Dotfiles repo

My Claude config (`~/.claude/CLAUDE.md`, `settings.json`, `skills/`, `plugins/known_marketplaces.json`) is symlinked from `~/dotfiles` and tracked in git. Edits flow through the symlinks automatically — no copying needed. New skills land in the repo automatically since `~/.claude/skills/` is a folded symlink to `~/dotfiles/.claude/skills/`. When you edit these files you need to remind me to commit and push that repo.
