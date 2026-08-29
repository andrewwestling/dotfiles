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
1. [Apply macOS system settings](#macos-system-settings)

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

- Symlinks `.zshenv`/`.zshrc`/`.gitconfig`/`.gitignore_global` into `~`
- Symlinks coding agent configs from [`agents/`](agents/): Claude Code (`~/.claude/settings.json`, `~/.claude/mcp.json`, `~/.claude/CLAUDE.md`), Codex `AGENTS.md`, Conductor (`~/.conductor/settings.toml`)
- Copies a **baseline** `~/.codex/config.toml` only if none exists — Codex rewrites that file constantly (project trust, generated MCP servers, app paths), so it's not symlinked and the repo copy is a hand-curated starting point, not a mirror
- Symlinks editor configs from [`editors/`](editors/): Cursor + VS Code `settings.json`/`keybindings.json`, and Cursor's `~/.cursor/mcp.json`
- Symlinks `~/.config/gh/config.yml` (gh CLI aliases/prefs; `hosts.yml` and auth stay out of git)
- Creates stub `~/.zshrc.local` and `~/.gitconfig.local` for machine-local secrets (see below)
- Installs oh-my-zsh, runs `brew bundle` (trusting the `tidbyt/tidbyt` tap first), sets up nvm + Node
- Installs `vercel` globally via npm; installs the **Railway CLI** via its standalone script (`curl -fsSL https://railway.com/install.sh | sh`). The Stripe CLI comes from the `stripe/stripe-cli/stripe` brew formula
- Installs Cursor extensions (`anysphere.remote-containers`, `anysphere.remote-ssh`) — `brew bundle` only covers VS Code extensions
- Restores agent skills from [`agents/skill-lock.json`](agents/skill-lock.json) via the [`skills` CLI](https://github.com/vercel-labs/skills) (`npx skills update -g -y`)

### Re-running to update an existing machine

`./install.sh` is idempotent **and reconciling** — re-run it any time to pull the
latest repo state onto a machine that's already set up:

- New `Brewfile` entries get installed (`brew bundle` runs every time). Packages
  that are installed but *no longer* in the Brewfile are only **reported**, never
  removed — run `brew bundle cleanup --force` yourself if you want them gone.
- Symlinks that an app has replaced with its own real file are backed up to
  `*.bak` and re-linked.
- `~/.agents/.skill-lock.json` is overwritten from the repo copy (the repo is the
  source of truth), printing the added/removed skills, before `skills update`.
- New Cursor extensions are installed.
- The run ends with a **summary** of what it changed, skipped, backed up, and
  what needs a human.

Pre-existing dotfiles it would clobber are backed up (`*.bak`), never overwritten.

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

To find installed things that aren't in the Brewfile yet: `brew leaves` (formulas) and `brew list --cask`. `install.sh` also prints a `brew bundle cleanup` report of installed-but-untracked packages on every run.

If `brew leaves` shows orphaned dependencies you don't want (packages nothing depends on anymore), clear them with `brew autoremove`.

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

## macOS system settings

Work through [`macos-checklist.md`](macos-checklist.md) — a click-through list of
the System Settings I change on a fresh Mac (Dock, keyboard repeat, text
substitutions, trackpad, Finder), plus **Spotlight search results**, which are
captured as a plist ([`macos/com.apple.Spotlight.plist`](macos/com.apple.Spotlight.plist))
and applied with `defaults import`.

There's deliberately no settings script — a previous `macos.sh` was removed
because scripted `defaults write` values didn't reliably apply.
