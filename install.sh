#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v brew >/dev/null 2>&1; then
    echo "error: Homebrew not found. Install it from https://brew.sh first." >&2
    exit 1
fi

echo "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

echo "Linking dotfiles from $DOTFILES_DIR into $HOME..."
cd "$DOTFILES_DIR"
stow --restow --target="$HOME" .

echo "Done. Open a new shell to pick up changes."
