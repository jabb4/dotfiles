# Brewfile — install everything this dotfiles repo configures.
# Usage: `brew bundle --file=~/dotfiles/Brewfile` (or run ./install.sh).

tap "felixkratz/formulae"
tap "nikitabobko/tap"
tap "dimentium/autoraise"

# CLI
brew "stow"                       # dotfiles symlink manager (install.sh)
brew "git"                        # .gitconfig + .config/git/
brew "starship"                   # .config/starship.toml + .zshrc prompt
brew "zsh-syntax-highlighting"    # sourced in .zshrc
brew "zsh-autosuggestions"        # sourced in .zshrc
brew "felixkratz/formulae/borders" # .config/borders/ (JankyBorders)
brew "tmux"                       # terminal multiplexer (defaults; no .tmux.conf)

# GUI apps
cask "ghostty"                    # .config/ghostty/
cask "linearmouse"                # .config/linearmouse/
cask "nikitabobko/tap/aerospace"  # .config/aerospace/
cask "dimentium/autoraise/autoraiseapp" # .config/AutoRaise/
cask "karabiner-elements"         # .config/karabiner/
cask "miniconda"                  # conda init block in .zshrc
