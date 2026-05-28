fastfetch

# PATH
export PATH="$HOME/.local/bin:$PATH"

# Editor
export EDITOR=nvim

# Aliases
alias ls='eza --group-directories-first --icons=auto'
alias tree='eza --tree --level=2 --icons=auto'
alias vim='nvim'
alias c='clear'
alias cc="claude"
alias ProtonDrive='cd "$HOME"/Library/CloudStorage/ProtonDrive-*-folder'

# Suffix aliases
alias -s md="bat"
alias -s {png,jpeg,heic}="open"
alias -s {mov,mp4}="open"
alias -s yaml="bat -l yaml"
alias -s {go,py,ts,js,c,cpp}="$EDITOR"

# Vi mode: Esc → normal-mode
bindkey -v
KEYTIMEOUT=1
zle-keymap-select() { zle reset-prompt }
zle -N zle-keymap-select

# Cmd+Z (Ghostty sends Ctrl-_) → ZLE undo.
bindkey -M viins '^_' undo
bindkey -M vicmd '^_' undo

# Refresh tmux status bar every command
precmd_functions+=(__tmux_refresh_status)
__tmux_refresh_status() { [[ -n "$TMUX" ]] && tmux refresh-client -S }

# Misc settings
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # filename expansion for `anything=expression` args
setopt nonomatch           # hide error if a glob has no match
setopt notify              # report background-job status immediately
setopt numericglobsort     # sort filenames numerically when sensible

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=$HISTSIZE
setopt extended_history       # store timestamp + duration with each entry
setopt hist_expire_dups_first # drop duplicates first when trimming HISTFILE
setopt hist_ignore_dups       # don't store a command identical to the previous one
setopt hist_ignore_space      # don't store commands that start with a space
setopt hist_verify            # confirm history-expanded command before running
setopt hist_find_no_dups      # skip duplicates in Ctrl-R search
setopt hist_save_no_dups      # don't write duplicates to HISTFILE on save
setopt inc_append_history     # append every command immediately, not on exit
setopt share_history          # share history across running shells in real time

# Up/Down: cycle history entries starting with the line's first word
for k in viins vicmd; do
  bindkey -M $k '^[[A' history-search-backward '^[OA' history-search-backward
  bindkey -M $k '^[[B' history-search-forward '^[OB' history-search-forward
done

# fzf keybindings
eval "$(fzf --zsh)"

# Completion
autoload -Uz compinit && compinit
_comp_options+=(globdots)   # include hidden files/dirs in completion (not globbing)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' menu no
zstyle ':completion:*' insert-tab false   # empty-line Tab opens fzf-tab instead of inserting a tab

# fzf-tab
source "/opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh"
# Preview: dirs → eza tree, files → bat, commands → tldr/man
zstyle ':fzf-tab:complete:*' fzf-preview '
if [[ -d $realpath ]]; then
  eza --tree --level=2 --color=always --icons=auto "$realpath" | head -200
elif [[ -f $realpath ]]; then
  bat -n --color=always --line-range :500 "$realpath"
elif tldr --color always "$word" 2>/dev/null; then
  :
elif man -w "$word" >/dev/null 2>&1; then
  man "$word" 2>/dev/null | col -bx | bat -p -l man --color=always
else
  whence -v "$word" 2>/dev/null || echo "$word"
fi'

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

# zoxide — replaces `cd` with frecency-aware jump; `cdi` is interactive picker.
export _ZO_DOCTOR=0
eval "$(zoxide init zsh --cmd cd)"


# Plugins — MUST be sourced last. zsh-syntax-highlighting hooks ZLE and other
# .zshrc content can override its hooks if loaded earlier.
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
