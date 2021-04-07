# dotfiles

These are my configuration files and notes for setting up a new Mac.

Do the following in order:

1. Clone this repo
1. Install `oh-my-zsh`
1. Install Rosetta 2 (for M1 Macs)
1. Install Homebrew and packages
1. Set up 1Password
1. Sign into iCloud
1. Restore `mackup`
1. Set up Kryptonite
1. Set up `pyenv`
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
% /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
% eval "$(/opt/homebrew/bin/brew shellenv)" ## get brew in the PATH for now (will be actually added when Mackup is restored)
% cd ~/code/dotfiles && brew bundle # install everything from Brewfile
```

### Brewfile

This is how I update the Brewfile when I install/uninstall something:

```zsh
% cd ~/code/dotfiles
% brew bundle dump -f
# Then commit the changes to this repo, etc.
```

I just do this periodically and commit it, it's not automated but the command handles the file for me so I don't have to handwrite it

## 1Password

Set up using the camera / phone thing via mobile app.

## iCloud

Sign into iCloud now that 1Password is set up. Disable all the stuff except these:

- iCloud Drive
- Notes
- Find My Mac
- Home

## Mackup

Restore app settings from mackup

```zsh
# Copy the configuration to the home directory because I don't use the default
% cp ~/code/dotfiles/mackup/.mackup.cfg ~/

# Copy the custom config directory for custom apps
% cp -r ~/code/dotfiles/mackup/.mackup ~/.mackup

% mackup restore
```

## Kryptonite (SSH / GPG Keys)

```zsh
% curl https://krypt.co/kr | sh
% kr pair
% kr codesign
```

## Python

Use `pyenv` to install and use the correct Python versions:

```zsh
% pyenv install 3.6.8
% pyenv global 3.6.8
% python --version # should return Python 3.6.8; if it isn't, something is wrong
```

## pip

Install these packages with `pip install`:

```zsh
% pip install \
awscli \
```

## AWS

_Get AWS Access Key ID/Secret from elsewhere and use `aws configure` to set up the AWS CLI_

```zsh
% aws configure
```
