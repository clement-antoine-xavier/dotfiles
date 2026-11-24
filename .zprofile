# Homebrew environment (must come before anything using brew-installed binaries)
eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# Local secrets (never committed). Create with:
#   mkdir -p ~/.secrets && chmod 700 ~/.secrets
#   echo 'export DEEPSEEK_API_KEY="..."' > ~/.secrets/env && chmod 600 ~/.secrets/env
[ -f "$HOME/.secrets/env" ] && source "$HOME/.secrets/env"
