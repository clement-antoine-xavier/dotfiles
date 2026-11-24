# dotfiles

My macOS shell environment: **Zsh** with **Oh My Zsh**, the four [zsh-users](https://github.com/zsh-users)
plugins, the `agnoster` prompt, and a handful of modern CLI replacements.

Tested on macOS 26 (Darwin 25, arm64) · zsh 5.9 · Homebrew 7.0.16.

---

## Stack

| Layer | Choice | Notes |
|---|---|---|
| Shell | zsh 5.9 | ships with macOS, no upgrade needed |
| Framework | [Oh My Zsh](https://ohmyz.sh) | plugin/theme loader, `~/.oh-my-zsh` |
| Prompt | `agnoster` | powerline segments; needs a Nerd Font |
| Font | Meslo LG Nerd Font Mono | installed via cask |
| History search | `zsh-history-substring-search` | prefix match on `↑`/`↓` |
| Suggestions | `zsh-autosuggestions` | fish-style inline ghost text |
| Highlighting | `zsh-syntax-highlighting` | green = valid, red = invalid |
| File finding | `fzf` 0.75 | `Ctrl-R`, `Ctrl-T`, `Alt-C` |
| Directory jump | `zoxide` 0.10 | `z`, `zi` |
| `ls` | `eza` 0.23 | icons, git status column |
| `cat` | `bat` 0.26 | syntax highlighting, no pager |

---

## Layout

```
dotfiles/
├── .zshrc        # everything the interactive shell loads
├── .zprofile     # login-shell env: Homebrew, secrets
├── Brewfile      # brew bundle manifest
├── install.sh    # idempotent bootstrap for a new machine
├── .gitignore
└── README.md
```

`.zshrc` and `.zprofile` are **symlinked** into `$HOME`, so this repo is the
single source of truth — editing `~/.zshrc` edits `dotfiles/.zshrc`.

---

## Install

### Fresh machine

```bash
git clone https://github.com/clement-antoine-xavier/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script installs the Brewfile packages, Oh My Zsh, the four plugins, fzf
bindings, then backs up and symlinks `.zshrc` / `.zprofile`.

### Existing machine (manual)

If you only want the shell config and already have the dependencies:

```bash
brew bundle --file=~/dotfiles/Brewfile
RUNZSH=no CHSH=no KEEP_ZSHRC=no \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

for p in zsh-autosuggestions zsh-syntax-highlighting \
         zsh-completions zsh-history-substring-search; do
  git clone --depth=1 "https://github.com/zsh-users/$p" \
    ~/.oh-my-zsh/custom/plugins/$p
done

ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.zprofile ~/.zprofile
exec zsh
```

### After installing — one manual step

Terminal → **Settings** → **Profiles** → **Text** → **Font** → *Change…* →
**MesloLGM NerdFont Mono**, size ~13. Without it, agnoster's powerline glyphs
render as `?` or boxes.

---

## What `.zshrc` does, in order

1. **`fpath` for `zsh-completions`** — must happen *before* `compinit`, which
   Oh My Zsh runs internally when `oh-my-zsh.sh` is sourced. Getting this wrong
   silently drops ~2 000 extra completions.
2. **Theme + display options** — `ZSH_THEME="agnoster"`, `DEFAULT_USER="$USER"`
   so the prompt collapses to just a chevron locally, plus case/hyphen
   insensitive completion and correction.
3. **History** — 50 000 entries, shared across sessions (`SHARE_HISTORY`),
   no duplicates, timestamps, no commands starting with a space.
4. **Plugins** — see the table below. `zsh-syntax-highlighting` is **last**;
   it wraps every widget and must see the final keymap.
5. **`history-substring-search` bindings** — both normal and application cursor
   mode sequences (`^[[A` / `^[OA`), so it works in every terminal.
6. **`zoxide init`** — provides `z`/`zi`.
7. **`fzf --zsh`** — guarded by `[[ -t 0 ]]` because fzf prints
   `can't change option: zle` when sourced in a TTY-less interactive shell.
8. **Aliases and `$EDITOR`**.

### Shell options

| Option | Effect |
|---|---|
| `HIST_IGNORE_ALL_DUPS` | keeps the newest copy of a repeated command |
| `HIST_IGNORE_SPACE` | commands starting with a space are never recorded |
| `SHARE_HISTORY` | history is immediately visible in all open shells |
| `INC_APPEND_HISTORY` | appends as you go instead of on exit |

---

## Plugins

| Plugin | Source | What it gives you |
|---|---|---|
| `git` | Oh My Zsh | 200+ aliases (`gs`, `gco`, `gd`, `glog`) + branch in prompt |
| `brew` | Oh My Zsh | `brew` completions kept in sync with installed taps |
| `macos` | Oh My Zsh | `cdf`, `ofd`, `pfd`, `showfiles`, `hidden`, `flushdns` |
| `extract` | Oh My Zsh | `x archive.tar.gz` for ~20 archive formats |
| `sudo` | Oh My Zsh | double-tap `Esc` to prepend `sudo` to the buffer |
| `colored-man-pages` | Oh My Zsh | colourised `man` output |
| `command-not-found` | Oh My Zsh | suggests a `brew install` for missing commands |
| `docker` | Oh My Zsh | container/image completions |
| `kubectl` | Oh My Zsh | `k` alias + completions |
| `gh` | Oh My Zsh | GitHub CLI completions |
| `nvm` | Oh My Zsh | **lazy-loads** nvm — first `nvm`/`node`/`npm` call pays the cost |
| `zsh-completions` | zsh-users | extra completion definitions |
| `zsh-autosuggestions` | zsh-users | inline suggestion from history; `→` to accept |
| `zsh-history-substring-search` | zsh-users | `↑`/`↓` search on the *substring* typed so far |
| `zsh-syntax-highlighting` | zsh-users | live command validity colouring |

### Design decisions

- **`zoxide` instead of OMZ's `z` plugin.** Both define `z`; zoxide is faster and
  adds `zi` for interactive selection. OMZ's `z` is intentionally *not* enabled.
- **`nvm` moved out of `.zprofile`** into OMZ's lazy plugin. Sourcing `nvm.sh`
  eagerly added ~1 s to every shell.
- **`fzf --zsh` instead of `~/.fzf.zsh`.** Always matches the installed fzf
  version and needs no generated file.
- **`cat` is aliased only interactively** — aliases never affect scripts or
  pipes, so nothing breaks.

---

## Key bindings

| Keys | Action |
|---|---|
| `↑` / `↓` | history search matching what you've typed (`history-substring-search`) |
| `^P` / `^N` | same as above (emacs style) |
| `→` (end of line) | accept autosuggestion |
| `Ctrl-R` | fuzzy history search (fzf) |
| `Ctrl-T` | fuzzy file picker, inserted into the buffer (fzf) |
| `Alt-C` | fuzzy `cd` (fzf) |
| `Esc` `Esc` | prepend `sudo` to the current command |
| `Tab` | completion (`COMPLETION_WAITING_DOTS` shows dots while loading) |

---

## Aliases

| Alias | Expands to |
|---|---|
| `ls` | `eza --group-directories-first --icons` |
| `ll` | `eza -lh --git --icons` |
| `la` | `eza -lah --git --icons` |
| `lt` | `eza --tree --level=2 --icons` |
| `cat` | `bat --paging=never` |
| `..` / `...` | `cd ..` / `cd ../..` |
| `reload` | `source ~/.zshrc` |
| `zshconf` | `$EDITOR ~/.zshrc` |

Plus everything from the `git` plugin, e.g. `gs`, `ga`, `gcmsg`, `gco`, `gcb`,
`gd`, `gl`, `glog`, `grhh`.

---

## Secrets

Nothing sensitive is committed. `.zprofile` sources a local file if present:

```zsh
[ -f "$HOME/.secrets/env" ] && source "$HOME/.secrets/env"
```

```bash
mkdir -p ~/.secrets && chmod 700 ~/.secrets
echo 'export DEEPSEEK_API_KEY="sk-..."' > ~/.secrets/env
chmod 600 ~/.secrets/env
```

`.secrets/`, `.env` and `*.local` are git-ignored.

---

## Maintenance

```bash
# Oh My Zsh + plugins (they're plain git checkouts)
omz update
for d in ~/.oh-my-zsh/custom/plugins/*/; do git -C "$d" pull --ff-only; done

# Packages
brew bundle --file=~/dotfiles/Brewfile   # install missing
brew upgrade                             # update installed
brew bundle dump --file=~/dotfiles/Brewfile --force   # re-snapshot

# This repo
cd ~/dotfiles && git add -A && git commit -m "..." && git push
```

Oh My Zsh self-updates every 13 days unless `DISABLE_AUTO_UPDATE="true"` is set.

---

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| Prompt shows `?` or ▯ boxes | Nerd Font not selected in Terminal settings |
| `can't change option: zle` | fzf sourced without a TTY — already guarded with `[[ -t 0 ]]` |
| Slow first prompt | `compdump` rebuild after a plugin change; it's cached in `~/.zcompdump` |
| `zsh: command not found: brew` | `brew shellenv` missing from `.zprofile` |
| `compdef: command not found` | `compinit` ran before the plugin `fpath` line |
| Completions missing after install | run `rm -f ~/.zcompdump && exec zsh` |

Measure startup cost:

```bash
for i in 1 2 3; do /usr/bin/time -p zsh -i -c exit; done
```

---

## Rollback

```bash
rm ~/.zshrc ~/.zprofile          # symlinks only, repo untouched
mv ~/.zshrc.bak ~/.zshrc         # if the installer backed one up
rm -rf ~/.oh-my-zsh
```
