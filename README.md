# dotfiles

These are my configuration files and notes for setting up a new Mac.

Do the following in order:
1. Install Homebrew
1. Install `oh-my-zsh`
1. Install brew packages / casks
1. Restore `mackup`
1. Set up Kryptonite
1. Set up `pyenv`
1. Set up AWS credentials


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
% brew cask install \
1password \
authy \
docker \
github \
google-chrome \
iterm2 \
menumeters \
spectacle \
spotify \
visual-studio-code \
whatsapp \
```

For Logitech mouse drivers:

```zsh
% brew tap homebrew/cask-drivers
% brew cask install logitech-options
```
Then after setting up 1Password, sign in with Logitech Account Sync (settings should be stored there for mouse)


## Mackup

Restore app settings from mackup

```zsh
% cp ~/code/dotfiles/mackup/.mackup.cfg ~/  # copy the config because we don't use the default
% mackup restore
```

## Kryptonite (SSH / GPG Keys)

> ℹ️ I should come up with a different strategy for this; maybe deprecate Kryptonite as SSH situation

```zsh
$ curl https://krypt.co/kr | sh
$ kr pair
$ kr codesign
```

## Python

Use `pyenv` to install and use the correct Python versions:

```zsh
pyenv install 3.6.8
pyenv global 3.6.8
python --version # should return Python 3.6.8; if it isn't, something is wrong
```

## pip

> ℹ️ Should be able to deprecate this with mackup

Install these packages with `pip install`:

```zsh
$ pip install \
awscli \
```

## AWS

_Get AWS Access Key ID/Secret from elsewhere and use `aws configure` to set up the AWS CLI_

```zsh
$ aws configure
```
