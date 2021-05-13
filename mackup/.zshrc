# zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# Homebrew
[ -s "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)" # (Apple Silicon)

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm (Intel)
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm (Apple Silicon)
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion (Apple Silicon)

# pyenv
eval "$(pyenv init -)"

# rbenv
[ -s "/opt/homebrew/bin/brew" ] && export LDFLAGS="-L/opt/homebrew/opt/libffi/lib"
[ -s "/opt/homebrew/bin/brew" ] && export CPPFLAGS="-I/opt/homebrew/opt/libffi/include"
[ -s "/opt/homebrew/bin/brew" ] && export PKG_CONFIG_PATH="/opt/homebrew/opt/libffi/lib/pkgconfig"
eval "$(rbenv init -)"

# Add Postgres.app CLI tools to path
path+=('/Applications/Postgres.app/Contents/Versions/latest/bin')

# Aliases
alias chrome="open -a 'Google Chrome'"
alias brewme="sudo chown -R $USER $(brew --prefix)"

# Added by Krypton
export GPG_TTY=$(tty)
