# dotfiles

These are my configuration files and notes for setting up a new Mac.

Do the following, in this order:

1. [Clone this repo and run install.sh](#clone-this-repo-and-run-installsh)
1. [Set computer name](#computer-name)
1. [Set up 1Password](#1password)
1. [Sign into iCloud](#icloud)
1. [Sign into Fastmail](#fastmail)
1. [Install Mac App Store apps](#mac-app-store)
1. [Set up SSH](#ssh)

## Clone this repo and run install.sh

Run git once so macOS will try to install command line tools:

```zsh
git
```

Make directory and clone

```zsh
mkdir ~/Code && git clone https://github.com/andrewwestling/dotfiles ~/Code/dotfiles
```

Run the install script:

```zsh
cd ~/Code/dotfiles && ./install.sh
```

This installs Homebrew (if needed) and Rosetta 2 (on Apple Silicon), then:

- Symlinks `.zshrc`/`.gitconfig`/`.gitignore_global` into `~`
- Symlinks coding agent configs from [`agents/`](agents/): Claude Code (`~/.claude/settings.json`, `~/.claude/mcp.json`), Codex (`~/.codex/config.toml`, `AGENTS.md`), Conductor (`~/.conductor/settings.toml`)
- Symlinks editor configs from [`editors/`](editors/): Cursor and VS Code `settings.json`/`keybindings.json`
- Creates stub `~/.zshrc.local` and `~/.gitconfig.local` for machine-local secrets (see below)
- Installs oh-my-zsh, runs `brew bundle` (trusting the `tidbyt/tidbyt` tap first), sets up nvm + Node
- Installs global npm CLIs (copilot, railway, stripe, vercel)
- Restores agent skills from [`agents/skill-lock.json`](agents/skill-lock.json) via the [`skills` CLI](https://github.com/vercel-labs/skills) (`npx skills update -g -y`)

It's safe to re-run; it skips anything already installed/linked, and backs up (rather than overwrites) any pre-existing dotfiles it would otherwise clobber.

Mac App Store apps (`mas` entries in the Brewfile) won't install yet, that needs iCloud sign-in first, so `brew bundle` gets re-run later in the [Mac App Store](#mac-app-store) step below.

### Secrets

Secrets and machine-specific bits never go in this repo:

- `~/.zshrc.local` — sourced by `.zshrc`; holds `CURSOR_API_KEY`, `OBSIDIAN_API_KEY` (used by the obsidian MCP server via `${VAR}` expansion in `agents/claude/mcp.json`), and machine-specific aliases
- `~/.gitconfig.local` — included by `.gitconfig`; gh writes its credential helpers here (`gh auth login` then `gh auth setup-git`)

### Brewfile

<details>
<summary>Details for updating Brewfile</summary>

The Brewfile is hand-curated (top-level packages only, no transitive deps). When I install/uninstall something, I add or remove the line by hand and commit.

Avoid `brew bundle dump -f` — it overwrites the curated file with every installed formula (including dependency noise) and clobbers the vscode section.

To find installed things that aren't in the Brewfile yet: `brew leaves` (formulas) and `brew list --cask`.

</details>

## Computer Name

Set the computer name from System Preferences > Sharing.

## 1Password

Set up using the camera/phone thing via mobile app. Use Yubikey for MFA.

## iCloud

Sign into iCloud now that 1Password is set up. Use discretion for which "Apps using iCloud" to enable, but ensure the following are enabled:

- Photos
- iCloud Drive
- iCloud Mail
- Passwords & Keychain
- Messages in iCloud
- Find My Mac
- Reminders
- Safari
- Phone & FaceTime
- Raycast

Set up a symlink for iCloud Drive at `~/iCloud`:

```zsh
ln -s ~/Library/Mobile\ Documents/com\~apple\~CloudDocs ~/iCloud
```

## Fastmail

Create a new App Password for Fastmail at [Settings > Password & Security > Third Party Apps > App Passwords > New App Password](https://www.fastmail.com/settings/security/devicekeys/new).

Once it's created, download the profile with the link it provides, and open System Preferences > Profile and install it.

## Mac App Store

After setting up 1Password and iCloud above, run the Homebrew install step again to install Mac App Store apps.

```zsh
cd ~/Code/dotfiles && brew bundle # The `mas` steps should complete now that we're signed into iCloud
```

## SSH

Enable the 1Password [SSH Agent](https://developer.1password.com/docs/ssh/agent/):

- Open the 1Password app and choose **1Password > Settings** from the menu bar, then select **Developer**.
- Select **Set Up SSH Agent**
