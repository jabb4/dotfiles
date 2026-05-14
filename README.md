# dotfiles

Personal dotfiles. Managed with [GNU Stow](https://www.gnu.org/software/stow/) so files live at their real `$HOME` paths via symlinks.

## What's in here

- `.zshrc` — shell config (zsh + starship + conda init)
- `.config/ghostty/` — Ghostty terminal
- `.config/starship.toml` — prompt
- `.claude/` — Claude Code global config (CLAUDE.md, settings, skills, plugin marketplaces)

## Install on a fresh machine

```sh
git clone https://github.com/<you>/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script installs Stow via Homebrew if missing, then runs `stow . -t "$HOME"` to symlink everything into place. Re-run after pulling updates.

## Uninstall

```sh
cd ~/dotfiles && stow -D . -t "$HOME"
```

This removes the symlinks but leaves the repo intact.
