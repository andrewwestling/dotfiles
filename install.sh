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

# 4. Symlink dotfiles into $HOME
link_dotfile() {
  local src="$DOTFILES_DIR/$1"
  local dest="$HOME/$1"

  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "==> $1 already symlinked."
    return
  fi

  if [[ -e "$dest" ]]; then
    echo "==> Backing up existing $1 to $1.bak"
    mv "$dest" "$dest.bak"
  fi

  echo "==> Symlinking $1"
  ln -s "$src" "$dest"
}

link_dotfile ".zshrc"
link_dotfile ".gitconfig"
link_dotfile ".gitignore_global"

# 5. oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "==> Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "==> oh-my-zsh already installed."
fi

# 6. Homebrew packages
echo "==> Running brew bundle..."
cd "$DOTFILES_DIR"
brew bundle

# 7. nvm + Node
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

cat <<'EOF'

==> Automated setup done. Remaining manual steps:

  1. Set computer name (System Preferences > Sharing)
  2. Set up 1Password (mobile app camera/phone setup, Yubikey for MFA)
  3. Sign into iCloud
  4. Sign into Fastmail (App Password + profile install)
  5. Re-run `brew bundle` from this repo to install Mac App Store apps
     (needs iCloud sign-in first for `mas` to work)
  6. Set up the 1Password SSH Agent (1Password > Settings > Developer)

See README.md for details on each step.
EOF
