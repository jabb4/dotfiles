# dotfiles

Personal dotfiles. Managed with [GNU Stow](https://www.gnu.org/software/stow/) so files live at their real `$HOME` paths via symlinks.

## What's in here

- `.zshrc` — shell config (zsh + starship + conda init)
- `.gitconfig` — top-level git config
- `.config/git/` — git includes (ignore, attributes, etc.)
- `.config/ghostty/` — Ghostty terminal
- `.config/linearmouse/` — LinearMouse pointer settings
- `.config/starship.toml` — prompt
- `.claude/` — Claude Code global config (CLAUDE.md, settings, skills, plugin marketplaces)

## Install on a fresh machine

```sh
git clone https://github.com/<you>/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script installs Stow via Homebrew if missing, then runs `stow . -t "$HOME"` to symlink everything into place. Re-run after pulling updates.

## Adding a new dotfile

Move the live file into the repo at the same path it has under `$HOME`, then re-link:

```sh
# Example: track ~/.gitconfig
mv ~/.gitconfig ~/dotfiles/.gitconfig
./install.sh
git add .gitconfig && git commit -m "feat: track .gitconfig"
```

```sh
# Example: track a tool's config under ~/.config/foo/
mkdir -p ~/dotfiles/.config/foo
mv ~/.config/foo/config ~/dotfiles/.config/foo/config
./install.sh
git add .config/foo && git commit -m "feat: track foo config"
```

The path inside `~/dotfiles` must mirror the path under `$HOME` — Stow uses the repo layout to decide where each symlink goes.

After this initial move, edits made through the symlink (e.g., a tool rewriting its own config) land in the repo directly, so `git status` will show them next time you `cd ~/dotfiles`.

### Caveats

- **Existing file at the target path**: Stow refuses to overwrite a real file. If `~/.foorc` already exists as a regular file, `mv` it into the repo first, then run `./install.sh`.
- **Atomic-replace tools**: some apps rewrite config by creating a new file and renaming it over the old, which replaces the symlink with a regular file. If a config stops syncing, `mv` it back into the repo and re-run `./install.sh`.

## Uninstall

```sh
cd ~/dotfiles && stow -D . -t "$HOME"
```

This removes the symlinks but leaves the repo intact.
