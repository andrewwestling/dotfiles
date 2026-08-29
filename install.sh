#!/usr/bin/env zsh
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"

echo "==> Using dotfiles at $DOTFILES_DIR"

# This script is idempotent AND reconciling: re-running it on an already
# provisioned machine pulls in anything new (Brewfile entries, Cursor
# extensions, refreshed skill lock) and repairs symlinks that an app has
# replaced with a real file. It ends with a summary of what it changed,
# skipped, and backed up.

CHANGED=()    # things this run created or repaired
SKIPPED=()    # things already in the desired state, or deliberately left alone
BACKED_UP=()  # pre-existing files moved aside to *.bak
WARNINGS=()   # things that need a human

# Ask for the sudo password once up front and keep it alive until the script
# exits, so brew's cask/mas steps don't each prompt for it.
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done &

# 1. Xcode Command Line Tools
if ! xcode-select -p >/dev/null 2>&1; then
  echo "==> Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "    Finish the Command Line Tools install, then re-run this script."
  exit 1
else
  echo "==> Xcode Command Line Tools already installed."
fi

# 2. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  CHANGED+=("Installed Homebrew")
else
  echo "==> Homebrew already installed."
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 3. Rosetta 2 (Apple Silicon only)
if [[ "$(uname -m)" == "arm64" ]]; then
  if ! /usr/bin/pgrep -q oahd; then
    echo "==> Installing Rosetta 2..."
    softwareupdate --install-rosetta --agree-to-license
    CHANGED+=("Installed Rosetta 2")
  else
    echo "==> Rosetta 2 already installed."
  fi
fi

# 4. Symlink config files
#
# link_file: point $dest at $DOTFILES_DIR/$1. If $dest is already the right
# symlink, do nothing. If it's a real file or a stale symlink (e.g. an app
# overwrote our link with its own copy), back it up to $dest.bak and relink.
link_file() {
  local src="$DOTFILES_DIR/$1"
  local dest="$2"

  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "==> $dest already symlinked."
    SKIPPED+=("symlink $dest")
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ -e "$dest" || -L "$dest" ]]; then
    echo "==> Backing up existing $dest to $dest.bak"
    rm -f "$dest.bak"
    mv "$dest" "$dest.bak"
    BACKED_UP+=("$dest -> $dest.bak")
  fi

  echo "==> Symlinking $dest"
  ln -s "$src" "$dest"
  CHANGED+=("symlinked $dest")
}

# copy_if_absent: for config the owning app rewrites in place (so a symlink
# would fight it or get clobbered). Install our baseline only when there's no
# real file yet. If a *symlink into this repo* is found (from an older version
# of this script), convert it to a real copy so the app can manage it.
copy_if_absent() {
  local src="$DOTFILES_DIR/$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "==> $dest was a symlink into the repo; converting to a real copy."
    rm "$dest"
    cp "$src" "$dest"
    CHANGED+=("un-symlinked $dest (now a managed real file, baseline copied)")
    return
  fi

  if [[ -e "$dest" ]]; then
    echo "==> $dest already exists; leaving the machine's own copy untouched."
    SKIPPED+=("$dest (app-managed; baseline not copied)")
    return
  fi

  echo "==> Copying baseline $dest"
  cp "$src" "$dest"
  CHANGED+=("copied baseline $dest")
}

# Shell + git
link_file ".zshenv" "$HOME/.zshenv"
link_file ".zshrc" "$HOME/.zshrc"
link_file ".gitconfig" "$HOME/.gitconfig"
link_file ".gitignore_global" "$HOME/.gitignore_global"

# Coding agents
link_file "agents/claude/settings.json" "$HOME/.claude/settings.json"
link_file "agents/claude/mcp.json" "$HOME/.claude/mcp.json"
link_file "agents/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link_file "agents/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
link_file "agents/conductor/settings.toml" "$HOME/.conductor/settings.toml"
# Codex rewrites config.toml constantly (project trust, generated MCP servers,
# app paths); track only a baseline and let Codex own the live file.
copy_if_absent "agents/codex/config.toml" "$HOME/.codex/config.toml"

