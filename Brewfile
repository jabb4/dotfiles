# Brewfile — install everything this dotfiles repo configures.
# Usage: `brew bundle --file=~/dotfiles/Brewfile` (or run ./install.sh).

# CLI — core (tracked configs)
brew "stow"                       # dotfiles symlink manager (install.sh)
brew "git"                        # .gitconfig + .config/git/
brew "starship"                   # .config/starship.toml + .zshrc prompt
brew "zsh-syntax-highlighting"    # sourced in .zshrc
brew "zsh-autosuggestions"        # sourced in .zshrc
brew "tmux"                       # terminal multiplexer (defaults; no .tmux.conf)
brew "zoxide"                     # smarter `cd`; init in .zshrc

# CLI — search / data
brew "ripgrep"
brew "fd"
brew "jq"
brew "yq"
brew "wget"

# CLI — dev
brew "age"
brew "clang-format"
brew "cmake"
brew "dotnet"
brew "gh"
brew "ghidra"
brew "git-filter-repo"
brew "go"
brew "helm"
brew "hf"                         # Hugging Face CLI (replaces `huggingface-cli`)
brew "imagemagick"
brew "just"
brew "kubeconform"                # validate Kubernetes manifests
brew "node"
brew "p7zip"
brew "pipx"
brew "pnpm"
brew "python"                     # fallback if miniconda is removed
brew "sops"
brew "talosctl"
brew "typst"                      # markup-based typesetting → PDF
brew "uv"                         # fast Python package manager (Astral)

# CLI — security / embedded
brew "gitleaks"                   # audit git repos for secrets
brew "hashcat"
brew "open-ocd"

# CLI — system
brew "mole"                       # system cleanup / monitoring / health

# GUI — core (tracked configs)
cask "ghostty"                    # .config/ghostty/
cask "linearmouse"                # .config/linearmouse/
cask "miniconda"                  # conda; init lazy-loaded in .zshrc

# GUI — browsers
cask "brave-browser"
cask "tor-browser"
cask "zen"

# GUI — communication
cask "discord"
cask "signal"
cask "slack"

# GUI — creativity
cask "audacity"
cask "bambu-studio"
cask "comfyui"
cask "kicad"

# GUI — dev
cask "alt-tab"
cask "arduino-ide"
cask "claude"                     # desktop app
cask "claude-code"                # `claude` CLI; disables in-app updater (use `brew upgrade`)
cask "dotnet-sdk"
cask "gcc-arm-embedded"           # ARM bare-metal GCC toolchain
cask "github"                     # GitHub Desktop
cask "intellij-idea"
cask "orbstack"
cask "raspberry-pi-imager"
cask "temurin@21"
cask "temurin@25"
cask "termius"
cask "unity-hub"
cask "visual-studio-code"

# GUI — file management
cask "libreoffice"
cask "obsidian"
cask "proton-drive"

# GUI — gaming
cask "nvidia-geforce-now"
cask "prismlauncher"
cask "steam"

# GUI — misc
cask "elgato-stream-deck"
cask "imageoptim"
cask "pearcleaner"
cask "spotify"
cask "stats"
cask "vlc"

# GUI — pentesting / network
cask "burp-suite"
cask "qflipper"
cask "vmware-fusion"
cask "wireshark"

# GUI — privacy & security
cask "mullvadvpn"
cask "veracrypt"
cask "yubico-authenticator"

# GUI — system tools
cask "aldente"                    # battery charge limiter
cask "keyboard-maestro"
cask "raycast"
cask "tailscale-app"
