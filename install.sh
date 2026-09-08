#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================================
# Install programs
# ============================================================================

if ! command -v brew >/dev/null 2>&1; then
    echo "error: Homebrew not found. Install it from https://brew.sh first." >&2
    exit 1
fi

brew analytics off >/dev/null

echo "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# ============================================================================
# Link dotfiles
# ============================================================================

# Pre-create to prevent Stow tree-folding — see README "Layout: NO_FOLD_DIRS".
NO_FOLD_DIRS=(
    "$HOME/.config/openlogi"  # writes locks, agent.sock, rolling config backups
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

# ============================================================================
# Per-program post-install setup
# ============================================================================

# --- Miniconda --------------------------------------------------------------
# Disable conda base auto-activation so the base env doesn't slip into every shell.
CONDA_BIN="/opt/homebrew/Caskroom/miniconda/base/bin/conda"
if [ -x "$CONDA_BIN" ]; then
    "$CONDA_BIN" config --set auto_activate false
fi

echo "Done. Open a new shell to pick up changes."
