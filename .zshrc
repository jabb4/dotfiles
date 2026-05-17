# Misc settings
setopt autocd              # change directory just by typing its name
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # filename expansion for `anything=expression` args
setopt nonomatch           # hide error if a glob has no match
setopt notify              # report background-job status immediately
setopt numericglobsort     # sort filenames numerically when sensible

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt extended_history       # store timestamp + duration with each entry
setopt hist_expire_dups_first # drop duplicates first when trimming HISTFILE
setopt hist_ignore_dups       # don't store a command identical to the previous one
setopt hist_ignore_space      # don't store commands that start with a space
setopt hist_verify            # confirm history-expanded command before running
setopt hist_find_no_dups      # skip duplicates in Ctrl-R search
setopt hist_save_no_dups      # don't write duplicates to HISTFILE on save
setopt inc_append_history     # append every command immediately, not on exit
setopt share_history          # share history across running shells in real time

# PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Aliases
alias ProtonDrive='cd "$HOME"/Library/CloudStorage/ProtonDrive-*-folder'

# Vi mode. Default zsh KEYTIMEOUT is 40 centiseconds (400ms), which makes the
# Esc → normal-mode transition feel laggy. 1 = 10ms = instant.
# The keymap-select hook redraws the prompt on mode change so Starship's
# vicmd_symbol updates immediately mid-line.
bindkey -v
KEYTIMEOUT=1
zle-keymap-select() { zle reset-prompt }
zle -N zle-keymap-select

# >>> conda initialize (lazy-loaded) >>>
# Replaces the standard `conda init` block. The eager version spawns a Python
# process at every shell startup to print the conda shell hook (~200ms on M-series
# Macs) — multiplied by every tmux pane. This stub defers that cost until the
# first `conda` invocation. Run `conda init zsh` to regenerate the eager block.
conda() {
    unset -f conda
    eval "$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook')"
    conda "$@"
}
# <<< conda initialize (lazy-loaded) <<<

# Starship prompt
eval "$(starship init zsh)"

# Plugins — MUST be sourced last. zsh-syntax-highlighting hooks ZLE and other
# .zshrc content can override its hooks if loaded earlier.
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
