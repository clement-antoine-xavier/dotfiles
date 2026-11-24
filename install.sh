#!/usr/bin/env bash
# Bootstrap this dotfiles setup on a fresh macOS machine.
# Idempotent: safe to re-run.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_DIR="$HOME/.oh-my-zsh"
PLUGIN_DIR="$ZSH_DIR/custom/plugins"
PLUGINS=(
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  zsh-history-substring-search
)

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }

# ---- 1. Homebrew ------------------------------------------------------------
command -v brew >/dev/null 2>&1 || {
  echo "Homebrew is required: https://brew.sh" >&2
  exit 1
}

log "Installing packages from Brewfile"
brew bundle --file="$REPO_DIR/Brewfile"

# ---- 2. Oh My Zsh -----------------------------------------------------------
log "Installing Oh My Zsh"
if [[ ! -d "$ZSH_DIR" ]]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "    already installed"
fi

# ---- 3. zsh-users plugins ---------------------------------------------------
log "Installing zsh-users plugins"
mkdir -p "$PLUGIN_DIR"
for p in "${PLUGINS[@]}"; do
  if [[ -d "$PLUGIN_DIR/$p" ]]; then
    echo "    $p: already installed"
  else
    git clone --depth=1 -q "https://github.com/zsh-users/$p" "$PLUGIN_DIR/$p"
    echo "    $p: cloned"
  fi
done

# ---- 4. fzf shell integration ----------------------------------------------
log "Generating fzf key bindings"
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish || true

# ---- 5. Link dotfiles -------------------------------------------------------
log "Linking dotfiles into \$HOME"
for f in .zshrc .zprofile; do
  if [[ -e "$HOME/$f" && ! -L "$HOME/$f" ]]; then
    mv "$HOME/$f" "$HOME/$f.bak"
    echo "    backed up existing $f -> $f.bak"
  fi
  ln -sfn "$REPO_DIR/$f" "$HOME/$f"
  echo "    linked $f"
done

# ---- 6. Secrets -------------------------------------------------------------
mkdir -p "$HOME/.secrets"
chmod 700 "$HOME/.secrets"
if [[ ! -f "$HOME/.secrets/env" ]]; then
  touch "$HOME/.secrets/env"
  chmod 600 "$HOME/.secrets/env"
  echo "    created ~/.secrets/env (put your exports here)"
fi

cat <<'EOF'

────────────────────────────────────────────────────────────────
Done. Two manual steps remain:

1. Terminal font (agnoster needs a Nerd Font):
   Terminal → Settings → Profiles → Text → Font → Change…
   → "MesloLGM NerdFont Mono", size ~13

2. Open a new Terminal window (or run: exec zsh)

Secrets go in ~/.secrets/env, never in this repo.
────────────────────────────────────────────────────────────────
EOF
