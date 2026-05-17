# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles managed with **GNU Stow**. Files in the repo live at their real `$HOME` paths via symlinks — the path inside the repo must mirror the path under `$HOME`. That mirroring is what makes Stow work; preserve it whenever adding or moving files.

There is no build, no test suite, no language runtime. The only entrypoint is `./install.sh`, which: (1) runs `brew bundle` against the repo's `Brewfile`, (2) pre-creates `NO_FOLD_DIRS` so Stow can't tree-fold them (see below), (3) runs `stow --restow --target="$HOME" .` to (re-)link everything, and (4) bootstraps the tmux plugin manager and installs any declared plugins. Re-run it after adding new top-level files or directories, after editing the `Brewfile`, or after declaring a new tmux plugin.

## Layout invariants

- **`.stow-local-ignore`** lists what Stow must NOT symlink: `.git`, `.gitignore`, `.stow-local-ignore`, `README.md`, `/CLAUDE.md` (this file — repo-only, not the symlinked `.claude/CLAUDE.md`), `install.sh`, `Brewfile`, `settings.local.json`. Anything else at the repo root (or under it) gets symlinked into `$HOME`. If you add a repo-only file (CI config, scripts, docs), add it to `.stow-local-ignore` so Stow doesn't drop a symlink for it in `$HOME`.
- **`.gitignore`** excludes `.claude/settings.local.json` (Claude Code's per-machine state, regenerated automatically). Runtime files that programs write into their config dirs (e.g. Karabiner's `automatic_backups/`, tmux's `plugins/`) are kept out of the repo by `NO_FOLD_DIRS` instead — see next bullet.
- **`NO_FOLD_DIRS` in `install.sh`** prevents Stow from tree-folding directories where tools write runtime files. Tree-folding happens when `$HOME/.config/foo` doesn't exist: Stow makes the whole dir a symlink into the repo, so anything the program later writes (plugin caches, session state, logs, auto-backups) lands inside the dotfiles repo. Pre-creating the dir forces file-level symlinks instead, keeping runtime files in `$HOME`. **When you start tracking a new tool, check whether it writes runtime files into its config dir; if yes, add the home-side path to `NO_FOLD_DIRS`** (with an inline comment naming what the tool writes). Current entries: `~/.config/tmux` (tpm plugins), `~/.config/karabiner` (auto-backups/assets), `~/.claude` (per-project state).
- **`Brewfile`** is the source of truth for installed tools — add a `brew`/`cask`/`tap` line here whenever you start tracking config for a new tool, so a fresh-machine `./install.sh` actually installs it. **Never run `brew install` / `brew install --cask` directly in this repo.** The workflow is: add the line to `Brewfile`, then ask the user to run `./install.sh`. The user owns the actual install step — even on an explicit "install X" request.

## Working with live config

The dotfiles tracked here are already symlinked into `$HOME`, so editing `~/.zshrc`, `~/.config/.../foo`, or `~/.claude/CLAUDE.md` writes through to this repo. Edits inside the repo and edits at the symlink target are the same edit. `git status` here is how you discover external changes.

Some apps rewrite config via atomic replace (write-temp + rename), which clobbers the symlink with a real file. If a tool's config stops syncing, `mv` it back into the repo and re-run `./install.sh`.

## `.claude/CLAUDE.md` is global preferences, not project guidance

`.claude/CLAUDE.md` in this repo is a tracked dotfile — it gets symlinked to `~/.claude/CLAUDE.md` and becomes the user's **global** Claude Code preferences across every project. Treat edits to it as a behavior change for all future Claude sessions, not just for work in this repo. Project-specific guidance for the dotfiles repo itself belongs in *this* file (`/CLAUDE.md`).

## Custom skills under `.claude/skills/`

- **`commit`** — the canonical commit/push workflow. Global preferences require using `/commit` for any commit or push; never run `git commit` / `git push` directly. The skill enforces Conventional Commits, runs a secret scan first, asks for explicit message confirmation, and **refuses to push to `main`/`master`** (the user pushes manually in that case).
- **`secrets`** — invoked by `/commit` before staging, also runnable standalone via `/secrets`. Scans for sensitive filenames, known credential formats, and suspicious assignments.

When modifying either skill's `SKILL.md`, the frontmatter `description` is what drives skill triggering — keep it in sync with the actual workflow.
