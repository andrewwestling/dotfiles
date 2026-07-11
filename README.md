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
mkdir ~/Code && git clone https://github.com/expandrew/dotfiles ~/Code/dotfiles
```

Run the install script. This installs Homebrew (if needed), Rosetta 2 (on Apple Silicon), symlinks `.zshrc`/`.gitconfig`/`.gitignore_global` into `~`, installs oh-my-zsh, runs `brew bundle`, and sets up nvm + Node:

```zsh
cd ~/Code/dotfiles && ./install.sh
```

It's safe to re-run — it skips anything already installed/linked, and backs up (rather than overwrites) any pre-existing dotfiles it would otherwise clobber.

Mac App Store apps (`mas` entries in the Brewfile) won't install yet — that needs iCloud sign-in first, so `brew bundle` gets re-run later in the [Mac App Store](#mac-app-store) step below.

### Multi-user setup

<details>
<summary>Details for using Homebrew with multiple accounts</summary>

If there are multiple user accounts on the same Mac, I need to follow a few extra steps:

1. Open System Preferences > Users & Groups
1. Create a new group called `brew`; add all the users to it
1. Run these steps:

```zsh
% sudo chgrp -R brew $(brew --prefix) # Change group to brew for Homebrew
% sudo chmod -R g+w $(brew --prefix) # Allow group members to write inside this directory
% brew doctor # Make sure everything is good
```

Even with this "shared group" setup, I still run into permissions issues sometimes when running `brew bundle`.

Usually I can resolve it by changing ownership to the current user for the Homebrew folder:

```zsh
% sudo chown -R $USER $(brew --prefix)
% brew bundle # Try installing again
```

</details>

### Brewfile

<details>
<summary>Details for updating Brewfile</summary>

This is how I update the Brewfile when I install/uninstall something:

```zsh
% cd ~/Code/dotfiles && brew bundle dump -f
# Then commit the changes to this repo, etc.
```

I just do this periodically and commit it, it's not automated but the command handles the file for me so I don't have to handwrite it

(There's a VS Code task to do this in [tasks.json](.vscode/tasks.json): **📝 Update Brewfile**)

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
