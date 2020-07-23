# dotfiles

These are my configuration files and notes for setting up a new Mac.

## Homebrew

```zsh
% /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### Packages

Install these packages with `brew install`:

```zsh
% brew install \
awscli \
nvm \
postgresql \
pyenv \
rbenv \
ruby-build \
zsh-git-prompt \
```

### Cask

#### macOS Apps

Install other macOS apps with `brew cask install`:

```zsh
% brew cask install \
1password \
authy \
docker \
github \
iterm2 \
menumeters \
spectacle \
spotify \
sublime-text \
```

For Logitech mouse drivers:

```zsh
% brew tap homebrew/cask-drivers

% brew cask install logitech-options

```
Then configure the side buttons to Desktop Left/Right

## iTerm2

- Run the `brew cask install` command above to install iTerm2.
- Clone this repository into `~/Code`.
- Open Preferences > General and set the Custom Folder to `/Users/amw/Code/dotfiles`.

![iTerm Preferences Location](https://user-images.githubusercontent.com/3157928/27269576-12ec5ca4-5486-11e7-839f-a6ef5ac4a978.png)


## oh-my-zsh

```zsh
$ sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## zsh

Include the `zshrc` from this repository by adding this to the local `~/.zshrc`:

```zsh
# ~/.zshrc

[[ -s "$HOME/Code/dotfiles/zshrc" ]] && source "$HOME/Code/dotfiles/zshrc"
```

## Git

Use the `gitconfig` from this repository by replacing the local `~/.gitconfig` file with this:

```zsh
# ~/.gitconfig

[include]
  path = ~/Code/dotfiles/gitconfig
```

## Python

Use `pyenv` to install and use the correct Python versions:

```zsh
pyenv install 3.6.8
pyenv global 3.6.8
python --version # should return Python 3.6.8; if it isn't, something is wrong
```

## pip

Install these packages with `pip install`:

```zsh
$ pip install \
awscli \
```

## Credentials

### Kryptonite (SSH / GPG Keys)

```zsh
$ curl https://krypt.co/kr | sh
$ kr pair
$ kr codesign
```

### AWS

_Get AWS Access Key ID/Secret from elsewhere and use `aws configure` to set up the AWS CLI_

```zsh
$ aws configure
```

## Sublime Text

- Run the `brew cask install` command above to install Sublime Text 3.
- Install [Package Control](https://packagecontrol.io/installation)
- Create symlinks to the settings files in this repository:

```zsh
# Preferences
% rm ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings
% ln -s ~/Code/dotfiles/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings

# Package Control
% rm ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Package\ Control.sublime-settings
% ln -s ~/Code/dotfiles/Package\ Control.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Package\ Control.sublime-settings
```
