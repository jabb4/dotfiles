# Global preferences

Loaded into every Claude Code session. Project-specific guidance belongs in that project's `CLAUDE.md`, not here.

## Communication
- **Be concise**. Skip obvious explanations. I don't need to know every step you take.
- **Answer + why.** Lead with the direct answer, then a short reason. Don't bury the answer under context.
- **Summarize what you did.** After edits or multi-step work, give a brief recap — don't expect me to reconstruct it from the diff.
- **Ask when ambiguous.** If a request has more than one reasonable interpretation, ask before committing to one. Don't pick silently.

## Coding
### Principles
#### Simplicity First
**Minimum code that solves the problem. Nothing speculative.**
- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

#### Surgical Changes
**Touch only what you must. Clean up only your own mess.**
When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### Style
- No inline comments. Code should be self-explanatory; if it isn't, the fix is clearer naming or structure, not a comment.
- Follow the API documentation standard specified for the project.
- Format with the project's formatter after edits if one exists.
- Use the project's specified linter after edits if one exists.

### Workflow
**Git:**
- Always invoke commits and pushes through the `/commit` skill — don't run `git commit` or `git push` directly from a conversation turn. The skill handles Conventional Commits formatting, runs a secret scan, gates push behind a second confirmation, and refuses `--no-verify` / `--force`.
- The `/commit` skill itself runs `git commit` and `git push` internally as part of its workflow — those calls are the authorized path, not a violation of the rule above. Don't block them.
- I'll signal when it's time to commit. Don't proactively suggest committing after edits — wait for me to ask.

## Guardrails
**Never do these destructive tasks:**

Pause and let me do them manually if needed.
- Anything irreversible (rm -rf, dropping tables, deleting branches, etc.).
- Destructive git ops: `git reset --hard`, `git checkout .` / `git restore .`,
  `git clean -fd`, `git branch -D`, `git push --force` / `--force-with-lease`.
- `git commit --amend` on commits that may already be pushed.
- Skipping safety checks: `--no-verify`, disabling type checks / tests / linters
  to silence failures (fix the failure instead).
- Alter files outside the current git repo / project
- Global or system installs (`npm i -g`, `brew install`, `pip install` outside a venv, etc.).
- Anything touching a live production environment.

Ask before continiuing:
- Database migrations
- Killing processes


## Environment
- **OS:** macOS (Apple Silicon)
- **Shell:** zsh
### Package manager
- **Default:** Homebrew
- **Python:** conda or pip (depends on the project — ask if unclear which the project uses).
- **Node:** pnpm