#!/usr/bin/env zsh
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"

echo "==> Using dotfiles at $DOTFILES_DIR"

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
else
  echo "==> Homebrew already installed."
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 3. Rosetta 2 (Apple Silicon only)
if [[ "$(uname -m)" == "arm64" ]]; then
  if ! /usr/bin/pgrep -q oahd; then
    echo "==> Installing Rosetta 2..."
    softwareupdate --install-rosetta --agree-to-license
  else
    echo "==> Rosetta 2 already installed."
  fi
fi

# 4. Symlink config files
link_file() {
  local src="$DOTFILES_DIR/$1"
  local dest="$2"

  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "==> $2 already symlinked."
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ -e "$dest" ]]; then
    echo "==> Backing up existing $dest to $dest.bak"
    mv "$dest" "$dest.bak"
  fi

  echo "==> Symlinking $dest"
  ln -s "$src" "$dest"
}

# Shell + git
link_file ".zshrc" "$HOME/.zshrc"
link_file ".gitconfig" "$HOME/.gitconfig"
link_file ".gitignore_global" "$HOME/.gitignore_global"

# Coding agents
link_file "agents/claude/settings.json" "$HOME/.claude/settings.json"
link_file "agents/claude/mcp.json" "$HOME/.claude/mcp.json"
link_file "agents/codex/config.toml" "$HOME/.codex/config.toml"
link_file "agents/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
link_file "agents/conductor/settings.toml" "$HOME/.conductor/settings.toml"

# Editors
link_file "editors/cursor/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
link_file "editors/cursor/keybindings.json" "$HOME/Library/Application Support/Cursor/User/keybindings.json"
link_file "editors/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
link_file "editors/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"

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
fi
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  echo "==> Creating stub ~/.gitconfig.local"
  cat > "$HOME/.gitconfig.local" <<'STUB'
# Machine-local git config — included by ~/.gitconfig, NOT tracked in git.
# gh writes its credential helper blocks here (run: gh auth setup-git).
STUB
fi

# 6. oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "==> Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "==> oh-my-zsh already installed."
fi

# 7. Homebrew packages
echo "==> Trusting third-party taps..."
brew trust --tap tidbyt/tidbyt >/dev/null 2>&1 || true
echo "==> Running brew bundle..."
cd "$DOTFILES_DIR"
brew bundle

# 8. nvm + Node
if [[ ! -d "$HOME/.nvm" ]]; then
  echo "==> Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
if command -v nvm >/dev/null 2>&1; then
  echo "==> Installing latest Node via nvm..."
  nvm install node
fi

# 9. Global npm CLIs
if command -v npm >/dev/null 2>&1; then
  echo "==> Installing global npm CLIs..."
  npm install -g @github/copilot @railway/cli @stripe/cli vercel
fi

# 10. Agent skills (managed by the `skills` CLI; lock file is the source of truth)
if [[ ! -f "$HOME/.agents/.skill-lock.json" ]]; then
  echo "==> Seeding ~/.agents/.skill-lock.json from repo"
  mkdir -p "$HOME/.agents"
  cp "$DOTFILES_DIR/agents/skill-lock.json" "$HOME/.agents/.skill-lock.json"
fi
if command -v npx >/dev/null 2>&1; then
  echo "==> Restoring agent skills from lock file..."
  npx -y skills@latest update -g -y || echo "    (skills restore failed; re-run 'npx skills update -g -y' later)"
fi

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
  8. Optionally run ./macos.sh for macOS defaults

See README.md for details on each step.
EOF
