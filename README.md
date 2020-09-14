# dotfiles

These are my configuration files and notes for setting up a new Mac.

Do the following in order:
1. Clone this repo
1. Install Homebrew
1. Install `oh-my-zsh`
1. Install brew packages / casks
1. Set up 1Password
1. Sign into iCloud
1. Restore `mackup`
1. Set up Kryptonite
1. Set up `pyenv`
1. Set up AWS credentials

## Clone this repo
```zsh
% mkdir ~/Code && git clone https://github.com/expandrew/dotfiles
```

## Homebrew
```zsh
% /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

## oh-my-zsh
```zsh
% sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Packages
Install these packages with `brew install`:

```zsh
% brew install \
awscli \
mackup \
nvm \
postgresql \
pyenv \
rbenv \
ruby-build \
zsh-git-prompt \
```

### Casks
Install other macOS apps with `brew cask install`:

```zsh
% brew tap homebrew/cask-drivers # for logitech-options
% brew cask install \
1password \
authy \
docker \
github \
google-chrome \
iterm2 \
menumeters \
logitech-options \
spectacle \
spotify \
visual-studio-code \
whatsapp \
```

## 1Password
Set up using the camera / phone thing

## iCloud
Sign into iCloud now that 1Password is set up

## Mackup
Restore app settings from mackup

```zsh
% cp ~/code/dotfiles/mackup/.mackup.cfg ~/  # Copy the configuration to the home directory because I don't use the default
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
