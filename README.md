# dotfiles

These are my configuration files and notes for setting up a new Mac.

## What it does

Installs apps and command-line tools, links shell and editor settings, restores coding agent configurations, and provides a checklist for finishing macOS setup.

## Who it's for

This is a personal Mac setup, useful as a reference for anyone maintaining their own dotfiles. Review the settings and app list before using it on another machine.

## Links

- [Installation and setup](#clone-this-repo-and-run-installsh)
- [macOS settings checklist](macos-checklist.md)
- [Issue tracker workflow](docs/issue-tracker.md)

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

Always run it from the main checkout. It refuses to run from a git worktree (Orca, Conductor, `git worktree add`), because the symlinks it creates point at the directory it runs from and would break once the worktree is deleted.

This installs Homebrew (if needed) and Rosetta 2 (on Apple Silicon), then:

- Symlinks `.zshenv`/`.zshrc`/`.gitconfig`/`.gitignore_global` into `~`
- Symlinks coding agent configs from [`agents/`](agents/): Claude Code (`~/.claude/settings.json`, `~/.claude/mcp.json`, `~/.claude/CLAUDE.md`), Codex `AGENTS.md`
- Keeps private and machine-generated parts of `~/.claude/settings.json` out of git: `autoMode.environment` (private org details; Claude only reads `autoMode` from this file) and Orca's hooks + status line (Orca rewrites them on every launch). A clean/smudge filter ([`agents/claude/settings-filter.sh`](agents/claude/settings-filter.sh)) strips them on commit and restores them on checkout from `~/.claude/settings.private.json`, which lives only on the machine. Copy that file to a new machine yourself
- Copies a **baseline** `~/.codex/config.toml` only if none exists — Codex rewrites that file constantly (project trust, generated MCP servers, app paths), so it's not symlinked and the repo copy is a hand-curated starting point, not a mirror
- Symlinks editor configs from [`editors/`](editors/): Cursor + VS Code `settings.json`/`keybindings.json`, and Cursor's `~/.cursor/mcp.json`
- Symlinks `~/.config/gh/config.yml` (gh CLI aliases/prefs; `hosts.yml` and auth stay out of git)
- Creates stub `~/.zshrc.local` and `~/.gitconfig.local` for machine-local secrets (see below)
- Installs oh-my-zsh, runs `brew bundle` (trusting the `tidbyt/tidbyt` and `stablyai/orca` taps first, and adopting a DMG-installed Orca.app), sets up nvm + Node
- Installs `vercel` globally via npm; installs the **Railway CLI** via its standalone script (`curl -fsSL https://railway.com/install.sh | sh`). The Stripe CLI comes from the `stripe/stripe-cli/stripe` brew formula
- Installs Cursor extensions (`anysphere.remote-containers`, `anysphere.remote-ssh`) — `brew bundle` only covers VS Code extensions
- Copies a **baseline** `~/.agents/.skill-lock.json` from [`agents/skill-lock.json`](agents/skill-lock.json) only if none exists, then restores agent skills via the [`skills` CLI](https://github.com/vercel-labs/skills) (`npx skills update -g -y`). The CLI rewrites the local lock, so the repo copy is a fresh-machine starting point, not a mirror. To refresh it, copy the local lock over it and commit
- Adds a Factory skills `SessionStart` check to Claude Code and merges the same hook into Codex without replacing existing hooks. Codex needs one-time `/hooks` trust for `check-skills.ts`
- Installs [Ponytail](https://github.com/DietrichGebert/ponytail) as a plugin in Claude Code, Codex, Copilot CLI, and OpenCode, and as hooks in Cursor (checkout at `~/.local/share/ponytail`). It's a plugin rather than a lock-file skill because its hooks keep it on every session. Codex needs a one-time `/hooks` trust per machine

### Re-running to update an existing machine

`./install.sh` is idempotent **and reconciling** — re-run it any time to pull the
latest repo state onto a machine that's already set up:

- New `Brewfile` entries get installed (`brew bundle` runs every time). Packages
  that are installed but *no longer* in the Brewfile are only **reported**, never
  removed — run `brew bundle cleanup --force` yourself if you want them gone.
- Symlinks that an app has replaced with its own real file are backed up to
  `*.bak` and re-linked.
- An existing `~/.agents/.skill-lock.json` is left alone, and `skills update`
  brings the installed skills up to date from it.
- New Cursor extensions are installed.
- The run ends with a **summary** of what it changed, skipped, backed up, and
  what needs a human.

Pre-existing dotfiles it would clobber are backed up (`*.bak`), never overwritten.

Mac App Store apps (`mas` entries in the Brewfile) won't install yet, that needs iCloud sign-in first, so `brew bundle` gets re-run later in the [Mac App Store](#mac-app-store) step below.

### What each agent loads

Sessions launched by Orca load the same files as the same agent launched by hand. The table below is the local machine; a Cursor Cloud agent runs on Cursor's machines, so it doesn't read any of these files.

| Source | Claude Code | Codex | Cursor |
| --- | --- | --- | --- |
| **Lock-installed skills** | `~/.claude/skills`, symlinks into `~/.agents/skills` | `~/.agents/skills` | `~/.agents/skills` |
| **Orca-written skills** | Same symlinks | `~/.agents/skills` | `~/.agents/skills` |
| **Plugins** | Ponytail (`install.sh`), plus `mattpocock-skills`, `linear` and `neon-postgres` installed by hand | Ponytail (`install.sh`), `mattpocock-skills`, and the OpenAI plugins in `~/.codex/config.toml` | Cursor marketplace plugins in `~/.cursor/plugins` (Ponytail is hooks here, not a plugin) |
| **Built-in skills** | None on disk | `~/.codex/skills/.system` | `~/.cursor/skills-cursor` |
| **Global instructions** | `~/.claude/CLAUDE.md`, symlinked from [`agents/claude/CLAUDE.md`](agents/claude/CLAUDE.md) | `~/.codex/AGENTS.md`, symlinked from [`agents/codex/AGENTS.md`](agents/codex/AGENTS.md) | User Rules in Cursor's settings, not tracked here |
| **Repo instructions** | `CLAUDE.md` | `AGENTS.md` | `AGENTS.md`, `.cursor/rules` |
| **Repo hooks** | `.claude/settings.json` | `.codex/hooks.json`, once the project is trusted | `.cursor/hooks.json` |
| **Global hooks** | `~/.claude/settings.json`: tracked Factory skills check and Orca's hooks (filtered out of git); Ponytail's come from its plugin | `~/.codex/hooks.json`: Factory skills check plus Orca's, not tracked here; Ponytail's come from its plugin. New hooks need `/hooks` trust | `~/.cursor/hooks.json`: Ponytail's and Orca's, not tracked here |

- **Lock-installed skills:** everything in [`agents/skill-lock.json`](agents/skill-lock.json), including the `do-*` skills from `mcwestling/factory` and `wayfinder` from `mattpocock/skills`. `wayfinder`, `to-tickets`, `triage`, `implement` and `grill-me` set `disable-model-invocation: true`, so they only run when typed.
- **Shared Matt Pocock skills:** keep the `mattpocock/skills` entries in the lock and their shared copies in `~/.agents/skills`, so Cursor and the other CLI agents retain access. Skills CLI 1.7.6 routes Cursor's global installs to that shared directory even with `-a cursor --copy`; agent targeting does not isolate these skills from Codex.
- **Plugin overlap:** existing `mattpocock-skills` plugins also expose prefixed names such as `mattpocock-skills:tdd` alongside `tdd`. This overlap is accepted: the goal is access to the skills, and Factory resolves either the prefixed or bare upstream names. Keep the existing installations; no discovery exclusions or separate storage are needed. New machines get Matt's skills through the shared lock, so an additional plugin install is optional.
- **Orca-written skills:** Orca writes `orca-linear`, `orca-cli`, `orchestration` and `computer-use` into `~/.agents/skills`. They aren't in the lock, so `skills update` doesn't manage them, and every local session sees them, not only Orca-launched ones.
- **Orca-launched sessions:** these also get `ORCA_*` environment variables and report status through the global hooks above, which call scripts in `~/.orca/agent-hooks`. Orca re-adds its hooks to `~/.claude/settings.json` on launch.

The Factory hook runs `node ~/.agents/skills/do-factory-setup/check-skills.ts` through zsh, so `.zshenv` loads nvm even in a non-interactive session; it also adds Homebrew’s paths for `gh` and `jq`. It converts a stale-skills warning to `systemMessage` JSON, which [Claude Code](https://code.claude.com/docs/en/hooks#json-output) and [Codex](https://learn.chatgpt.com/docs/hooks#common-output-fields) display to the user. Current skills or a missing checker, Node, or GitHub access produce no warning; the checker bounds its GitHub call to three seconds and the hook has a five-second timeout. `jq` (already in the Brewfile) formats the JSON.

Claude's hook becomes live when the main checkout backing `~/.claude/settings.json` pulls the change. Run `./install.sh` from that checkout to merge Codex's entry, then use `/hooks` in Codex to trust it. Neither agent updates skills automatically.

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
