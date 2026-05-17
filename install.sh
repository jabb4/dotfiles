#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v brew >/dev/null 2>&1; then
    echo "error: Homebrew not found. Install it from https://brew.sh first." >&2
    exit 1
fi

echo "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# Pre-create to prevent Stow tree-folding — see README "Layout: NO_FOLD_DIRS".
NO_FOLD_DIRS=(
    "$HOME/.config/tmux"      # tpm plugins
    "$HOME/.config/karabiner" # auto-backups, assets
    "$HOME/.claude"           # per-project state, settings
)
for dir in "${NO_FOLD_DIRS[@]}"; do
    if [ -L "$dir" ]; then
        echo "Unfolding Stow-folded symlink: $dir"
        rm "$dir"
    fi
    mkdir -p "$dir"
done


echo "Linking dotfiles from $DOTFILES_DIR into $HOME..."
cd "$DOTFILES_DIR"
stow --restow --target="$HOME" .

# tpm bootstrap: clone on first run, then install plugins declared in tmux.conf.
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "Cloning tpm into $TPM_DIR..."
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
echo "Installing/updating tmux plugins..."
# tpm queries the tmux server's env, not the shell — set it on the server first.
TMUX_HAD_SERVER=no
tmux info >/dev/null 2>&1 && TMUX_HAD_SERVER=yes
tmux start-server
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"
"$TPM_DIR/bin/install_plugins"
if [ "$TMUX_HAD_SERVER" = "no" ]; then
    tmux kill-server 2>/dev/null || true
fi

echo "Done. Open a new shell to pick up changes."
