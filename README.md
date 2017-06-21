# dotfiles

These are my configuration files and notes for setting up a new Mac.

## iTerm2

- Install [iTerm2](https://www.iterm2.com/).
- Clone this repository into `~/Code`.
- Open Preferences > General and set the Custom Folder to `/Users/amw/Code/dotfiles`.

![iTerm Preferences Location](https://user-images.githubusercontent.com/3157928/27269576-12ec5ca4-5486-11e7-839f-a6ef5ac4a978.png)

## Homebrew

```bash
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Install these packages with `brew install`:

- bash-completion
- bash-git-prompt
- git
- node
- python
- thefuck

## Bash

Use the `bash_profile` from this repository by replacing the local `~/.bash_profile` file with this:

```bash
# ~/.bash_profile

[[ -s "$HOME/Code/dotfiles/bash_profile" ]] && source "$HOME/Code/dotfiles/bash_profile"
```

## Git

Use the `gitconfig` from this repository by replacing the local `~/.gitconfig` file with this:

```bash
# ~/.gitconfig

[include]
  path = /Users/amw/Code/dotfiles/gitconfig
```

## pip

Install these packages with `pip install`:

- awscli

## Credentials

### Kryptonite (SSH Keys)

```bash
$ curl https://krypt.co/kr | sh
$ kr pair
```

### AWS

_Get AWS Access Key ID/Secret from elsewhere and use `aws configure` to set up the AWS CLI_

```bash
$ aws configure
```