# Editors
link_file "editors/cursor/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
link_file "editors/cursor/keybindings.json" "$HOME/Library/Application Support/Cursor/User/keybindings.json"
link_file "editors/cursor/mcp.json" "$HOME/.cursor/mcp.json"
link_file "editors/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
link_file "editors/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"

# GitHub CLI (non-secret config only; auth/hosts.yml stay out of git)
link_file "config/gh/config.yml" "$HOME/.config/gh/config.yml"

# 5. Machine-local stubs (secrets + per-machine config live here, never in git)
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  echo "==> Creating stub ~/.zshrc.local"
  cat > "$HOME/.zshrc.local" <<'STUB'
# Machine-local secrets and config — sourced by ~/.zshrc, NOT tracked in git.
# Expected keys:
#   export CURSOR_API_KEY="..."
#   export OBSIDIAN_API_KEY="..."   # used by the obsidian MCP server
# Plus any machine-specific aliases (e.g. gam).
STUB
  CHANGED+=("created stub ~/.zshrc.local")
fi
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  echo "==> Creating stub ~/.gitconfig.local"
  cat > "$HOME/.gitconfig.local" <<'STUB'
# Machine-local git config — included by ~/.gitconfig, NOT tracked in git.
# gh writes its credential helper blocks here (run: gh auth setup-git).
STUB
  CHANGED+=("created stub ~/.gitconfig.local")
fi

# 6. oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "==> Installing oh-my-zsh..."
  # KEEP_ZSHRC=yes stops the installer from backing up and replacing our
  # already-symlinked ~/.zshrc with its stock template.
  KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  CHANGED+=("installed oh-my-zsh")
else
  echo "==> oh-my-zsh already installed."
fi

# 7. Homebrew packages
echo "==> Trusting third-party taps..."
brew trust --tap tidbyt/tidbyt >/dev/null 2>&1 || true
echo "==> Running brew bundle..."
cd "$DOTFILES_DIR"
brew bundle
CHANGED+=("ran brew bundle (installs any new Brewfile entries)")

# Report — but never act on — installed packages that are no longer in the
# Brewfile. Removal is deliberate and manual: `brew bundle cleanup --force`.
echo "==> Checking for packages not in the Brewfile (report only)..."
CLEANUP_OUT="$(brew bundle cleanup --file="$DOTFILES_DIR/Brewfile" 2>/dev/null || true)"
if [[ -n "$CLEANUP_OUT" ]]; then
  echo "$CLEANUP_OUT"
  WARNINGS+=("Packages installed but not in the Brewfile (see 'brew bundle cleanup' output above). Run 'brew bundle cleanup --force' to remove, or add them to the Brewfile.")
fi

# 8. nvm + Node
if [[ ! -d "$HOME/.nvm" ]]; then
  echo "==> Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  CHANGED+=("installed nvm")
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
if command -v nvm >/dev/null 2>&1; then
  echo "==> Installing latest Node via nvm..."
  nvm install node
  nvm alias default node
fi

# 9. Global npm CLIs (vercel only; railway + stripe come from steps 10 / brew)
if command -v npm >/dev/null 2>&1; then
  echo "==> Installing global npm CLIs..."
  npm install -g vercel
fi

# 10. Railway CLI (standalone installer — not npm, not brew)
if ! command -v railway >/dev/null 2>&1 && [[ ! -x "$HOME/.railway/bin/railway" ]]; then
  echo "==> Installing Railway CLI..."
  curl -fsSL https://railway.com/install.sh | sh && CHANGED+=("installed Railway CLI") \
    || WARNINGS+=("Railway CLI install failed; re-run: curl -fsSL https://railway.com/install.sh | sh")
else
  echo "==> Railway CLI already installed."
