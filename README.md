# dotfiles

Personal dotfiles. Managed with [GNU Stow](https://www.gnu.org/software/stow/) so files live at their real `$HOME` paths via symlinks.

## What's in here

- `.zshrc` — shell config (zsh + starship + lazy-loaded conda + vi mode)
- `.hushlogin` — empty file that suppresses macOS's `Last login:` banner on shell start
- `.gitconfig` — top-level git config
- `.config/git/` — git includes (ignore, attributes, etc.)
- `.config/ghostty/` — Ghostty terminal
- `.config/linearmouse/` — LinearMouse pointer settings
- `.config/starship.toml` — prompt
- `.config/tmux/` — tmux config (`tmux.conf`, `tmux.reset.conf`); plugins managed by [tpm](https://github.com/tmux-plugins/tpm), see install.sh
- `.config/aerospace/` — [AeroSpace](https://github.com/nikitabobko/AeroSpace) tiling window manager
- `.config/borders/` — [JankyBorders](https://github.com/FelixKratz/JankyBorders) focused-window border
- `.config/AutoRaise/` — [AutoRaise](https://github.com/sbmpost/AutoRaise) focus-follows-mouse
- `.config/karabiner/` — [Karabiner-Elements](https://karabiner-elements.pqrs.org/) caps-lock → Hyper key (so AeroSpace can bind `hyper-N` without breaking Swedish-layout `alt+N` characters)
- `.claude/` — Claude Code global config (CLAUDE.md, settings, skills, plugin marketplaces)
- `Brewfile` — Homebrew formulas, casks, and taps for everything configured here

## Install on a fresh machine

```sh
git clone https://github.com/jabb4/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script:

1. **`brew bundle`** against the [`Brewfile`](Brewfile) — installs anything missing, no-op for what's already there.
2. **Pre-creates "no-fold" directories** (`~/.config/tmux`, `~/.config/karabiner`, `~/.claude`). See [Layout: NO_FOLD_DIRS](#layout-no_fold_dirs) below.
3. **`stow --restow`** — symlinks everything into `$HOME`.
4. **tpm bootstrap** — clones [tmux plugin manager](https://github.com/tmux-plugins/tpm) and installs every `@plugin` declared in `tmux.conf`.

Re-run after pulling updates, editing the `Brewfile`, or adding a new tmux plugin. The script is idempotent — safe to run any time.

### Layout: NO_FOLD_DIRS

By default Stow "tree-folds" a directory: if `~/.config/foo` doesn't exist, Stow makes the whole dir a single symlink into the repo. That breaks if the program later writes runtime files (plugin caches, session state, logs) — those land *inside* the dotfiles repo instead of in `$HOME`.

`install.sh` works around this by pre-creating any directory listed in `NO_FOLD_DIRS` before running Stow. With the parent already present, Stow falls back to file-level symlinks, leaving room for runtime subdirectories to live in `$HOME` where they belong.

Add an entry to `NO_FOLD_DIRS` (in `install.sh`) whenever you track a tool that writes runtime files alongside its config. Current entries: tmux (tpm plugins), karabiner (auto-backups, assets), `.claude` (per-project state, settings).

### Running parts of the install in isolation

To install just the brew packages without re-linking:

```sh
brew bundle --file=~/dotfiles/Brewfile
```

To see what would change without installing: `brew bundle check --file=~/dotfiles/Brewfile`.

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

If the tool writes runtime files into its config directory (plugin caches, session state, logs, auto-backups), also add the home-side path to `NO_FOLD_DIRS` in `install.sh` — see [Layout: NO_FOLD_DIRS](#layout-no_fold_dirs).

### Caveats

- **Existing file at the target path**: Stow refuses to overwrite a real file. If `~/.foorc` already exists as a regular file, `mv` it into the repo first, then run `./install.sh`.
- **Atomic-replace tools**: some apps rewrite config by creating a new file and renaming it over the old, which replaces the symlink with a regular file. If a config stops syncing, `mv` it back into the repo and re-run `./install.sh`.

## Uninstall

```sh
cd ~/dotfiles && stow -D . -t "$HOME"
```

This removes the symlinks but leaves the repo intact.
