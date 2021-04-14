# dotfiles

These are my configuration files and notes for setting up a new Mac.

Do the following, in this order:

1. Clone this repo
1. Install `oh-my-zsh`
1. Install Rosetta 2 (for M1 Macs)
1. Install Homebrew and packages
1. Set up 1Password
1. Sign into iCloud
1. Install Mac App Store apps
1. Restore Mackup
1. Set up Krypton
1. Set up Python
1. Set up Ruby
1. Set up AWS credentials

## Clone this repo

```zsh
% mkdir ~/Code && git clone https://github.com/expandrew/dotfiles ~/Code/dotfiles
```

## oh-my-zsh

```zsh
% sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Rosetta 2

```zsh
% sudo softwareupdate --install-rosetta
```

## Homebrew

```zsh
# Install Homebrew
% /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Get `brew` in the PATH for now (this gets resolved for real when Mackup restores my .zshrc below)
% eval "$(/opt/homebrew/bin/brew shellenv)"

# Install everything from Brewfile, except Mac App Store apps - `mas` won't work yet, because I haven't signed into iCloud at this point - this has a dependency on 1Password step to get the password, so we'll re-run `brew bundle` again below after 1Password and iCloud are set up.
% cd ~/code/dotfiles && brew bundle
```

### Brewfile

<details>
<summary>Details for updating Brewfile</summary>

This is how I update the Brewfile when I install/uninstall something:

```zsh
% cd ~/code/dotfiles && brew bundle dump -f
# Then commit the changes to this repo, etc.
```

I just do this periodically and commit it, it's not automated but the command handles the file for me so I don't have to handwrite it

</details>

## 1Password

Set up using the camera / phone thing via mobile app.

## iCloud

Sign into iCloud now that 1Password is set up. Disable all the stuff except these:

- iCloud Drive
- Find My Mac

iCloud will also bring over my other Internet Accounts when I sign in. Go to the a@aw Google account and turn on "Contacts" sync (will ask me to sign into Google; grab password from 1Password and use security key for 2FA)

## Mac App Store

After setting up 1Password and iCloud above, run the Homebrew install step again to install Mac App Store apps.

```zsh
% cd ~/code/dotfiles && brew bundle # The `mas` steps should complete now that we're signed into iCloud
```

## Mackup

Restore app settings from mackup

```zsh
# Copy the configuration to the home directory because I don't use the default
% cp ~/code/dotfiles/mackup/.mackup.cfg ~/

# Copy the custom config directory for custom apps
% cp -r ~/code/dotfiles/mackup/.mackup ~/.mackup

% mackup restore
```

## Krypton (SSH / GPG Keys)

```zsh
% curl https://krypt.co/kr | sh
% kr pair
% kr codesign
```

## Python

Use `pyenv` to install and use the correct Python versions:

```zsh
% pyenv install 3.9.2
% pyenv global 3.9.2
% python --version # should return Python 3.9.2; if it isn't, something is wrong
```

## Ruby

Use `rbenv` to install and use the correct Ruby versions:

```zsh
% rbenv install 2.6.5
% rbenv global 2.6.5
% rbenv rehash # Make executables available
% gem install bundler
```

## AWS

_Get AWS Access Key ID/Secret from elsewhere and use `aws configure` to set up the AWS CLI_

```zsh
% aws configure
```
