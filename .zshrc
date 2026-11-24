# ============================================================================
#  ~/.zshrc  —  Oh My Zsh + zsh-users plugins
#  Source of truth: https://github.com/clement-antoine-xavier/dotfiles
# ============================================================================

# ---- Paths & fpath (must be set BEFORE compinit runs) ----------------------
export ZSH="$HOME/.oh-my-zsh"
fpath+=("$ZSH/custom/plugins/zsh-completions/src")

# ---- Theme -----------------------------------------------------------------
ZSH_THEME="agnoster"
DEFAULT_USER="$USER"          # hide "user@host" in the prompt when local
CASE_SENSITIVE="true"
HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"

# ---- History ---------------------------------------------------------------
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE SHARE_HISTORY INC_APPEND_HISTORY

# ---- Plugins (zsh-syntax-highlighting MUST be last) ------------------------
plugins=(
  git
  brew
  macos
  extract
  sudo
  colored-man-pages
  command-not-found
  docker
  kubectl
  gh
  nvm
  zsh-completions
  zsh-autosuggestions
  zsh-history-substring-search
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ---- history-substring-search key bindings ---------------------------------
bindkey '^[[A' history-substring-search-up
bindkey '^[OA' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OB' history-substring-search-down
bindkey '^P'   history-substring-search-up
bindkey '^N'   history-substring-search-down

# ---- Modern CLI tooling ----------------------------------------------------
eval "$(zoxide init zsh)"          # z / zi  (replaces OMZ's `z` plugin)

if command -v fzf >/dev/null 2>&1 && [[ -t 0 ]]; then
  source <(fzf --zsh)              # Ctrl-R history, Ctrl-T files, Alt-C cd
fi

alias ls='eza --group-directories-first --icons'
alias ll='eza -lh --git --icons'
alias la='eza -lah --git --icons'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never'

# ---- Editor ----------------------------------------------------------------
export EDITOR='vim'
export VISUAL="$EDITOR"

# ---- Handy aliases ---------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias reload='source ~/.zshrc'
alias zshconf='$EDITOR ~/.zshrc'