fi

# 11. Cursor extensions (brew bundle handles VS Code extensions, not Cursor's)
if command -v cursor >/dev/null 2>&1; then
  echo "==> Installing Cursor extensions..."
  for ext in anysphere.remote-containers anysphere.remote-ssh; do
    cursor --install-extension "$ext" >/dev/null 2>&1 \
      && echo "    $ext" \
      || WARNINGS+=("Failed to install Cursor extension: $ext")
  done
else
  WARNINGS+=("'cursor' CLI not on PATH; skipped Cursor extension install (Cursor > Shell Command: Install 'cursor' command)")
fi

# 12. Agent skills. The repo lock file is the source of truth: overwrite the
# local one every run so a fresh clone's skill set wins, then let the skills
# CLI reconcile what's on disk.
mkdir -p "$HOME/.agents"
LOCAL_LOCK="$HOME/.agents/.skill-lock.json"
REPO_LOCK="$DOTFILES_DIR/agents/skill-lock.json"
if [[ -f "$LOCAL_LOCK" ]] && ! diff -q "$REPO_LOCK" "$LOCAL_LOCK" >/dev/null 2>&1; then
  echo "==> Updating ~/.agents/.skill-lock.json from repo. Skill changes:"
  /usr/bin/python3 - "$REPO_LOCK" "$LOCAL_LOCK" <<'PY' || true
import json, sys
def names(p):
    d = json.load(open(p)); s = d.get("skills", d)
    return set(s.keys()) if isinstance(s, dict) else {x.get("name", str(x)) for x in s}
repo, local = names(sys.argv[1]), names(sys.argv[2])
for n in sorted(repo - local): print(f"    + {n}")
for n in sorted(local - repo): print(f"    - {n}")
PY
  cp "$REPO_LOCK" "$LOCAL_LOCK"
  CHANGED+=("refreshed ~/.agents/.skill-lock.json from repo")
elif [[ ! -f "$LOCAL_LOCK" ]]; then
  echo "==> Seeding ~/.agents/.skill-lock.json from repo"
  cp "$REPO_LOCK" "$LOCAL_LOCK"
  CHANGED+=("seeded ~/.agents/.skill-lock.json")
fi
if command -v npx >/dev/null 2>&1; then
  echo "==> Restoring agent skills from lock file..."
  npx -y skills@latest update -g -y || WARNINGS+=("skills restore failed; re-run 'npx skills update -g -y'")
fi

# --- Summary -----------------------------------------------------------------
echo
echo "==================== install.sh summary ===================="
print_list() {
  # $1 = title, $2 = name of an array variable
  local title="$1" arr="$2"
  local -a items=("${(@P)arr}")
  (( ${#items[@]} )) || return 0
  echo "$title"
  local item
  for item in "${items[@]}"; do echo "  - $item"; done
}
print_list "Changed:"               CHANGED
print_list "Skipped (already set):" SKIPPED
print_list "Backed up:"             BACKED_UP
print_list "Needs attention:"       WARNINGS
(( ${#CHANGED[@]} + ${#BACKED_UP[@]} + ${#WARNINGS[@]} )) \
  || echo "Nothing to do — machine already matches the repo."
echo "==========================================================="

cat <<'EOF'

==> Automated setup done. Remaining manual steps:

  1. Set computer name (System Preferences > Sharing)
  2. Set up 1Password (mobile app camera/phone setup, Yubikey for MFA)
  3. Sign into iCloud
  4. Sign into Fastmail (App Password + profile install)
  5. Re-run `brew bundle` from this repo to install Mac App Store apps
     (needs iCloud sign-in first for `mas` to work)
  6. Set up the 1Password SSH Agent (1Password > Settings > Developer)
  7. Fill in ~/.zshrc.local (API keys) and run `gh auth login` + `gh auth setup-git`
  8. Work through macos-checklist.md (system settings + Spotlight)

See README.md for details on each step.
EOF
