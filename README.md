# dotfiles

These are my configuration files and notes for setting up a new Mac.

## Homebrew

```bash
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### Packages

Install these packages with `brew install`:

```bash
$ brew install \
autoconf \
awscli \
bash-completion \
bash-git-prompt \
gdbm \
gettext \
git \
go \
icu4c \
kops \
kubernetes-cli \
kubetail \
libidn2 \
libunistring \
md5sha1sum \
mkcert \
node \
nspr \
nss \
nvm \
openssl \
pkg-config \
postgresql \
python \
rbenv \
readline \
ruby-build \
sops \
sqlite \
thefuck \
wget \
xz \
```

### Cask

#### macOS Apps

Install other macOS apps with `brew cask install`:

```bash
$ brew cask install \
1password \
authy \
bartender \
chromedriver \
docker \
dropbox \
github \
iterm2 \
karabiner-elements \
recordit \
sizeup \
slack \
spotify \
sublime-text \
tableplus \
visual-studio-code \
workflowy \
yujitach-menumeters \
```

#### Quick Look Plugins

These plugins add extra functionality to the macOS [Quick Look](https://support.apple.com/kb/PH25575?locale=en_US) feature. This list comes from [sindresorhus/quick-look-plugins](https://github.com/sindresorhus/quick-look-plugins).

Install all with this command:

```bash
$ brew cask install \
betterzipql \
qlcolorcode \
qlimagesize \
qlmarkdown \
qlprettypatch \
qlstephen \
qlvideo \
quicklook-csv \
quicklook-json \
quicklookase \
suspicious-package \
webpquicklook \
```

## iTerm2

- Run the `brew cask install` command above to install iTerm2.
- Clone this repository into `~/Code`.
- Open Preferences > General and set the Custom Folder to `/Users/amw/Code/dotfiles`.

![iTerm Preferences Location](https://user-images.githubusercontent.com/3157928/27269576-12ec5ca4-5486-11e7-839f-a6ef5ac4a978.png)

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
  path = ~/Code/dotfiles/gitconfig
```

## Go

Create a folder for Go code:

```bash
mkdir ~/go
```

## npm

Install these packages globally with `npm install -g`:

```bash
$ npm install -g \
bower \
eslint \
gulp \
jshint \
standard \
```

## pip

Install these packages with `pip install`:

```bash
$ pip install \
awscli \
```

## Credentials

### Kryptonite (SSH / GPG Keys)

```bash
$ curl https://krypt.co/kr | sh
$ kr pair
$ kr codesign
```

### AWS

_Get AWS Access Key ID/Secret from elsewhere and use `aws configure` to set up the AWS CLI_

```bash
$ aws configure
```

## Sublime Text

- Run the `brew cask install` command above to install Sublime Text 3.
- Install [Package Control](https://packagecontrol.io/installation)
- Create symlinks to the settings files in this repository:

```bash
# Preferences
$ rm ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings
$ ln -s ~/Code/dotfiles/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Preferences.sublime-settings

# Package Control
$ rm ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Package\ Control.sublime-settings
$ ln -s ~/Code/dotfiles/Package\ Control.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Package\ Control.sublime-settings
```
